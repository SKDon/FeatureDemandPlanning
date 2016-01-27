CREATE PROCEDURE [dbo].[Fdp_Validation_TakeRateForPackFeaturesShouldBeEquivalent]
	  @FdpVolumeHeaderId	INT
	, @MarketId				INT			 = NULL
	, @CDSId				NVARCHAR(16) = NULL
AS

	SET NOCOUNT ON;

	-- Get the models that we have data for for each market
	-- Coalesce as a big string so we can get the feature applicability for the market we are interested in

	DECLARE @Models AS TABLE
	(
		ModelId INT
	);
	DECLARE @ModelIdentifiers AS NVARCHAR(MAX);

	-- Don't worry about FDP models, as feature applicability isn't coded
	
	INSERT INTO @Models (ModelId)
	SELECT DISTINCT ModelId 
	FROM Fdp_TakeRateSummaryByModelAndMarket_VW AS M
	WHERE
	FdpVolumeHeaderId = @FdpVolumeHeaderId;

	SELECT @ModelIdentifiers = COALESCE(@ModelIdentifiers + ',' ,'') + QUOTENAME(CAST(ModelId AS NVARCHAR(10)))
	FROM @Models
	ORDER BY ModelId;

	DECLARE @Markets AS TABLE
	(
		  MarketId		INT
		, MarketGroupId INT
		, Processed		BIT
	);
	DECLARE @CurrentMarketId		AS INT;
	DECLARE @CurrentMarketGroupId	AS INT;
	DECLARE @FeaturePackTakeRate	AS DECIMAL(5, 4);
	DECLARE @TotalErrors			AS INT = 0;

	INSERT INTO @Markets 
	(
		MarketId, 
		MarketGroupId,
		Processed
	)
	SELECT DISTINCT 
		  MarketId
		, MarketGroupId
		, CAST(0 AS BIT) 
	FROM
	Fdp_TakeRateSummaryByMarket_VW AS M
	WHERE
	M.FdpVolumeHeaderId = @FdpVolumeHeaderId
	AND
	(@MarketId IS NULL OR M.MarketId = @MarketId)

	SELECT TOP 1 @CurrentMarketId = MarketId, @CurrentMarketGroupId = MarketGroupId FROM @Markets WHERE Processed = 0;

	WHILE @CurrentMarketId IS NOT NULL
	BEGIN
		INSERT INTO Fdp_Validation
		(
			  FdpVolumeHeaderId
			, MarketId
			, FdpValidationRuleId
			, [Message]
			, FdpTakeRateSummaryId
			, FdpChangesetDataItemId
		)
		SELECT
			  H.FdpVolumeHeaderId 
			, @CurrentMarketId		AS MarketId
			, 6 -- TakeRateForPackFeaturesShouldBeEquivalent
			, MAX('Take rate for all features in pack ''' + P.Pack_Name + ''' should be equivalent') AS [Message]
			, MAX(S.FdpTakeRateSummaryId)	AS FdpTakeRateSummaryId
			, C.FdpChangesetDataItemId
		FROM 
		Fdp_VolumeHeader					AS H
		JOIN OXO_Doc						AS O	ON	H.DocumentId			= O.Id
		JOIN Fdp_VolumeDataItem_VW			AS D	ON	H.FdpVolumeHeaderId		= D.FdpVolumeHeaderId
													AND D.IsFeatureData			= 1
													AND D.MarketId				= @CurrentMarketId
		LEFT JOIN Fdp_ChangesetDataItem_VW AS C		ON H.FdpVolumeHeaderId		= C.FdpVolumeHeaderId
													AND D.FdpVolumeDataItemId	= C.FdpVolumeDataItemId
													AND C.IsFeatureUpdate		= 1
													AND C.CDSId					= @CDSId
		JOIN Fdp_TakeRateSummary			AS S	ON	D.MarketId				= S.MarketId
													AND D.ModelId				= S.ModelId
													AND H.FdpVolumeHeaderId		= S.FdpVolumeHeaderId
		JOIN OXO_Programme_Pack				AS P	ON	D.FeaturePackId			= P.Id
													AND O.Programme_Id			= P.Programme_Id
		CROSS APPLY dbo.FN_OXO_Data_Get_FBM_Market(H.DocumentId, @CurrentMarketGroupId, @CurrentMarketId, @ModelIdentifiers) AS F
		LEFT JOIN Fdp_Validation			AS V	ON	S.FdpTakeRateSummaryId	= V.FdpTakeRateSummaryId
													AND	V.IsActive = 1
		WHERE
		H.FdpVolumeHeaderId = @FdpVolumeHeaderId
		AND
		F.OXO_Code LIKE '%P%'
		AND
		D.ModelId = F.Model_Id
		AND
		D.FeatureId = F.Feature_Id
		AND
		V.FdpValidationId IS NULL
		GROUP BY
		H.FdpVolumeHeaderId, D.ModelId, D.FeaturePackId, D.FeatureId, ISNULL(C.PercentageTakeRate, D.PercentageTakeRate), C.FdpChangesetDataItemId
		-- If we have more than one percentage take rate, we now that the feature and pack take is different
		HAVING
		COUNT(ISNULL(C.PercentageTakeRate, D.PercentageTakeRate)) > 1

		SET @TotalErrors = @TotalErrors + @@ROWCOUNT;

		UPDATE @Markets SET Processed = 1 WHERE MarketId = @CurrentMarketId;
		SET @CurrentMarketId = NULL;
		SELECT TOP 1 @CurrentMarketId = MarketId, @CurrentMarketGroupId = MarketGroupId FROM @Markets WHERE Processed = 0; 
	END
	
	PRINT 'Take rate for pack feature errors added: ' + CAST(@TotalErrors AS NVARCHAR(10))