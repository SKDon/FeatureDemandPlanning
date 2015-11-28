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
		, FeatureComment		NVARCHAR(4000)	NULL
		, SystemDescription		NVARCHAR(200)	NULL
		, RuleCount				INT
		, LongDescription		NVARCHAR(MAX)	NULL
		, Volume				INT
		, PercentageTakeRate	DECIMAL(4, 2)
		, OxoCode				NVARCHAR(100)	NULL
		, ModelId				INT
		, FdpModelId			INT
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
	
	IF @Mode = 'MG'
	BEGIN
		INSERT INTO #RawTakeRateData
		SELECT * FROM dbo.fn_Fdp_TakeRateData_ByMarketGroup_Get(@OxoDocId, @MarketGroupId, @ModelIds);
		
		INSERT INTO #FeatureApplicability 
		SELECT * FROM dbo.FN_OXO_Data_Get_FBM_MarketGroup(@OxoDocId, @MarketGroupId, @ModelIds)
	END
	ELSE
	BEGIN
		INSERT INTO #RawTakeRateData
		SELECT * FROM dbo.fn_Fdp_TakeRateData_ByMarket_Get(@OxoDocId, @ObjectId, @ModelIds);
		
		INSERT INTO #FeatureApplicability 
		SELECT * FROM dbo.FN_OXO_Data_Get_FBM_Market(@OxoDocId, @MarketGroupId, @ObjectId, @ModelIds)
	END
	
	CREATE NONCLUSTERED INDEX Ix_TmpRawTakeRateData_Code ON #RawTakeRateData
	(
		FeatureId, Volume, PercentageTakeRate
	);
	CREATE CLUSTERED INDEX Ix_TmpFeatureApplicability ON #FeatureApplicability
	(
		FeatureId, ModelId
	);
	
	WITH Feature AS 
	(
		SELECT 
			  Id			AS FeatureId
			, FdpFeatureId
			, ProgrammeId
			, Gateway
			, FeatureGroup
			, DisplayOrder 
		FROM Fdp_Feature_VW
		WHERE 
		ProgrammeId = @ProgrammeId
		AND
		Gateway = @Gateway
		
		UNION
		
		SELECT
			  CAST(NULL	AS INT) AS FeatureId
			, CAST(NULL	AS INT) AS FdpFeatureId
			, @ProgrammeId
			, @Gateway
			, 'VOLUME BY DERIVATIVE'
			, -1
	)
	,FeatureGroup AS
	(
		-- Groups with no features
		
		SELECT 
			  -1000 AS FeatureId
			, -1000 AS FdpFeatureId
			, @ProgrammeId			AS ProgrammeId
			, @Gateway				AS Gateway
			, Group_Name			AS FeatureGroup
			, MAX(Display_Order)	AS DisplayOrder
		FROM 
		OXO_Feature_Group AS G
		LEFT JOIN Feature AS F ON G.Group_Name = F.FeatureGroup
		WHERE 
		G.[Status] = 1
		AND
		F.FeatureId IS NULL
		AND
		F.FdpFeatureId IS NULL
		GROUP BY
		G.Group_Name
		
		UNION
		
		-- Groups with features
		
		SELECT 
			  FeatureId
			, FdpFeatureId
			, ProgrammeId
			, Gateway
			, FeatureGroup
			, DisplayOrder 
		FROM
		Feature
	)
	, TakeRateDataByFeature AS
	(
		-- OXO coded features / models where we have applicability and can therefore work out the percentages
		
		SELECT 
			  FEA.FeatureId
			, FEA.DisplayOrder
			, FEA.FeatureGroup	 
			, O.ModelId 
			, D.Volume
			, D.PercentageTakeRate
			, O.OxoCode
		FROM FeatureGroup				AS FEA
		LEFT JOIN #FeatureApplicability	AS O	ON		FEA.FeatureId		= O.FeatureId
		LEFT JOIN #RawTakeRateData		AS D	ON		FEA.FeatureId		= D.FeatureId
												AND		O.ModelId			= D.ModelId																				 
		WHERE 
		FEA.ProgrammeId = @ProgrammeId
		AND
		FEA.Gateway = @Gateway
		AND
		FEA.FeatureId IS NOT NULL	
	
		--UNION
		
		---- Features where we have take rate information, but no applicability has been coded
		
		--SELECT 
		--	  ISNULL(FEA.FeatureId, -1)	AS FeatureId
		--	, FEA.DisplayOrder
		--	, FEA.FeatureGroup	 
		--	, D.ModelId 
		--	, D.Volume
		--	, D.PercentageTakeRate
		--	, NULL AS OxoCode
		--FROM FeatureGroup AS FEA
		--OUTER APPLY
		--(
		--	SELECT Volume, PercentageTakeRate, ModelId
		--	FROM #RawTakeRateData
		--	WHERE
		--	FeatureId IS NULL
		--)
		--AS D
		--WHERE
		--FEA.ProgrammeId = @ProgrammeId
		--AND
		--FEA.Gateway = @Gateway
		--AND
		--FEA.FeatureId IS NULL			
	)	
	INSERT INTO #TakeRateDataByFeature
	(
		  DisplayOrder			
		, FeatureGroup			
		, FeatureSubGroup		
		, FeatureCode			
		, BrandDescription		
		, FeatureId			
		, FeatureComment		
		, SystemDescription		
		, RuleCount				
		, LongDescription	
		, ModelId		
		, Volume				
		, PercentageTakeRate
		, OxoCode				
	)
	SELECT 
		  F1.DisplayOrder
		, F1.FeatureGroup
		, ISNULL(FeatureSubGroup, N'')		AS FeatureSubGroup
		, ISNULL(FeatureCode, N'')			AS FeatureCode
		, ISNULL(BrandDescription, N'')		AS BrandDescription
		, FeatureId	 
		, ISNULL(FeatureComment, N'')		AS FeatureComment
		, ISNULL(SystemDescription, N'')	AS SystemDescription
		, ISNULL(LEN(FeatureRuleText),0)	AS RuleCount
		, ISNULL(LongDescription, N'')		AS LongDescription
		, ModelId 
		, Volume
		, PercentageTakeRate
		, OxoCode
	FROM
	TakeRateDataByFeature				AS F1
	LEFT JOIN OXO_Programme_Feature_VW	AS F2	ON	F1.FeatureId	= F2.ID
												AND F2.ProgrammeId	= @ProgrammeId;

	-- If we are showing volume information, use the raw volume figures,
	-- otherwise return the percentage take rate for each feature / market
	
	SET @ModelTotals = N'';
	SELECT @ModelTotals = COALESCE(@ModelTotals + ' + ', '') + 'ISNULL([' + StringIdentifier + '], 0)'
	FROM #Model
	WHERE
	IsFdpModel = 0;
	
	SELECT @ModelTotals
	
	IF @ShowPercentage = 0
	BEGIN
		SET @Sql =		  'SELECT DATASET.*, ' + @ModelTotals + ' AS TotalVolume '				
		SET @Sql = @Sql + 'FROM ( '
		SET @Sql = @Sql + 'SELECT RANK() OVER (ORDER BY DisplayOrder, FeatureCode) AS Id, DisplayOrder, FeatureGroup, FeatureSubGroup, FeatureCode, BrandDescription, FeatureId, FeatureComment, '
		SET @Sql = @Sql + 'SystemDescription, RuleCount, LongDescription, ModelId, Volume '
		SET @Sql = @Sql + 'FROM #FeatureByMarket '
		SET @Sql = @Sql + 'WHERE FeatureId <> -1) AS S1 '
		SET @Sql = @Sql + 'PIVOT ( '
		SET @Sql = @Sql + 'SUM([Volume]) FOR ModelId '
		SET @Sql = @Sql + 'IN (' + @ModelIds + ')) AS DATASET '
		SET @Sql = @Sql + 'ORDER BY DisplayOrder, FeatureCode';
	END
	ELSE
	BEGIN
		SET @Sql =		  'SELECT DATASET.*, ' + @ModelTotals + ' AS TotalPercentageTakeRate '				
		SET @Sql = @Sql + 'FROM ( '
		SET @Sql = @Sql + 'SELECT RANK() OVER (ORDER BY DisplayOrder, FeatureCode) AS Id, DisplayOrder, FeatureGroup, FeatureSubGroup, FeatureCode, BrandDescription, FeatureId, FeatureComment, '
		SET @Sql = @Sql + 'SystemDescription, RuleCount, LongDescription, ModelId, PercentageTakeRate '
		SET @Sql = @Sql + 'FROM #FeatureByMarket '
		SET @Sql = @Sql + 'WHERE FeatureId <> -1) AS S2 '
		SET @Sql = @Sql + 'PIVOT ( '
		SET @Sql = @Sql + 'SUM([PercentageTakeRate]) FOR ModelId '
		SET @Sql = @Sql + 'IN (' + @ModelIds + ')) AS DATASET '
		SET @Sql = @Sql + 'ORDER BY DisplayOrder, FeatureCode';			
	END

	PRINT @Sql;
	EXEC sp_executesql @Sql;
	
	-- For the second dataset, return the OXO Code to determine the feature applicability
	-- Unfortunately we can't easily combine into the first dataset due to the fact that we are pivoting on different columns
	
	SET @Sql =		  'SELECT DATASET.* '				
	SET @Sql = @Sql + 'FROM ( '
	SET @Sql = @Sql + 'SELECT RANK() OVER (ORDER BY Display_Order, Feature_Code) AS Id, Display_Order, FeatureGroup, FeatureSubGroup, Feature_Code, BrandDescription, Feature_Id, FeatureComment, '
	SET @Sql = @Sql + 'SystemDescription, RuleCount, LongDescription, Model_Id, OXO_Code '
	SET @Sql = @Sql + 'FROM #FeatureByMarket '
	SET @Sql = @Sql + 'WHERE Feature_Id <> -1) AS S3 '
	SET @Sql = @Sql + 'PIVOT ( '
	SET @Sql = @Sql + 'MAX([OXO_Code]) FOR Model_Id '
	SET @Sql = @Sql + 'IN (' + @ModelIds + ')) AS DATASET '
	SET @Sql = @Sql + 'ORDER BY Display_Order, Feature_Code';

	PRINT @Sql;
	EXEC sp_executesql @Sql;
	
	SELECT @FilteredVolume = SUM(ISNULL(Volume, 0)) FROM #TakeRateDataByFeature WHERE FeatureId = -1
	
	-- Third dataset returning volume and percentage take rate by derivative
	
	SELECT 
		  M.ModelId
		, M.IsFdpModel
		, ISNULL(FBM.Volume, 0) AS Volume
		, CASE 
			WHEN @FilteredVolume = 0 THEN 0.0
			ELSE ISNULL(FBM.Volume, 0) / CAST(@FilteredVolume AS DECIMAL(10,0)) 
		  END 
		  AS PercentageOfFilteredVolume
	FROM #Model					AS M
	LEFT JOIN #TakeRateDataByFeature	AS FBM ON	M.ModelId		= FBM.ModelId
									   AND	FBM.FeatureId	= -1;
	
	-- Summary dataset returning the meta information for the data (created by, updated, total volume mix, volume for market, etc)
	
	SELECT TOP 1
		  ISNULL(V.TotalVolume, 0)	AS TotalVolume
		, @FilteredVolume			AS FilteredVolume
		, CASE 
			WHEN ISNULL(V.TotalVolume, 0) = 0 THEN 0.0
			ELSE @FilteredVolume / CAST(V.TotalVolume AS DECIMAL(10,0))
		  END 
									AS PercentageOfTotalVolume
		, D.CreatedBy
		, D.CreatedOn
		
	FROM
	OXO_Doc						AS D1		
	LEFT JOIN	Fdp_OxoDoc		AS D	ON	D1.Id = D.OXODocId
	LEFT JOIN	Fdp_OxoVolume	AS V ON D.FdpOxoDocId = V.FdpOxoDocId
	WHERE
	D.FdpOxoDocId = @FdpOxoDocId;
	
	DROP TABLE #TakeRateDataByFeature;
	DROP TABLE #RawTakeRateData;
	DROP TABLE #FeatureApplicability;
	DROP TABLE #Model;
	
	
	