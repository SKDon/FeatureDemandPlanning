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
	DECLARE @ModelTotals		NVARCHAR(MAX) = N'';
	DECLARE @OxoModelIds		NVARCHAR(MAX) = N'';

	CREATE TABLE #FeatureApplicability
	(
		  FeatureId			INT				NULL
		, PackId			INT				NULL
		, ModelId			INT				NULL
		, OxoCode			NVARCHAR(100)	NULL
		, StringIdentifier	NVARCHAR(10)	NULL
	);
	CREATE TABLE #RawTakeRateData
	(
		  FeatureId		INT NULL
		, FdpFeatureId	INT	NULL
		, PackId		INT NULL
		, ModelId		INT NULL
		, FdpModelId	INT NULL
		, Volume		INT NULL
		, PercentageTakeRate DECIMAL(8,2)
	);
	CREATE TABLE #TakeRateDataByFeature
	(
		  DisplayOrder			INT				NULL
		, FeatureGroup			NVARCHAR(200)	NULL
		, FeatureSubGroup		NVARCHAR(200)	NULL
		, FeatureCode			NVARCHAR(20)	NULL
		, BrandDescription		NVARCHAR(2000)	NULL
		, FeatureId				INT
		, FdpFeatureId			INT
		, FeatureComment		NVARCHAR(MAX)	NULL
		, FeatureRuleText		NVARCHAR(MAX)
		, SystemDescription		NVARCHAR(200)	NULL
		, HasRule				BIT
		, LongDescription		NVARCHAR(MAX)	NULL
		, Volume				INT
		, PercentageTakeRate	DECIMAL(8,2)
		, OxoCode				NVARCHAR(100)	NULL
		, ModelId				INT
		, FdpModelId			INT
		, StringIdentifier		NVARCHAR(10)
		, FeatureIdentifier		NVARCHAR(10)
		, S INT
	);
	CREATE TABLE #AggregateVolumeByFeature
	(
		  AggregatedFeatureIdentifier	NVARCHAR(10)
		, AggregatedVolume				INT
	);
	CREATE TABLE #Model
	(
		  ModelId		INT PRIMARY KEY
		, StringIdentifier NVARCHAR(10)
		, IsFdpModel	BIT
	)
	INSERT INTO #Model
	(
		  ModelId
		, StringIdentifier
		, IsFdpModel
	)
	SELECT ModelId, StringIdentifier, IsFdpModel 
	FROM dbo.fn_Fdp_SplitModelIds(@ModelIds);

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
		  @ProgrammeId	= Programme_Id
		, @Gateway		= Gateway
	FROM 
	Fdp_VolumeHeader AS H
	JOIN OXO_Doc AS D ON H.DocumentId = D.Id
	WHERE 
	H.FdpVolumeHeaderId = @FdpVolumeHeaderId;
  
	SELECT TOP 1 @MarketGroupId = Market_Group_Id 
	FROM 
	OXO_Programme_MarketGroupMarket_VW
	WHERE
	(
		(@Mode = 'M' AND Market_Id = @ObjectId)
		OR
		(@Mode = 'MG' AND Market_Group_Id = @ObjectId)
	)
	AND
	Programme_Id = @ProgrammeId
	AND
	@ObjectId IS NOT NULL;
	
	-- Parse the list of model ids to return only the OXO model ids
	-- FDP models have no feature applicability coded so cannot be used
	
	SELECT @OxoModelIds = COALESCE(@OxoModelIds + ',' ,'') + CAST(ModelId AS NVARCHAR(10))
	FROM #Model
	WHERE IsFdpModel = 0
	
	IF @Mode = 'MG'
	BEGIN
		INSERT INTO #RawTakeRateData
		(
			  ModelId
			, FdpModelId
			, FeatureId		
			, FdpFeatureId
			, PackId
			, Volume
			, PercentageTakeRate
		)
		SELECT 
			  TR.ModelId
			, TR.FdpModelId
			, TR.FeatureId
			, TR.FdpFeatureId
			, TR.PackId
			, TR.Volume
			, TR.PercentageTakeRate 
		FROM 
		dbo.fn_Fdp_TakeRateData_ByMarketGroup_Get(@FdpVolumeHeaderId, @MarketGroupId, @ModelIds) AS TR;
		
		INSERT INTO #FeatureApplicability
		(
			  FeatureId		
			, PackId		
			, ModelId		
			, OxoCode		
			, StringIdentifier
		) 
		SELECT 
			  Feature_Id
			, NULL
			, Model_Id
			, OXO_Code
			, 'O' + CAST(Model_Id AS NVARCHAR(10))
		FROM dbo.FN_OXO_Data_Get_FBM_MarketGroup(@DocumentId, @MarketGroupId, @OxoModelIds)
	END
	ELSE
	BEGIN
		INSERT INTO #RawTakeRateData
		(
			  ModelId
			, FdpModelId
			, FeatureId		
			, FdpFeatureId
			, PackId
			, Volume
			, PercentageTakeRate
		)
		SELECT 
			  TR.ModelId
			, TR.FdpModelId
			, TR.FeatureId
			, TR.FdpFeatureId
			, TR.PackId
			, TR.Volume
			, TR.PercentageTakeRate 
		FROM 
		dbo.fn_Fdp_TakeRateData_ByMarket_Get(@FdpVolumeHeaderId, @ObjectId, @ModelIds) AS TR;
		
		INSERT INTO #FeatureApplicability
		(
			  FeatureId		
			, PackId		
			, ModelId		
			, OxoCode		
			, StringIdentifier
		) 
		SELECT 
			  Feature_Id
			, NULL
			, Model_Id
			, OXO_Code
			, 'O' + CAST(Model_Id AS NVARCHAR(10))
		FROM 
		dbo.FN_OXO_Data_Get_FBM_Market(@DocumentId, @MarketGroupId, @ObjectId, @OxoModelIds)
	END
	
	CREATE NONCLUSTERED INDEX Ix_TmpRawTakeRateData_Code ON #RawTakeRateData
	(
		FeatureId, Volume, PercentageTakeRate
	);
	CREATE CLUSTERED INDEX Ix_TmpFeatureApplicability ON #FeatureApplicability
	(
		FeatureId, ModelId
	);
	
	;WITH TakeRateDataByFeature AS
	(		
		SELECT 
			  FEA.DisplayOrder
			, FEA.FeatureId
			, FEA.FdpFeatureId
			, FEA.MappedFeatureCode AS FeatureCode
			, FEA.FeatureGroupId 
			, FEA.FeatureGroup	
			, FEA.FeatureSubGroup
			, FEA.BrandDescription
			, FEA.[Description]
			, FEA.FeatureComment
			, FEA.FeatureRuleText
			, FEA.LongDescription
			, D.ModelId
			, CAST(NULL AS INT) AS FdpModelId 
			, ISNULL(D.Volume, 0) AS Volume
			, D.PercentageTakeRate
			, O.OxoCode
			, M.StringIdentifier
			, 'O' + CAST(FEA.FeatureId AS NVARCHAR(10)) AS FeatureIdentifier
			, 1 AS S
			  
		FROM Fdp_FeatureMapping_VW		AS FEA
		JOIN #RawTakeRateData			AS D	ON		FEA.FeatureId	= D.FeatureId
		LEFT JOIN #FeatureApplicability		AS O	ON		D.FeatureId		= O.FeatureId
												AND		D.ModelId		= O.ModelId
		JOIN #Model						AS M	ON		D.ModelId		= M.ModelId
												AND		M.IsFdpModel	= 0
		WHERE 
		FEA.ProgrammeId = @ProgrammeId
		AND
		FEA.Gateway = @Gateway
		AND
		(@Filter IS NULL OR FEA.MappedFeatureCode LIKE '%' + @Filter + '%' OR FEA.BrandDescription LIKE '%' + @Filter + '%')
		
		UNION
		
		SELECT 
			  FEA.DisplayOrder
			, FEA.FeatureId
			, FEA.FdpFeatureId
			, FEA.MappedFeatureCode AS FeatureCode
			, FEA.FeatureGroupId 
			, FEA.FeatureGroup	
			, FEA.FeatureSubGroup
			, FEA.BrandDescription
			, FEA.[Description]
			, FEA.FeatureComment
			, FEA.FeatureRuleText
			, FEA.LongDescription
			, D.ModelId
			, CAST(NULL AS INT) AS FdpModelId 
			, ISNULL(D.Volume, 0) AS Volume
			, D.PercentageTakeRate
			, CAST(NULL AS NVARCHAR(10)) AS OxoCode
			, M.StringIdentifier
			, 'F' + CAST(FEA.FdpFeatureId AS NVARCHAR(10)) AS FeatureIdentifier
			, 2 AS S
			  
		FROM Fdp_FeatureMapping_VW		AS FEA
		JOIN #RawTakeRateData			AS D	ON		FEA.FdpFeatureId	= D.FdpFeatureId
		JOIN #Model						AS M	ON		D.ModelId			= M.ModelId
												AND		M.IsFdpModel		= 0
		WHERE 
		FEA.ProgrammeId = @ProgrammeId
		AND
		FEA.Gateway = @Gateway
		AND
		(@Filter IS NULL OR FEA.MappedFeatureCode LIKE '%' + @Filter + '%' OR FEA.BrandDescription LIKE '%' + @Filter + '%')
		
		UNION
		
		SELECT 
			  FEA.DisplayOrder
			, FEA.FeatureId
			, CAST(NULL AS INT) AS FdpFeatureId
			, FEA.MappedFeatureCode AS FeatureCode
			, FEA.FeatureGroupId 
			, FEA.FeatureGroup	
			, FEA.FeatureSubGroup
			, FEA.BrandDescription
			, FEA.[Description]
			, FEA.FeatureComment
			, FEA.FeatureRuleText
			, FEA.LongDescription
			, CAST(NULL AS INT) AS ModelId
			, D.FdpModelId 
			, ISNULL(D.Volume, 0) AS Volume
			, D.PercentageTakeRate
			, CAST(NULL AS NVARCHAR(10)) AS OxoCode
			, M.StringIdentifier
			, CASE
				WHEN FEA.FeatureId IS NOT NULL THEN 'O' + CAST(FEA.FeatureId AS NVARCHAR(10))
				ELSE 'F' + CAST(FEA.FdpFeatureId AS NVARCHAR(10))
			  END
			  AS FeatureIdentifier
			, 3 AS S
			  
		FROM Fdp_FeatureMapping_VW	AS FEA
		JOIN #RawTakeRateData		AS D	ON		FEA.FeatureId	= D.FeatureId
		JOIN #Model					AS M	ON		D.FdpModelId	= M.ModelId
											AND		M.IsFdpModel = 1
		WHERE 
		FEA.ProgrammeId = @ProgrammeId
		AND
		FEA.Gateway = @Gateway
		AND
		(@Filter IS NULL OR FEA.MappedFeatureCode LIKE '%' + @Filter + '%' OR FEA.BrandDescription LIKE '%' + @Filter + '%')
		
		UNION
		
		SELECT 
			  FEA.DisplayOrder
			, CAST(NULL AS INT) AS FeatureId
			, FEA.FdpFeatureId
			, FEA.MappedFeatureCode AS FeatureCode
			, FEA.FeatureGroupId 
			, FEA.FeatureGroup	
			, FEA.FeatureSubGroup
			, FEA.BrandDescription
			, FEA.[Description]
			, FEA.FeatureComment
			, FEA.FeatureRuleText
			, FEA.LongDescription
			, CAST(NULL AS INT) AS ModelId
			, D.FdpModelId 
			, ISNULL(D.Volume, 0) AS Volume
			, D.PercentageTakeRate
			, CAST(NULL AS NVARCHAR(10)) AS OxoCode
			, M.StringIdentifier
			, CASE
				WHEN FEA.FeatureId IS NOT NULL THEN 'O' + CAST(FEA.FeatureId AS NVARCHAR(10))
				ELSE 'F' + CAST(FEA.FdpFeatureId AS NVARCHAR(10))
			  END
			  AS FeatureIdentifier
			, 4 AS S
			  
		FROM Fdp_FeatureMapping_VW	AS FEA
		JOIN #RawTakeRateData		AS D	ON	FEA.FdpFeatureId	= D.FdpFeatureId
		JOIN #Model					AS M	ON	D.FdpModelId		= M.ModelId
											AND	M.IsFdpModel		= 1
		WHERE 
		FEA.ProgrammeId = @ProgrammeId
		AND
		FEA.Gateway = @Gateway
		AND
		(@Filter IS NULL OR FEA.MappedFeatureCode LIKE '%' + @Filter + '%' OR FEA.BrandDescription LIKE '%' + @Filter + '%')
		
		--UNION
		
		--SELECT 
		--	  FEA.DisplayOrder
		--	, FEA.FeatureId
		--	, FEA.FdpFeatureId
		--	, FEA.MappedFeatureCode AS FeatureCode
		--	, FEA.FeatureGroupId 
		--	, FEA.FeatureGroup	
		--	, FEA.FeatureSubGroup
		--	, FEA.BrandDescription
		--	, FEA.[Description]
		--	, FEA.FeatureComment
		--	, FEA.FeatureRuleText
		--	, FEA.LongDescription
		--	, CAST(NULL AS INT) AS ModelId
		--	, CAST(NULL AS INT) FdpModelId 
		--	, 0 AS Volume
		--	, 0 AS PercentageTakeRate
		--	, CAST(NULL AS NVARCHAR(10)) AS OxoCode
		--	, CAST(NULL AS NVARCHAR(10)) AS StringIdentifier
		--	, CASE
		--		WHEN FEA.FeatureId IS NOT NULL THEN 'O' + CAST(FEA.FeatureId AS NVARCHAR(10))
		--		ELSE 'F' + CAST(FEA.FdpFeatureId AS NVARCHAR(10))
		--	  END
		--	  AS FeatureIdentifier
		--	, 4 AS S
			  
		--FROM Fdp_FeatureMapping_VW		AS FEA
		--WHERE
		--FEA.ProgrammeId = @ProgrammeId
		--AND
		--FEA.Gateway = @Gateway
		--AND
		--(@Filter IS NULL OR FEA.MappedFeatureCode LIKE '%' + @Filter + '%' OR FEA.BrandDescription LIKE '%' + @Filter + '%')
	)	
	INSERT INTO #TakeRateDataByFeature
	(
		  DisplayOrder			
		, FeatureGroup			
		, FeatureSubGroup		
		, FeatureCode			
		, BrandDescription		
		, FeatureId
		, FdpFeatureId			
		, FeatureComment
		, FeatureRuleText		
		, SystemDescription		
		, HasRule				
		, LongDescription	
		, ModelId
		, FdpModelId		
		, Volume				
		, PercentageTakeRate
		, OxoCode
		, StringIdentifier	
		, FeatureIdentifier
		, S			
	)
	SELECT 
		  F.DisplayOrder
		, F.FeatureGroup
		, F.FeatureSubGroup
		, F.FeatureCode
		, F.BrandDescription
		, F.FeatureId
		, F.FdpFeatureId	 
		, F.FeatureComment
		, F.FeatureRuleText
		, F.[Description]
		, CAST(CASE WHEN LEN(F.FeatureRuleText) > 0 THEN 1 ELSE 0 END AS BIT)
		, F.LongDescription
		, F.ModelId
		, F.FdpModelId 
		, ISNULL(F.Volume, 0)
		, F.PercentageTakeRate
		, F.OxoCode
		, F.StringIdentifier
		, F.FeatureIdentifier
		, F.S
	FROM
	TakeRateDataByFeature				AS F 
	
	INSERT INTO #AggregateVolumeByFeature
	(
		  AggregatedFeatureIdentifier
		, AggregatedVolume
	)
	SELECT FeatureIdentifier, SUM(ISNULL(Volume, 0)) FROM #TakeRateDataByFeature AS T
	WHERE
	(
		(T.ModelId IS NOT NULL AND T.FdpModelId IS NULL)
		OR
		(T.FdpModelId IS NOT NULL AND T.ModelId IS NULL)
	)
	AND
	(@Filter IS NULL OR T.FeatureCode LIKE '%' + @Filter + '%')
	GROUP BY 
	FeatureIdentifier
	
	-- Work out total volumes so we can calculate percentage take from the feature mix
	
	SELECT @TotalVolume = SUM(S.TotalVolume)
	FROM
	Fdp_TakeRateSummaryByMarket_VW AS S
	WHERE
	FdpVolumeHeaderId = @FdpVolumeHeaderId

	IF @Mode = 'MG'
	BEGIN
		SELECT @FilteredVolume = SUM(TotalVolume)
		FROM Fdp_TakeRateSummaryByMarket_VW
		WHERE
		FdpVolumeHeaderId = @FdpVolumeHeaderId
		AND
		(@MarketGroupId IS NULL OR MarketGroupId = @MarketGroupId);

		SELECT @FilteredPercentage = @FilteredVolume / CAST(@TotalVolume AS DECIMAL);
	END
	ELSE
	BEGIN
		SELECT @FilteredVolume = TotalVolume, @FilteredPercentage = PercentageTakeRate
		FROM Fdp_TakeRateSummaryByMarket_VW
		WHERE
		FdpVolumeHeaderId = @FdpVolumeHeaderId
		AND
		MarketId = @ObjectId;
	END
	
	-- If we are showing volume information, use the raw volume figures,
	-- otherwise return the percentage take rate for each feature / market
	
	SET @ModelTotals = N'';
	SELECT @ModelTotals = COALESCE(@ModelTotals + ' + ', '') + 'ISNULL([' + StringIdentifier + '], 0)'
	FROM #Model;
	
	IF @ShowPercentage = 0
	BEGIN
		SET @Sql =		  'SELECT DATASET.*, ' + @ModelTotals + ' AS TotalVolume '				
		SET @Sql = @Sql + 'FROM ( '
		SET @Sql = @Sql + 'SELECT RANK() OVER (ORDER BY DisplayOrder, FeatureCode, FeatureIdentifier) AS Id, DisplayOrder, FeatureIdentifier, FeatureGroup, FeatureSubGroup, FeatureCode, BrandDescription, FeatureComment, FeatureRuleText, StringIdentifier, '
		SET @Sql = @Sql + 'SystemDescription, HasRule, LongDescription, ISNULL(Volume, 0) AS Volume '
		SET @Sql = @Sql + 'FROM #TakeRateDataByFeature) AS S1 '
		SET @Sql = @Sql + 'PIVOT ( '
		SET @Sql = @Sql + 'SUM([Volume]) FOR StringIdentifier '
		SET @Sql = @Sql + 'IN (' + @ModelIds + ')) AS DATASET '
		SET @Sql = @Sql + 'ORDER BY DisplayOrder, FeatureCode';
	END
	ELSE
	BEGIN
		SET @Sql =		  'SELECT DATASET.*, dbo.fn_Fdp_PercentageTakeRate_Get(AggregatedVolume, ' + CAST(@FilteredVolume AS NVARCHAR(10)) + ') AS TotalPercentageTakeRate '
		SET @Sql = @Sql + 'FROM ( '
		SET @Sql = @Sql + 'SELECT RANK() OVER (ORDER BY DisplayOrder, FeatureCode, FeatureIdentifier) AS Id, DisplayOrder, FeatureIdentifier, FeatureGroup, FeatureSubGroup, FeatureCode, BrandDescription, FeatureComment, FeatureRuleText, StringIdentifier, '
		SET @Sql = @Sql + 'SystemDescription, HasRule, LongDescription, PercentageTakeRate '
		SET @Sql = @Sql + 'FROM #TakeRateDataByFeature) AS S2 '
		SET @Sql = @Sql + 'LEFT JOIN #AggregateVolumeByFeature AS F ON S2.FeatureIdentifier = F.AggregatedFeatureIdentifier '
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
	SET @Sql = @Sql + 'SELECT RANK() OVER (ORDER BY DisplayOrder, FeatureCode, FeatureIdentifier) AS Id, DisplayOrder, FeatureIdentifier, FeatureGroup, FeatureSubGroup, FeatureCode, BrandDescription, FeatureComment, FeatureRuleText, StringIdentifier, '
	SET @Sql = @Sql + 'SystemDescription, HasRule, LongDescription, OXOCode '
	SET @Sql = @Sql + 'FROM #TakeRateDataByFeature) AS S3 '
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
		JOIN #Model AS M ON S.ModelId = M.ModelId
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
		JOIN #Model AS M ON S.FdpModelId = M.ModelId
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
		JOIN #Model AS M ON S.ModelId = M.ModelId
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
		JOIN #Model AS M ON S.FdpModelId = M.ModelId
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
	
	-- Tidy up
	
	DROP TABLE #TakeRateDataByFeature;
	DROP TABLE #RawTakeRateData;
	DROP TABLE #FeatureApplicability;
	DROP TABLE #Model;