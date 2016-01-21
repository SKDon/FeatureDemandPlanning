CREATE PROCEDURE [dbo].[Fdp_TakeRateData_Validate] 
	  @FdpVolumeHeaderId	AS INT
	, @MarketId				AS INT = NULL
	, @CDSId				AS NVARCHAR(16)
AS
BEGIN
	SET NOCOUNT ON;

    DECLARE @Markets AS TABLE
    (
		MarketId INT
    )
    DECLARE @ValidationError AS TABLE
    (
		  FdpVolumeHeaderId			INT
		, MarketId					INT
		, FdpValidationRuleId		INT
		, ValidationMessage			NVARCHAR(MAX)
		, FdpChangesetDataItemId	INT NULL
		, FdpVolumeDataItemId		INT NULL
		, FdpTakeRateSummaryId		INT NULL
		, FdpTakeRateFeatureMixId	INT NULL
    )
    DECLARE @FdpChangesetId AS INT;
    
    -- Filter the markets by the market information in the dataset and optionally further by market id
    
    INSERT INTO @Markets
    (
		MarketId
    )
    SELECT DISTINCT MarketId
    FROM
    Fdp_VolumeDataItem_VW	AS D
    WHERE
    D.FdpVolumeHeaderId = @FdpVolumeHeaderId
    AND
    (@MarketId IS NULL OR D.MarketId = @MarketId);
    
    -- If the user has any unsaved changes (only for market specific data), 
    -- these need to be included in the validation process
    
    SELECT TOP 1 @FdpChangesetId = C.FdpChangesetId
	FROM
	Fdp_VolumeHeader	AS H
	JOIN Fdp_Changeset	AS C	ON H.FdpVolumeHeaderId = C.FdpVolumeHeaderId
	WHERE
	H.FdpVolumeHeaderId = @FdpVolumeHeaderId
	AND
	C.CreatedBy = @CDSID
	AND
	C.IsDeleted = 0
	AND
	C.IsSaved = 0
	AND
	C.MarketId = @MarketId
	ORDER BY
	C.CreatedOn DESC;
	
	-- Lower any validation errors for that document / market
	-- This stops any validation errors that are no longer relevant from surfacing
	
	UPDATE Fdp_Validation SET IsActive = 0
	WHERE
	FdpVolumeHeaderId = @FdpVolumeHeaderId
	AND
	(@MarketId IS NULL OR MarketId = @MarketId);
	
	-- We have number of validation rules - Validate against each in turn, adding validation entries as necessary

	-- 1. Take rate above 100% and below 0% is not allowed
	-- 2. Volume for a feature cannot exceed the volume for a model
	-- 3. Total volumes for models at a market level cannot exceed the total volume for the market
	-- 4. Total % take for models at a market level cannot exceed 100%
	-- 5. Take rate for standard features should be 100%
	-- 6. Take rate for all features as part of packs should be equivalent
	-- 7. EFG (Exclusive feature group). All features in a group must add up to 100% (or less if information is incomplete)
	
	-- 1. Take rate above 100% and below 0% is not allowed
	-- ===================================================
	
	INSERT INTO @ValidationError
	(
		  FdpVolumeHeaderId
		, MarketId
		, FdpValidationRuleId
		, ValidationMessage
		, FdpVolumeDataItemId
		, FdpTakeRateSummaryId
		, FdpTakeRateFeatureMixId
		, FdpChangesetDataItemId
	)
	-- Take rate feature data
	SELECT 
		  D.FdpVolumeHeaderId
		, D.MarketId
		, R.FdpValidationRuleId
		, CASE 
			WHEN ISNULL(C.PercentageTakeRate, D.PercentageTakeRate) > 1 THEN 'Take rate for feature cannot exceed 100%'
			WHEN ISNULL(C.PercentageTakeRate, D.PercentageTakeRate) < 0 THEN 'Take rate for feature cannot be less than 0%'
		  END
		, D.FdpVolumeDataItemId
		, NULL
		, NULL
		, C.FdpChangesetDataItemId
	FROM
	Fdp_VolumeDataItem_VW				AS D
	LEFT JOIN Fdp_ChangesetDataItem_VW	AS C	ON	C.FdpChangesetId		= @FdpChangesetId
												AND C.FdpVolumeDataItemId	= D.FdpVolumeDataItemId
	JOIN @Markets						AS M	ON	D.MarketId				= M.MarketId
	CROSS APPLY Fdp_ValidationRule		AS R 
	WHERE
	D.FdpVolumeHeaderId = @FdpVolumeHeaderId
	AND
	(ISNULL(C.PercentageTakeRate, D.PercentageTakeRate) < 0 OR ISNULL(C.PercentageTakeRate, D.PercentageTakeRate) > 1)
	AND
	R.FdpValidationRuleId = 1
	AND
	R.IsActive = 1
	
	UNION
	
	-- Take rate model by market data
	SELECT 
		  S.FdpVolumeHeaderId
		, S.MarketId
		, R.FdpValidationRuleId
		, CASE 
			WHEN ISNULL(C.PercentageTakeRate, S.PercentageTakeRate) > 1 THEN 'Take rate for model cannot exceed 100%'
			WHEN ISNULL(C.PercentageTakeRate, S.PercentageTakeRate) < 0 THEN 'Take rate for model cannot be less than 0%'
		  END
		, NULL
		, S.FdpTakeRateSummaryId
		, NULL
		, C.FdpChangesetDataItemId
	FROM
	Fdp_TakeRateSummary					AS S
	LEFT JOIN Fdp_ChangesetDataItem_VW	AS C	ON	C.FdpChangesetId		= @FdpChangesetId
												AND C.FdpTakeRateSummaryId	= S.FdpTakeRateSummaryId
	JOIN @Markets						AS M	ON	S.MarketId				= M.MarketId
	CROSS APPLY Fdp_ValidationRule		AS R 
	WHERE
	S.FdpVolumeHeaderId = @FdpVolumeHeaderId
	AND
	(ISNULL(C.PercentageTakeRate, S.PercentageTakeRate) < 0 OR ISNULL(C.PercentageTakeRate, S.PercentageTakeRate) > 1)
	AND
	R.FdpValidationRuleId = 1
	AND
	R.IsActive = 1
	
	UNION
	
	-- Take rate feature mix data
	SELECT 
		  FM.FdpVolumeHeaderId
		, FM.MarketId
		, R.FdpValidationRuleId
		, CASE 
			WHEN ISNULL(C.PercentageTakeRate, FM.PercentageTakeRate) > 1 THEN 'Take rate for feature mix cannot exceed 100%'
			WHEN ISNULL(C.PercentageTakeRate, FM.PercentageTakeRate) < 0 THEN 'Take rate for feature mix cannot be less than 0%'
		  END
		, NULL
		, NULL
		, FM.FdpTakeRateFeatureMixId
		, C.FdpChangesetDataItemId
	FROM
	Fdp_TakeRateFeatureMix				AS FM
	LEFT JOIN Fdp_ChangesetDataItem_VW	AS C	ON	C.FdpChangesetId			= @FdpChangesetId
												AND C.FdpTakeRateFeatureMixId	= FM.FdpTakeRateFeatureMixId
	JOIN @Markets						AS M	ON	FM.MarketId					= M.MarketId
	CROSS APPLY Fdp_ValidationRule		AS R 
	WHERE
	FM.FdpVolumeHeaderId = @FdpVolumeHeaderId
	AND
	(ISNULL(C.PercentageTakeRate, FM.PercentageTakeRate) < 0 OR ISNULL(C.PercentageTakeRate, FM.PercentageTakeRate) > 1)
	AND
	R.FdpValidationRuleId = 1
	AND
	R.IsActive = 1;
	
	-- 2. Volume for a feature cannot exceed the volume for a model
	-- ============================================================
	
	INSERT INTO @ValidationError
	(
		  FdpVolumeHeaderId
		, MarketId
		, FdpValidationRuleId
		, ValidationMessage
		, FdpVolumeDataItemId
		, FdpTakeRateSummaryId
		, FdpChangesetDataItemId
	)
	SELECT 
		  D.FdpVolumeHeaderId
		, D.MarketId
		, R.FdpValidationRuleId
		, 'Volume for feature cannot exceed volume for model'
		, D.FdpVolumeDataItemId
		, S.FdpTakeRateSummaryId
		, C.FdpChangesetDataItemId
	FROM
	Fdp_VolumeDataItem_VW								AS D
	-- Changeset changes at feature level
	LEFT JOIN Fdp_ChangesetDataItem_VW					AS C	ON	C.FdpChangesetId			= @FdpChangesetId
																AND C.FdpVolumeDataItemId		= D.FdpVolumeDataItemId
	JOIN @Markets										AS M	ON	D.MarketId					= M.MarketId
	LEFT JOIN Fdp_TakeRateSummaryByModelAndMarket_VW	AS S	ON	D.FdpVolumeHeaderId			= S.FdpVolumeHeaderId
																AND D.MarketId					= S.MarketId
																AND D.ModelId					= S.ModelId
	-- Changeset changes at model level
	LEFT JOIN Fdp_ChangesetModel_VW						AS C1	ON	C1.FdpChangesetId			= @FdpChangesetId
																AND S.FdpTakeRateSummaryId		= C1.FdpTakeRateSummaryId
	CROSS APPLY Fdp_ValidationRule						AS R 
	WHERE
	D.FdpVolumeHeaderId = @FdpVolumeHeaderId
	AND
	ISNULL(C.TotalVolume, D.Volume) > ISNULL(C1.TotalVolume, S.TotalVolume)
	AND
	R.FdpValidationRuleId = 2
	AND
	R.IsActive = 1
	
	UNION
	
	SELECT 
		  D.FdpVolumeHeaderId
		, D.MarketId
		, R.FdpValidationRuleId
		, 'Volume for feature cannot exceed volume for model'
		, D.FdpVolumeDataItemId
		, S.FdpTakeRateSummaryId
		, C.FdpChangesetDataItemId
	FROM
	Fdp_VolumeDataItem_VW								AS D
	-- Changeset changes at feature level
	LEFT JOIN Fdp_ChangesetDataItem_VW					AS C	ON	C.FdpChangesetId			= @FdpChangesetId
																AND C.FdpVolumeDataItemId		= D.FdpVolumeDataItemId
	JOIN @Markets										AS M	ON	D.MarketId					= M.MarketId
	LEFT JOIN Fdp_TakeRateSummaryByModelAndMarket_VW	AS S	ON	D.FdpVolumeHeaderId			= S.FdpVolumeHeaderId
																AND D.MarketId					= S.MarketId
																AND D.FdpModelId				= S.FdpModelId
	-- Changeset changes at model level
	LEFT JOIN Fdp_ChangesetModel_VW						AS C1	ON	C1.FdpChangesetId			= @FdpChangesetId
																AND S.FdpTakeRateSummaryId		= C1.FdpTakeRateSummaryId
	CROSS APPLY Fdp_ValidationRule						AS R 
	WHERE
	D.FdpVolumeHeaderId = @FdpVolumeHeaderId
	AND
	ISNULL(C.TotalVolume, D.Volume) > ISNULL(C1.TotalVolume, S.TotalVolume)
	AND
	R.FdpValidationRuleId = 2
	AND
	R.IsActive = 1
	
	-- 3. Total volumes for models at a market level cannot exceed the total volume for the market
	-- ===========================================================================================
	
	INSERT INTO @ValidationError
	(
		  FdpVolumeHeaderId
		, MarketId
		, FdpValidationRuleId
		, ValidationMessage
		, FdpChangesetDataItemId
	)
	SELECT 
		  S.FdpVolumeHeaderId
		, S.MarketId
		, R.FdpValidationRuleId
		, 'Total volume for models cannot exceed volume for market'
		, C.FdpChangesetDataItemId
	FROM
	Fdp_VolumeHeader									AS H
	JOIN Fdp_TakeRateSummaryByMarket_VW					AS S	ON	H.FdpVolumeHeaderId	= S.FdpVolumeHeaderId
	LEFT JOIN Fdp_ChangesetMarket_VW					AS C	ON	C.FdpChangesetId	= @FdpChangesetId
																AND S.MarketId			= C.MarketId
	JOIN @Markets										AS M	ON	S.MarketId			= M.MarketId
	JOIN
	(
		SELECT
			  M.FdpVolumeHeaderId
			, M.MarketId
			, SUM(ISNULL(C.TotalVolume, M.TotalVolume)) AS TotalVolume
		FROM
		Fdp_TakeRateSummaryByModelAndMarket_VW	AS M
		LEFT JOIN Fdp_ChangesetModel_VW			AS C	ON C.FdpChangesetId			= @FdpChangesetId
														AND M.FdpTakeRateSummaryId	= C.FdpTakeRateSummaryId
		GROUP BY
		M.FdpVolumeHeaderId, M.MarketId
	)											AS M1	ON	H.FdpVolumeHeaderId		= M1.FdpVolumeHeaderId
														AND S.MarketId				= M1.MarketId
	CROSS APPLY Fdp_ValidationRule				AS R 
	WHERE
	H.FdpVolumeHeaderId = @FdpVolumeHeaderId
	AND
	M1.TotalVolume > S.TotalVolume
	AND
	R.FdpValidationRuleId = 3
	AND
	R.IsActive = 1
	
	-- 4. % Take for each model at a market level cannot exceed 100%
	-- =============================================================
	
	INSERT INTO @ValidationError
	(
		  FdpVolumeHeaderId
		, MarketId
		, FdpValidationRuleId
		, ValidationMessage
	)
	SELECT 
		  S.FdpVolumeHeaderId
		, S.MarketId
		, R.FdpValidationRuleId
		, 'Total % take for models cannot exceed 100%'				AS ValidationMessage
	FROM
	Fdp_VolumeHeader									AS H
	JOIN Fdp_TakeRateSummaryByModelAndMarket_VW			AS S	ON	H.FdpVolumeHeaderId	= S.FdpVolumeHeaderId
	LEFT JOIN Fdp_ChangesetModel_VW						AS C	ON	C.FdpChangesetId	= @FdpChangesetId
																AND S.MarketId			= C.MarketId
	JOIN @Markets										AS M	ON	S.MarketId			= M.MarketId
	CROSS APPLY Fdp_ValidationRule				AS R 
	WHERE
	H.FdpVolumeHeaderId = @FdpVolumeHeaderId
	AND
	R.FdpValidationRuleId = 4
	AND
	R.IsActive = 1
	GROUP BY
	  S.FdpVolumeHeaderId
	, S.MarketId
	, R.FdpValidationRuleId
	HAVING
	SUM(ISNULL(C.PercentageTakeRate, S.PercentageTakeRate)) > 1
	
	-- Insert the validation entries into the database
	
	INSERT INTO Fdp_Validation
	(
		  FdpVolumeHeaderId
		, MarketId
		, FdpValidationRuleId
		, [Message]
		, FdpVolumeDataItemId
		, FdpTakeRateSummaryId
		, FdpTakeRateFeatureMixId
		, FdpChangesetDataItemId
	)
	SELECT
		  E.FdpVolumeHeaderId
		, E.MarketId
		, E.FdpValidationRuleId
		, E.ValidationMessage
		, E.FdpVolumeDataItemId
		, E.FdpTakeRateSummaryId
		, E.FdpTakeRateFeatureMixId
		, E.FdpChangesetDataItemId
		
	FROM @ValidationError AS E
END