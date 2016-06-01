CREATE PROCEDURE [dbo].[Fdp_TakeRateData_GetCrossTab] 
    @FdpVolumeHeaderId	INT = NULL
  , @DocumentId			INT = NULL
  , @Mode				NVARCHAR(2)
  , @ObjectId			INT = NULL
  , @ModelIds			NVARCHAR(MAX)
  , @ShowPercentage		BIT = 0
  , @IsExport			BIT = 0
  , @Filter				NVARCHAR(100) = NULL
AS
	SET NOCOUNT ON;

	DECLARE @Sql				NVARCHAR(MAX) = N'';
	DECLARE @ProgrammeId		INT; 
	DECLARE @Gateway			NVARCHAR(100);   	
	DECLARE @MarketGroupId		INT;
	DECLARE @FdpOxoDocId		INT;
	DECLARE @FilteredVolume		INT;
	DECLARE @FilteredPercentage	DECIMAL(5,4);
	DECLARE @TotalVolume		INT;

	-- If the take rate file has not been specified explicitly work out the latest file
	-- from the document id

	IF @FdpVolumeHeaderId IS NULL
		SELECT @FdpVolumeHeaderId = dbo.fn_Fdp_LatestTakeRateFileByDocument_Get(@DocumentId)

	IF @DocumentId IS NULL
		SELECT @DocumentId = DocumentId
		FROM Fdp_VolumeHeader
		WHERE
		FdpVolumeHeaderId = @FdpVolumeHeaderId;
	
	SELECT TOP 1 
		  @ProgrammeId	= H.ProgrammeId
		, @Gateway		= H.Gateway
		, @MarketGroupId = MK.Market_Group_Id
	FROM 
	Fdp_VolumeHeader_VW AS H
	LEFT JOIN OXO_Programme_MarketGroupMarket_VW AS MK ON H.ProgrammeId = MK.Programme_Id
														AND MK.Market_Id = @ObjectId
	WHERE 
	H.FdpVolumeHeaderId = @FdpVolumeHeaderId;
	
	DECLARE @Model AS TABLE
	(
		  ModelId		INT PRIMARY KEY
		, StringIdentifier NVARCHAR(10)
		, IsFdpModel	BIT
	)
	INSERT INTO @Model
	(
		  ModelId
		, StringIdentifier
		, IsFdpModel
	)
	SELECT ModelId, StringIdentifier, IsFdpModel 
	FROM dbo.fn_Fdp_SplitModelIds(@ModelIds);
	
	-- Work out total volumes so we can calculate percentage take from the feature mix
	
	SELECT TOP 1 @TotalVolume = TotalVolume FROM Fdp_VolumeHeader WHERE FdpVolumeHeaderId = @FdpVolumeHeaderId;

	SELECT @FilteredVolume = @TotalVolume;
	SET @FilteredPercentage = 1;

	IF @ObjectId IS NOT NULL 
	BEGIN
		SELECT TOP 1 @FilteredVolume = Volume, @FilteredPercentage = PercentageTakeRate 
		FROM Fdp_TakeRateSummary 
		WHERE
		FdpVolumeHeaderId = @FdpVolumeHeaderId
		AND
		MarketId = @ObjectId
		AND
		ModelId IS NULL;
	END;

	DECLARE @FdpPivotHeaderId AS INT;
	SELECT TOP 1 @FdpPivotHeaderId = FdpPivotHeaderId
	FROM Fdp_PivotHeader 
	WHERE 
	FdpVolumeHeaderId = @FdpVolumeHeaderId
	AND
	(
		(@ObjectId IS NULL AND MarketId IS NULL)
		OR
		(@ObjectId IS NOT NULL AND MarketId = @ObjectId)
	)
	AND
	ModelIds = @ModelIds;

	IF @FdpPivotHeaderId IS NULL
	BEGIN
		EXEC Fdp_PivotData_Update 
			  @FdpVolumeHeaderId = @FdpVolumeHeaderId
			, @MarketId = @ObjectId
			, @ModelIds = @ModelIds
			, @FdpPivotHeaderId = @FdpPivotHeaderId OUTPUT;
	END
	
	IF @ShowPercentage = 0
	BEGIN
		SET @Sql =		  'SELECT DATASET.* '				
		SET @Sql = @Sql + 'FROM ( '
		SET @Sql = @Sql + '  SELECT RANK() OVER (ORDER BY DisplayOrder, FeatureCode, FeatureIdentifier) AS Id, DisplayOrder, FeatureIdentifier, FeatureGroup, FeatureSubGroup, FeatureCode, BrandDescription, FeatureComment, FeatureRuleText, ExclusiveFeatureGroup, StringIdentifier, '
		SET @Sql = @Sql + '  SystemDescription, HasRule, LongDescription, FeaturePackId, IsOrphanedData, IsIgnoredData, IsMappedToMultipleImportFeatures, ISNULL(Volume, 0) AS Volume '
		SET @Sql = @Sql + '  FROM Fdp_PivotData '
		SET @Sql = @Sql + '  WHERE FdpPivotHeaderId = ' + CAST(@FdpPivotHeaderId AS NVARCHAR(10)) + ' '
		SET @Sql = @Sql + ') AS S1 '
		SET @Sql = @Sql + 'LEFT JOIN '
		SET @Sql = @Sql + '( '
		SET @Sql = @Sql + ' SELECT FdpVolumeHeaderId, MarketId AS FeatureMixMarketId, FeatureIdentifier AS FeatureMixIdentifier, Volume AS TotalVolume, PercentageTakeRate AS TotalPercentageTakeRate '
		SET @Sql = @Sql + ' FROM Fdp_TakeRateFeatureMix AS F '
		SET @Sql = @Sql + ') '
		SET @Sql = @Sql + 'AS FMIX ON S1.FeatureIdentifier = FMIX.FeatureMixIdentifier '
		SET @Sql = @Sql + 'AND FMIX.FdpVolumeHeaderId = ' + CAST(@FdpVolumeHeaderId AS NVARCHAR(10)) + ' '
		
		IF @ObjectId IS NULL
			SET @Sql = @Sql + 'AND FMIX.FeatureMixMarketId IS NULL '
		ELSE
			SET @Sql = @Sql + 'AND FMIX.FeatureMixMarketId = ' + CAST(@ObjectId AS NVARCHAR(10)) + ' '

		SET @Sql = @Sql + 'PIVOT ( '
		SET @Sql = @Sql + 'SUM([Volume]) FOR StringIdentifier '
		SET @Sql = @Sql + 'IN (' + @ModelIds + ')) AS DATASET '
		SET @Sql = @Sql + 'ORDER BY DisplayOrder, FeatureCode';
	END
	ELSE
	BEGIN
		SET @Sql =		  'SELECT DATASET.* '
		SET @Sql = @Sql + 'FROM ( '
		SET @Sql = @Sql + '  SELECT RANK() OVER (ORDER BY DisplayOrder, FeatureCode, FeatureIdentifier) AS Id, DisplayOrder, FeatureIdentifier, FeatureGroup, FeatureSubGroup, FeatureCode, BrandDescription, FeatureComment, FeatureRuleText, ExclusiveFeatureGroup, StringIdentifier, '
		SET @Sql = @Sql + '  SystemDescription, HasRule, LongDescription, FeaturePackId, IsOrphanedData, IsIgnoredData, IsMappedToMultipleImportFeatures, PercentageTakeRate '
		SET @Sql = @Sql + '  FROM Fdp_PivotData '
		SET @Sql = @Sql + '  WHERE FdpPivotHeaderId = ' + CAST(@FdpPivotHeaderId AS NVARCHAR(10)) + ' '
		SET @Sql = @Sql + ') AS S2 '
		SET @Sql = @Sql + 'LEFT JOIN '
		SET @Sql = @Sql + '( '
		SET @Sql = @Sql + ' SELECT FdpVolumeHeaderId, MarketId AS FeatureMixMarketId, FeatureIdentifier AS FeatureMixIdentifier, PercentageTakeRate AS TotalPercentageTakeRate '
		SET @Sql = @Sql + ' FROM Fdp_TakeRateFeatureMix AS F '
		SET @Sql = @Sql + ') '
		SET @Sql = @Sql + 'AS FMIX ON S2.FeatureIdentifier = FMIX.FeatureMixIdentifier '
		SET @Sql = @Sql + 'AND FMIX.FdpVolumeHeaderId = ' + CAST(@FdpVolumeHeaderId AS NVARCHAR(10)) + ' '
		
		-- We need to ensure that we bring back the correct feature mix for the market (or lack thereof)
		IF @ObjectId IS NULL
			SET @Sql = @Sql + 'AND FMIX.FeatureMixMarketId IS NULL '
		ELSE
			SET @Sql = @Sql + 'AND FMIX.FeatureMixMarketId = ' + CAST(@ObjectId AS NVARCHAR(10)) + ' '

		SET @Sql = @Sql + 'PIVOT ( '
		SET @Sql = @Sql + 'SUM([PercentageTakeRate]) FOR StringIdentifier '
		SET @Sql = @Sql + 'IN (' + @ModelIds + ')) AS DATASET '
		SET @Sql = @Sql + 'ORDER BY DisplayOrder, FeatureCode';			
	END

	PRINT 'Take Rate: ' + @Sql;
	EXEC sp_executesql @Sql;
	
	-- For the second dataset, return the OXO Code to determine the feature applicability
	-- Unfortunately we can't easily combine into the first dataset due to the fact that we are pivoting on different columns
	
	SET @Sql =		  'SELECT DATASET.* '				
	SET @Sql = @Sql + 'FROM ( '
	SET @Sql = @Sql + 'SELECT RANK() OVER (ORDER BY DisplayOrder, FeatureCode, FeatureIdentifier) AS Id, DisplayOrder, FeatureIdentifier, FeatureGroup, FeatureSubGroup, FeatureCode, BrandDescription, FeatureComment, FeatureRuleText, ExclusiveFeatureGroup, StringIdentifier, '
	SET @Sql = @Sql + 'SystemDescription, HasRule, LongDescription, FeaturePackId, IsOrphanedData, IsIgnoredData, IsMappedToMultipleImportFeatures, OXOCode '
	SET @Sql = @Sql + 'FROM Fdp_PivotData WHERE FdpPivotHeaderId = ' + CAST(@FdpPivotHeaderId AS NVARCHAR(10)) + ') AS S3 '
	SET @Sql = @Sql + 'PIVOT ( '
	SET @Sql = @Sql + 'MAX([OXOCode]) FOR StringIdentifier '
	SET @Sql = @Sql + 'IN (' + @ModelIds + ')) AS DATASET '
	SET @Sql = @Sql + 'ORDER BY DisplayOrder, FeatureCode';

	PRINT 'Feature Applicability: ' + @Sql;
	EXEC sp_executesql @Sql;
	
	-- Third dataset returning volume and percentage take rate by derivative
	-- Calculate the total volumes for the whole unfiltered dataset and the filtered dataset

	IF @Mode = 'MG'
	BEGIN
		SELECT 
		  M.StringIdentifier
		, M.IsFdpModel
		, SUM(S.TotalVolume) AS Volume
		, dbo.fn_Fdp_PercentageTakeRate_Get(SUM(S.TotalVolume), @FilteredVolume) AS PercentageOfFilteredVolume
		FROM
		Fdp_TakeRateSummaryByModelAndMarket_VW AS S
		JOIN @Model AS M ON S.ModelId = M.ModelId
						 AND M.IsFdpModel = 0
		WHERE
		S.FdpVolumeHeaderId = @FdpVolumeHeaderId
		AND
		(@MarketGroupId IS NULL OR S.MarketGroupId = @MarketGroupId)
		GROUP BY
		M.StringIdentifier, M.IsFdpModel

		UNION

		SELECT 
			  M.StringIdentifier
			, M.IsFdpModel
			, SUM(S.TotalVolume) AS Volume
			, dbo.fn_Fdp_PercentageTakeRate_Get(SUM(S.TotalVolume), @FilteredVolume) AS PercentageOfFilteredVolume
		FROM
		Fdp_TakeRateSummaryByModelAndMarket_VW AS S
		JOIN @Model AS M ON S.FdpModelId = M.ModelId
						 AND M.IsFdpModel = 1
		WHERE
		S.FdpVolumeHeaderId = @FdpVolumeHeaderId
		AND
		(@MarketGroupId IS NULL OR S.MarketGroupId = @MarketGroupId)
		GROUP BY
		M.StringIdentifier, M.IsFdpModel
	END
	ELSE
	BEGIN
	SELECT 
		  M.StringIdentifier
		, M.IsFdpModel
		, S.TotalVolume AS Volume
		, S.PercentageTakeRate AS PercentageOfFilteredVolume
		FROM
		Fdp_TakeRateSummaryByModelAndMarket_VW AS S
		JOIN @Model AS M ON S.ModelId = M.ModelId
						 AND M.IsFdpModel = 0
		WHERE
		S.FdpVolumeHeaderId = @FdpVolumeHeaderId
		AND
		S.MarketId = @ObjectId

		UNION

		SELECT 
			  M.StringIdentifier
			, M.IsFdpModel
			, S.TotalVolume
			, S.PercentageTakeRate AS PercentageOfFilteredVolume
		FROM
		Fdp_TakeRateSummaryByModelAndMarket_VW AS S
		JOIN @Model AS M ON S.FdpModelId = M.ModelId
						 AND M.IsFdpModel = 1
		WHERE
		S.FdpVolumeHeaderId = @FdpVolumeHeaderId
		AND
		S.MarketId = @ObjectId
	END
	
	-- Summary dataset returning the meta information for the data (created by, updated, total volume mix, volume for market, etc)
	
	SELECT TOP 1
		  ISNULL(@TotalVolume, 0)				AS TotalVolume
		, ISNULL(@FilteredVolume, 0)			AS FilteredVolume
		, ISNULL(@FilteredPercentage, 0.0)		AS PercentageOfTotalVolume
		, H.CreatedBy
		, H.CreatedOn
		
	FROM
	Fdp_VolumeHeader AS H
	WHERE
	H.FdpVolumeHeaderId = @FdpVolumeHeaderId
	
	-- Additional dataset returning whether or not a data item has a note associated with it

	SELECT 
		  D.FdpVolumeDataItemId
		, CAST(NULL AS INT) AS FdpTakeRateSummaryId
		, D.MarketId
		, D.MarketGroupId
		, D.ModelId
		, D.FdpModelId
		, D.FeatureId
		, D.FdpFeatureId
		
	FROM Fdp_VolumeHeader	AS H
	JOIN
	(
		SELECT
			  H.DocumentId
			, H.FdpVolumeHeaderId
			, D.FdpVolumeDataItemId
		FROM 
		Fdp_VolumeHeader AS H
		JOIN Fdp_VolumeDataItem AS D ON	H.FdpVolumeHeaderId	= D.FdpVolumeHeaderId
		JOIN Fdp_TakeRateDataItemNote AS N ON D.FdpVolumeDataItemId = N.FdpTakeRateDataItemId
		GROUP BY
		  H.DocumentId
		, H.FdpVolumeHeaderId
		, D.FdpVolumeDataItemId
	)
							AS N	ON	H.FdpVolumeHeaderId		= N.FdpVolumeHeaderId
	JOIN Fdp_VolumeDataItem	AS D	ON	N.FdpVolumeDataItemId	= D.FdpVolumeDataItemId
	WHERE 
	H.FdpVolumeHeaderId = @FdpVolumeHeaderId
	AND
	(
		(@Mode = 'M' AND (@ObjectId IS NULL OR D.MarketId = @ObjectId))
		OR
		(@Mode = 'MG' AND (@ObjectId IS NULL OR D.MarketGroupId = @ObjectId))
	)
	
	UNION
	
	SELECT 
		  CAST(NULL AS INT) AS FdpVolumeDataItemId
		, S.FdpTakeRateSummaryId
		, S.MarketId
		, CAST(NULL AS INT) AS MarketGroupId
		, S.ModelId
		, S.FdpModelId
		, CAST(NULL AS INT) AS FeatureId
		, CAST(NULL AS INT) AS FdpFeatureId
		
	FROM Fdp_VolumeHeader	AS H
	JOIN
	(
		SELECT
			  H.DocumentId
			, H.FdpVolumeHeaderId
			, S.FdpTakeRateSummaryId
		FROM 
		Fdp_VolumeHeader				AS H
		JOIN Fdp_TakeRateSummary		AS S ON	H.FdpVolumeHeaderId	= S.FdpVolumeHeaderId
		JOIN Fdp_TakeRateDataItemNote	AS N ON S.FdpTakeRateSummaryId = N.FdpTakeRateSummaryId
		GROUP BY
		  H.DocumentId
		, H.FdpVolumeHeaderId
		, S.FdpTakeRateSummaryId
	)
							AS N	ON	H.FdpVolumeHeaderId		= N.FdpVolumeHeaderId
	JOIN Fdp_TakeRateSummary	AS S	ON	N.FdpTakeRateSummaryId	= S.FdpTakeRateSummaryId
	WHERE 
	H.FdpVolumeHeaderId = @FdpVolumeHeaderId
	AND
	(@Mode = 'M' AND (@ObjectId IS NULL OR S.MarketId = @ObjectId))
	
	-- Exclusive feature groups
	
	SELECT RANK() OVER (ORDER BY F.EFGName) AS EfgId
		, F.ExclusiveFeatureGroup
		, F.FeatureCode
		, F.FeatureId
		, ISNULL(F.BrandDescription, F.SystemDescription) AS Feature
		, F.FeatureGroup
		, F.FeatureSubGroup
	FROM
	Fdp_VolumeHeader AS H
	JOIN Fdp_Feature_VW AS F ON H.DocumentId = F.DocumentId
	WHERE
	H.FdpVolumeHeaderId = @FdpVolumeHeaderId
	AND
	F.FeatureId IS NOT NULL

	-- Packs

	SELECT
		  Id AS FeatureId 
		, PackId
		, PackName
		, ISNULL(P.BrandDescription, P.SystemDescription) AS Feature
	FROM
	Fdp_VolumeHeader_VW AS H
	JOIN OXO_Pack_Feature_VW AS P ON H.ProgrammeId = P.ProgrammeId
	WHERE
	H.FdpVolumeHeaderId = @FdpVolumeHeaderId

	-- Multi-mapped features

	SELECT 
		  MappedFeatureCode
		, ImportFeatureCode
		, FeatureDescription AS [Description]
	FROM
	Fdp_ImportFeatureDescription
	WHERE
	FdpVolumeHeaderId = @FdpVolumeHeaderId;