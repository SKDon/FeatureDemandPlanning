CREATE PROCEDURE [dbo].[Fdp_OxoVolumeDataItem_GetCrossTab] 
    @OxoDocId		INT
  , @Mode			NVARCHAR(2)
  , @ObjectId		INT = NULL
  , @ModelIds		NVARCHAR(MAX)
  , @ShowPercentage	BIT = 0
  , @IsExport		BIT = 0
AS
	SET NOCOUNT ON;

	DECLARE @Sql				NVARCHAR(MAX) = N'';
	DECLARE @ProgrammeId		INT; 
	DECLARE @Gateway			NVARCHAR(100);   	
	DECLARE @MarketGroupId		INT;
	DECLARE @FdpOxoDocId		INT;
	DECLARE @FilteredVolume		INT;
	DECLARE @ModelTotals		NVARCHAR(MAX) = N'';
	DECLARE @OxoModelIds		NVARCHAR(MAX) = N'';

	CREATE TABLE #FeatureApplicability
	(
		  FeatureId		INT				NULL
		, PackId		INT				NULL
		, ModelId		INT				NULL
		, OxoCode		NVARCHAR(100)	NULL
	);
	CREATE TABLE #RawTakeRateData
	(
		  FeatureId		INT NULL
		, FdpFeatureId	INT	NULL
		, PackId		INT NULL
		, ModelId		INT NULL
		, FdpModelId	INT NULL
		, Volume		INT NULL
		, PercentageTakeRate DECIMAL(5,2)
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
		, RuleCount				INT
		, LongDescription		NVARCHAR(MAX)	NULL
		, Volume				INT
		, PercentageTakeRate	DECIMAL(4, 2)
		, OxoCode				NVARCHAR(100)	NULL
		, ModelId				INT
		, FdpModelId			INT
		, StringIdentifier		NVARCHAR(10)
		, Ix					INT
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
	
	SELECT TOP 1 @FdpOxoDocId = FdpOxoDocId 
	FROM Fdp_OxoDoc 
	WHERE 
	OXODocId = @OxoDocId 
	ORDER BY 
	FdpOxoDocId DESC;
  
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
		SELECT * FROM dbo.FN_OXO_Data_Get_FBM_MarketGroup(@OxoDocId, @MarketGroupId, @OxoModelIds)
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
		SELECT * FROM dbo.FN_OXO_Data_Get_FBM_Market(@OxoDocId, @MarketGroupId, @ObjectId, @OxoModelIds)
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
			, D.ModelId
			, CAST(NULL AS INT) AS FdpModelId 
			, ISNULL(D.Volume, 0) AS Volume
			, D.PercentageTakeRate
			, NULL AS OxoCode --O.OxoCode
			, M.StringIdentifier
			, 1 AS IX
			  
		FROM Fdp_FeatureMapping_VW		AS FEA
		LEFT JOIN #RawTakeRateData		AS D	ON		FEA.FeatureId	= D.FeatureId
		LEFT JOIN #FeatureApplicability	AS O	ON		D.FeatureId		= O.FeatureId
												AND		D.ModelId		= O.ModelId
		JOIN #Model						AS M	ON		D.ModelId		= M.ModelId
												AND		M.IsFdpModel = 0
		WHERE 
		FEA.ProgrammeId = @ProgrammeId
		AND
		FEA.Gateway = @Gateway	
		
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
			, CAST(NULL AS INT) AS ModelId
			, D.FdpModelId 
			, ISNULL(D.Volume, 0) AS Volume
			, D.PercentageTakeRate
			, CAST(NULL AS NVARCHAR(10)) AS OxoCode
			, M.StringIdentifier
			, 2 AS IX
			  
		FROM Fdp_FeatureMapping_VW		AS FEA
		LEFT JOIN #RawTakeRateData		AS D	ON		FEA.FeatureId	= D.FeatureId
		LEFT JOIN #Model				AS M	ON		D.FdpModelId	= M.ModelId
												AND		M.IsFdpModel = 1
		WHERE 
		FEA.ProgrammeId = @ProgrammeId
		AND
		FEA.Gateway = @Gateway
		
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
			, CAST(NULL AS INT) AS ModelId
			, D.FdpModelId 
			, ISNULL(D.Volume, 0) AS Volume
			, D.PercentageTakeRate
			, CAST(NULL AS NVARCHAR(10)) AS OxoCode
			, M.StringIdentifier
			, 3 AS IX
			  
		FROM Fdp_FeatureMapping_VW		AS FEA
		LEFT JOIN #RawTakeRateData		AS D	ON		FEA.FdpFeatureId	= D.FdpFeatureId
		LEFT JOIN #Model				AS M	ON		D.FdpModelId		= M.ModelId
												AND		M.IsFdpModel		= 1
		WHERE 
		FEA.ProgrammeId = @ProgrammeId
		AND
		FEA.Gateway = @Gateway
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
		--, FeatureComment		
		, SystemDescription		
		--, RuleCount				
		--, LongDescription	
		, ModelId
		, FdpModelId		
		, Volume				
		, PercentageTakeRate
		, OxoCode
		, StringIdentifier	
		, Ix			
	)
	SELECT 
		  F.DisplayOrder
		, F.FeatureGroup
		, F.FeatureSubGroup
		, F.FeatureCode
		, F.BrandDescription		AS BrandDescription
		, F.FeatureId
		, F.FdpFeatureId	 
		--, ISNULL(FeatureComment, N'')		AS FeatureComment
		, F.[Description]					AS SystemDescription
		--, ISNULL(LEN(FeatureRuleText),0)	AS RuleCount
		--, ISNULL(LongDescription, N'')		AS LongDescription
		, F.ModelId
		, F.FdpModelId 
		, ISNULL(F.Volume, 0) AS Volume
		, F.PercentageTakeRate
		, F.OxoCode
		, F.StringIdentifier
		, F.IX
	FROM
	TakeRateDataByFeature				AS F 
	
	SELECT * FROM #TakeRateDataByFeature

	-- If we are showing volume information, use the raw volume figures,
	-- otherwise return the percentage take rate for each feature / market
	
	SET @ModelTotals = N'';
	SELECT @ModelTotals = COALESCE(@ModelTotals + ' + ', '') + 'ISNULL([' + StringIdentifier + '], 0)'
	FROM #Model;
	
	IF @ShowPercentage = 0
	BEGIN
		SET @Sql =		  'SELECT DATASET.*, ' + @ModelTotals + ' AS TotalVolume '
		--SET @Sql = 'SELECT DATASET.* '				
		SET @Sql = @Sql + 'FROM ( '
		SET @Sql = @Sql + 'SELECT RANK() OVER (ORDER BY DisplayOrder, FeatureCode) AS Id, DisplayOrder, FeatureGroup, FeatureSubGroup, FeatureCode, BrandDescription, FeatureComment, StringIdentifier, '
		SET @Sql = @Sql + 'SystemDescription, RuleCount, LongDescription, ISNULL(Volume, 0) AS Volume '
		SET @Sql = @Sql + 'FROM #TakeRateDataByFeature) AS S1 '
		SET @Sql = @Sql + 'PIVOT ( '
		SET @Sql = @Sql + 'SUM([Volume]) FOR StringIdentifier '
		SET @Sql = @Sql + 'IN (' + @ModelIds + ')) AS DATASET '
		SET @Sql = @Sql + 'ORDER BY DisplayOrder, FeatureCode';
	END
	ELSE
	BEGIN
		--SET @Sql =		  'SELECT DATASET.*, ' + @ModelTotals + ' AS TotalPercentageTakeRate '
		SET @Sql = 'SELECT DATASET.* '					
		SET @Sql = @Sql + 'FROM ( '
		SET @Sql = @Sql + 'SELECT RANK() OVER (ORDER BY DisplayOrder, FeatureCode) AS Id, DisplayOrder, FeatureGroup, FeatureSubGroup, FeatureCode, BrandDescription, FeatureComment, StringIdentifier, '
		SET @Sql = @Sql + 'SystemDescription, RuleCount, LongDescription, PercentageTakeRate '
		SET @Sql = @Sql + 'FROM #TakeRateDataByFeature) AS S2 '
		SET @Sql = @Sql + 'PIVOT ( '
		SET @Sql = @Sql + 'SUM([PercentageTakeRate]) FOR StringIdentifier '
		SET @Sql = @Sql + 'IN (' + @ModelIds + ')) AS DATASET '
		SET @Sql = @Sql + 'ORDER BY DisplayOrder, FeatureCode';			
	END

	PRINT @Sql;
	EXEC sp_executesql @Sql;
	
	---- For the second dataset, return the OXO Code to determine the feature applicability
	---- Unfortunately we can't easily combine into the first dataset due to the fact that we are pivoting on different columns
	
	--SET @Sql =		  'SELECT DATASET.* '				
	--SET @Sql = @Sql + 'FROM ( '
	--SET @Sql = @Sql + 'SELECT RANK() OVER (ORDER BY Display_Order, Feature_Code) AS Id, Display_Order, FeatureGroup, FeatureSubGroup, Feature_Code, BrandDescription, Feature_Id, FeatureComment, '
	--SET @Sql = @Sql + 'SystemDescription, RuleCount, LongDescription, Model_Id, OXO_Code '
	--SET @Sql = @Sql + 'FROM #FeatureByMarket '
	--SET @Sql = @Sql + 'WHERE Feature_Id <> -1) AS S3 '
	--SET @Sql = @Sql + 'PIVOT ( '
	--SET @Sql = @Sql + 'MAX([OXO_Code]) FOR Model_Id '
	--SET @Sql = @Sql + 'IN (' + @ModelIds + ')) AS DATASET '
	--SET @Sql = @Sql + 'ORDER BY Display_Order, Feature_Code';

	--PRINT @Sql;
	--EXEC sp_executesql @Sql;
	
	--SELECT @FilteredVolume = SUM(ISNULL(Volume, 0)) FROM #TakeRateDataByFeature WHERE FeatureId = -1
	
	---- Third dataset returning volume and percentage take rate by derivative
	
	--SELECT 
	--	  M.ModelId
	--	, M.IsFdpModel
	--	, ISNULL(FBM.Volume, 0) AS Volume
	--	, CASE 
	--		WHEN @FilteredVolume = 0 THEN 0.0
	--		ELSE ISNULL(FBM.Volume, 0) / CAST(@FilteredVolume AS DECIMAL(10,0)) 
	--	  END 
	--	  AS PercentageOfFilteredVolume
	--FROM #Model					AS M
	--LEFT JOIN #TakeRateDataByFeature	AS FBM ON	M.ModelId		= FBM.ModelId
	--								   AND	FBM.FeatureId	= -1;
	
	---- Summary dataset returning the meta information for the data (created by, updated, total volume mix, volume for market, etc)
	
	--SELECT TOP 1
	--	  ISNULL(V.TotalVolume, 0)	AS TotalVolume
	--	, @FilteredVolume			AS FilteredVolume
	--	, CASE 
	--		WHEN ISNULL(V.TotalVolume, 0) = 0 THEN 0.0
	--		ELSE @FilteredVolume / CAST(V.TotalVolume AS DECIMAL(10,0))
	--	  END 
	--								AS PercentageOfTotalVolume
	--	, D.CreatedBy
	--	, D.CreatedOn
		
	--FROM
	--OXO_Doc						AS D1		
	--LEFT JOIN	Fdp_OxoDoc		AS D	ON	D1.Id = D.OXODocId
	--LEFT JOIN	Fdp_OxoVolume	AS V ON D.FdpOxoDocId = V.FdpOxoDocId
	--WHERE
	--D.FdpOxoDocId = @FdpOxoDocId;
	
	DROP TABLE #TakeRateDataByFeature;
	DROP TABLE #RawTakeRateData;
	DROP TABLE #FeatureApplicability;
	DROP TABLE #Model;
	
	
	