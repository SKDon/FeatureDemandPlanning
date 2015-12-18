CREATE PROCEDURE [dbo].[Fdp_TakeRateData_GetCrossTab] 
    @OxoDocId		INT
  , @Mode			NVARCHAR(2)
  , @ObjectId		INT = NULL
  , @ModelIds		NVARCHAR(MAX)
  , @ShowPercentage	BIT = 0
  , @IsExport		BIT = 0
  , @Filter			NVARCHAR(100) = NULL
AS
	SET NOCOUNT ON;

	DECLARE @Sql				NVARCHAR(MAX) = N'';
	DECLARE @ProgrammeId		INT; 
	DECLARE @Gateway			NVARCHAR(100);   	
	DECLARE @MarketGroupId		INT;
	DECLARE @FdpOxoDocId		INT;
	DECLARE @FilteredVolume		INT;
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
		, FeatureComment		NVARCHAR(4000)	NULL
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
	
	SELECT TOP 1 
		  @ProgrammeId	= Programme_Id
		, @Gateway		= Gateway
	FROM OXO_Doc WHERE Id = @OxoDocId;
  
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
		dbo.fn_Fdp_TakeRateData_ByMarketGroup_Get(@OxoDocId, @MarketGroupId, @ModelIds) AS TR;
		
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
			, Pack_Id
			, Model_Id
			, OXO_Code
			, 'O' + CAST(Model_Id AS NVARCHAR(10))
		FROM dbo.FN_OXO_Data_Get_FBM_MarketGroup(@OxoDocId, @MarketGroupId, @OxoModelIds)
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
		dbo.fn_Fdp_TakeRateData_ByMarket_Get(@OxoDocId, @ObjectId, @ModelIds) AS TR;
		
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
			, Pack_Id
			, Model_Id
			, OXO_Code
			, 'O' + CAST(Model_Id AS NVARCHAR(10))
		FROM dbo.FN_OXO_Data_Get_FBM_Market(@OxoDocId, @MarketGroupId, @ObjectId, @OxoModelIds)
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
		JOIN #FeatureApplicability		AS O	ON		D.FeatureId		= O.FeatureId
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
			, 1 AS S
			  
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
			, 2 AS S
			  
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
			, 3 AS S
			  
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
	Fdp_TakeRateSummaryByModelAndMarket_VW AS S
	WHERE
	ProgrammeId = @ProgrammeId
	AND
	Gateway = @Gateway
	
	SELECT @FilteredVolume = SUM(S.TotalVolume)
	FROM
	Fdp_TakeRateSummaryByModelAndMarket_VW AS S
	JOIN #Model AS M ON S.ModelId = M.ModelId
					 AND M.IsFdpModel = 0
	WHERE
	S.ProgrammeId = @ProgrammeId
	AND
	S.Gateway = @Gateway
	AND
	(
		(@Mode = 'M' AND (@ObjectId IS NULL OR S.MarketId = @ObjectId))
		OR
		(@Mode = 'MG' AND (@MarketGroupId IS NULL OR S.MarketGroupId = @MarketGroupId))
	)
	
	SELECT @FilteredVolume = @FilteredVolume + SUM(S.TotalVolume)
	FROM
	Fdp_TakeRateSummaryByModelAndMarket_VW AS S
	JOIN #Model AS M ON S.FdpModelId = M.ModelId
					 AND M.IsFdpModel = 1
	WHERE
	ProgrammeId = @ProgrammeId
	AND
	Gateway = @Gateway
	AND
	(
		(@Mode = 'M' AND (@ObjectId IS NULL OR S.MarketId = @ObjectId))
		OR
		(@Mode = 'MG' AND (@ObjectId IS NULL OR S.MarketGroupId = @ObjectId))
	)

	-- If we are showing volume information, use the raw volume figures,
	-- otherwise return the percentage take rate for each feature / market
	
	SET @ModelTotals = N'';
	SELECT @ModelTotals = COALESCE(@ModelTotals + ' + ', '') + 'ISNULL([' + StringIdentifier + '], 0)'
	FROM #Model;
	
	IF @ShowPercentage = 0
	BEGIN
		SET @Sql =		  'SELECT DATASET.*, ' + @ModelTotals + ' AS TotalVolume '				
		SET @Sql = @Sql + 'FROM ( '
		SET @Sql = @Sql + 'SELECT RANK() OVER (ORDER BY DisplayOrder, FeatureCode, FeatureIdentifier) AS Id, DisplayOrder, FeatureIdentifier, FeatureGroup, FeatureSubGroup, FeatureCode, BrandDescription, FeatureComment, StringIdentifier, '
		SET @Sql = @Sql + 'SystemDescription, HasRule, LongDescription, ISNULL(Volume, 0) AS Volume '
		SET @Sql = @Sql + 'FROM #TakeRateDataByFeature) AS S1 '
		SET @Sql = @Sql + 'PIVOT ( '
		SET @Sql = @Sql + 'SUM([Volume]) FOR StringIdentifier '
		SET @Sql = @Sql + 'IN (' + @ModelIds + ')) AS DATASET '
		SET @Sql = @Sql + 'ORDER BY DisplayOrder, FeatureCode';
	END
	ELSE
	BEGIN
		SET @Sql =		  'SELECT DATASET.*, ISNULL(AggregatedVolume, 0) / CAST(' + CAST(@FilteredVolume AS NVARCHAR(10)) + ' AS DECIMAL) AS TotalPercentageTakeRate '
		SET @Sql = @Sql + 'FROM ( '
		SET @Sql = @Sql + 'SELECT RANK() OVER (ORDER BY DisplayOrder, FeatureCode, FeatureIdentifier) AS Id, DisplayOrder, FeatureIdentifier, FeatureGroup, FeatureSubGroup, FeatureCode, BrandDescription, FeatureComment, StringIdentifier, '
		SET @Sql = @Sql + 'SystemDescription, HasRule, LongDescription, PercentageTakeRate '
		SET @Sql = @Sql + 'FROM #TakeRateDataByFeature) AS S2 '
		SET @Sql = @Sql + 'LEFT JOIN #AggregateVolumeByFeature AS F ON S2.FeatureIdentifier = F.AggregatedFeatureIdentifier '
		SET @Sql = @Sql + 'PIVOT ( '
		SET @Sql = @Sql + 'SUM([PercentageTakeRate]) FOR StringIdentifier '
		SET @Sql = @Sql + 'IN (' + @ModelIds + ')) AS DATASET '
		SET @Sql = @Sql + 'ORDER BY DisplayOrder, FeatureCode';			
	END

	PRINT @Sql;
	EXEC sp_executesql @Sql;
	
	-- For the second dataset, return the OXO Code to determine the feature applicability
	-- Unfortunately we can't easily combine into the first dataset due to the fact that we are pivoting on different columns
	
	SET @Sql =		  'SELECT DATASET.* '				
	SET @Sql = @Sql + 'FROM ( '
	SET @Sql = @Sql + 'SELECT RANK() OVER (ORDER BY DisplayOrder, FeatureCode, FeatureIdentifier) AS Id, DisplayOrder, FeatureIdentifier, FeatureGroup, FeatureSubGroup, FeatureCode, BrandDescription, FeatureComment, StringIdentifier, '
	SET @Sql = @Sql + 'SystemDescription, HasRule, LongDescription, OXOCode '
	SET @Sql = @Sql + 'FROM #TakeRateDataByFeature) AS S3 '
	SET @Sql = @Sql + 'PIVOT ( '
	SET @Sql = @Sql + 'MAX([OXOCode]) FOR StringIdentifier '
	SET @Sql = @Sql + 'IN (' + @ModelIds + ')) AS DATASET '
	SET @Sql = @Sql + 'ORDER BY DisplayOrder, FeatureCode';

	PRINT @Sql;
	EXEC sp_executesql @Sql;
	
	-- Third dataset returning volume and percentage take rate by derivative
	-- Calculate the total volumes for the whole unfiltered dataset and the filtered dataset

	SELECT 
		  M.StringIdentifier
		, M.IsFdpModel
		, SUM(S.TotalVolume) AS Volume
		, SUM(S.TotalVolume) / CAST(@FilteredVolume AS DECIMAL) AS PercentageOfFilteredVolume
	FROM
	Fdp_TakeRateSummaryByModelAndMarket_VW AS S
	JOIN #Model AS M ON S.ModelId = M.ModelId
					 AND M.IsFdpModel = 0
	WHERE
	ProgrammeId = @ProgrammeId
	AND
	Gateway = @Gateway
	AND
	(
		(@Mode = 'M' AND (@ObjectId IS NULL OR S.MarketId = @ObjectId))
		OR
		(@Mode = 'MG' AND (@ObjectId IS NULL OR S.MarketGroupId = @ObjectId))
	)
	GROUP BY
	M.StringIdentifier, M.IsFdpModel

	UNION

	SELECT 
		  M.StringIdentifier
		, M.IsFdpModel
		, SUM(S.TotalVolume) AS Volume
		, SUM(S.TotalVolume) / CAST(@FilteredVolume AS DECIMAL) AS PercentageOfFilteredVolume
	FROM
	Fdp_TakeRateSummaryByModelAndMarket_VW AS S
	JOIN #Model AS M ON S.FdpModelId = M.ModelId
					 AND M.IsFdpModel = 1
	WHERE
	ProgrammeId = @ProgrammeId
	AND
	Gateway = @Gateway
	AND
	(
		(@Mode = 'M' AND (@ObjectId IS NULL OR S.MarketId = @ObjectId))
		OR
		(@Mode = 'MG' AND (@ObjectId IS NULL OR S.MarketGroupId = @ObjectId))
	)
	GROUP BY
	M.StringIdentifier, M.IsFdpModel
	
	---- Summary dataset returning the meta information for the data (created by, updated, total volume mix, volume for market, etc)
	
	SELECT TOP 1
		  ISNULL(@TotalVolume, 0)				AS TotalVolume
		, ISNULL(@FilteredVolume, 0)			AS FilteredVolume
		, ISNULL(CASE 
			WHEN ISNULL(@TotalVolume, 0) = 0 THEN 0.0
			ELSE @FilteredVolume / CAST(@TotalVolume AS DECIMAL)
		  END, 0.0) 
									AS PercentageOfTotalVolume
		, H.CreatedBy
		, H.CreatedOn
		
	FROM
	Fdp_VolumeHeader AS H
	WHERE
	H.DocumentId = @OxoDocId;
	
	DROP TABLE #TakeRateDataByFeature;
	DROP TABLE #RawTakeRateData;
	DROP TABLE #FeatureApplicability;
	DROP TABLE #Model;