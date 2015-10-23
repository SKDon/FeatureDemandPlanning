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
	DECLARE @MarketGroupId		INT;
	DECLARE @FdpOxoDocId		INT;
	DECLARE @FilteredVolume		INT;
	DECLARE @ModelTotals		NVARCHAR(MAX) = N'';

	CREATE TABLE #FeatureByMarket
	(
		  Display_Order			INT				NULL
		, FeatureGroup			NVARCHAR(200)	NULL
		, FeatureSubGroup		NVARCHAR(200)	NULL
		, Feature_Code			NVARCHAR(20)	NULL
		, BrandDescription		NVARCHAR(2000)	NULL
		, Feature_Id			INT
		, FeatureComment		NVARCHAR(4000)	NULL
		, SystemDescription		NVARCHAR(200)	NULL
		, RuleCount				INT
		, LongDescription		NVARCHAR(MAX)	NULL
		, Volume				INT
		, PercentageTakeRate	DECIMAL(4, 2)
		, OXO_Code				NVARCHAR(100)	NULL
		, Model_Id				INT
	);
	CREATE TABLE #OXO_Code
	(
		  Feature_Id INT NULL
		, Pack_Id INT NULL
		, Model_Id INT NULL
		, OXO_Code NVARCHAR(100) NULL
	);
	CREATE TABLE #Volume_Data
	(
		  Feature_Id INT NULL
		, Pack_Id INT NULL
		, Model_Id INT NULL
		, Trim_Id INT NULL
		, Volume INT NULL
		, PercentageTakeRate DECIMAL(5,2)
	);
	CREATE TABLE #Model
	(
		Model_Id INT PRIMARY KEY
	)
	
	INSERT INTO #Model
	SELECT Model_Id FROM dbo.FN_SPLIT_MODEL_IDS(@ModelIds);
	
	SELECT TOP 1 @ProgrammeId = Programme_Id FROM OXO_Doc WHERE Id = @OxoDocId;
	SELECT TOP 1 @FdpOxoDocId = FdpOxoDocId FROM Fdp_OxoDoc WHERE OXODocId = @OxoDocId ORDER BY FdpOxoDocId DESC;
  
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
		INSERT INTO #Volume_Data
		SELECT * FROM dbo.fn_Fdp_OxoVolumeData_Get_MarketGroup2(@OxoDocId, @MarketGroupId, @ModelIds);
		
		INSERT INTO #OXO_CODE 
		SELECT * FROM dbo.FN_OXO_Data_Get_FBM_MarketGroup(@OxoDocId, @MarketGroupId, @ModelIds)
	END
	ELSE
	BEGIN
		INSERT INTO #Volume_Data
		SELECT * FROM dbo.fn_Fdp_OxoVolumeData_Get_Market2(@OxoDocId, @MarketGroupId, @ObjectId, @ModelIds);
		
		INSERT INTO #OXO_CODE 
		SELECT * FROM dbo.FN_OXO_Data_Get_FBM_Market(@OxoDocId, @MarketGroupId, @ObjectId, @ModelIds)
	END
	
	CREATE NONCLUSTERED INDEX Ix_TmpVolume_Data_Code ON #Volume_Data
	(
		Feature_Id, Volume, PercentageTakeRate
	);
	CREATE CLUSTERED INDEX Ix_TmpOXO_Code ON #OXO_Code
	(
		Feature_Id, Model_Id
	);
	
	;WITH Feature AS 
	(
		SELECT 
			  Id			AS Feature_Id
			, ProgrammeId
			, FeatureGroup
			, DisplayOrder 
		FROM OXO_Programme_Feature_VW
		WHERE 
		ProgrammeId = @ProgrammeId
		
		UNION
		
		SELECT NULL
			, @ProgrammeId
			, 'VOLUME BY DERIVATIVE'
			, -1
	)
	,FeatureGroup AS
	(
		SELECT 
			  -1000 AS Feature_Id
			, @ProgrammeId AS ProgrammeId
			, Group_Name AS FeatureGroup
			, MAX(Display_Order) AS DisplayOrder
		FROM 
		OXO_Feature_Group G
		LEFT JOIN Feature AS F ON G.Group_Name = F.FeatureGroup 
		WHERE 
		G.[Status] = 1
		AND
		F.Feature_Id IS NULL
		GROUP BY
		G.Group_Name
		
		UNION
		
		SELECT 
			  Feature_Id
			, ProgrammeId
			, FeatureGroup
			, DisplayOrder 
		FROM
		Feature
	)
	, FeatureByMarket AS
	(
		SELECT 
			  FEA.Feature_Id
			, FEA.DisplayOrder						AS Display_Order
			, FEA.FeatureGroup	 
			, O.Model_Id 
			, D.Volume
			, D.PercentageTakeRate
			, O.OXO_Code
		FROM FeatureGroup		AS FEA
		LEFT JOIN #OXO_Code		AS O	ON		FEA.Feature_Id		= O.Feature_Id
		LEFT JOIN #Volume_Data	AS D	ON		FEA.Feature_Id		= D.Feature_Id
										AND		O.Model_Id			= D.Model_Id																				 
		WHERE 
		FEA.ProgrammeId = @ProgrammeId
		AND
		FEA.Feature_Id IS NOT NULL	
	
		UNION
		
		SELECT 
			  ISNULL(FEA.Feature_Id, -1)			AS Feature_Id
			, FEA.DisplayOrder						AS Display_Order
			, FEA.FeatureGroup	 
			, D.Model_Id 
			, D.Volume
			, D.PercentageTakeRate
			, D.OXO_Code
		FROM FeatureGroup AS FEA
		OUTER APPLY
		(
			SELECT Volume, PercentageTakeRate, Model_Id, NULL AS OXO_Code
			FROM #Volume_Data
			WHERE
			Feature_Id IS NULL
		)
		AS D
		WHERE
		FEA.ProgrammeId = @ProgrammeId
		AND
		FEA.Feature_Id IS NULL			
	)	
	INSERT INTO #FeatureByMarket
	(
		  Display_Order			
		, FeatureGroup			
		, FeatureSubGroup		
		, Feature_Code			
		, BrandDescription		
		, Feature_Id			
		, FeatureComment		
		, SystemDescription		
		, RuleCount				
		, LongDescription	
		, Model_Id		
		, Volume				
		, PercentageTakeRate
		, OXO_Code				
	)
	SELECT 
		  Display_Order
		, F1.FeatureGroup
		, ISNULL(FeatureSubGroup, N'')		AS FeatureSubGroup
		, ISNULL(FeatureCode, N'')			AS FeatureCode
		, ISNULL(BrandDescription, N'')		AS BrandDescription
		, Feature_Id	 
		, ISNULL(FeatureComment, N'')		AS FeatureComment
		, ISNULL(SystemDescription, N'')	AS SystemDescription
		, ISNULL(LEN(FeatureRuleText),0)	AS RuleCount
		, ISNULL(LongDescription, N'')		AS LongDescription
		, Model_Id 
		, Volume
		, PercentageTakeRate
		, OXO_Code
	FROM
	FeatureByMarket						AS F1
	LEFT JOIN OXO_Programme_Feature_VW	AS F2	ON	F1.Feature_Id	= F2.ID
												AND F2.ProgrammeId	= @ProgrammeId;

	-- If we are showing volume information, use the raw volume figures,
	-- otherwise return the percentage take rate for each feature / market
	
	SET @ModelTotals = N'';
	SELECT @ModelTotals = COALESCE(@ModelTotals + ' + ', '') + 'ISNULL([' + CAST(Model_Id AS NVARCHAR(5)) + '], 0)'
	FROM #Model
	
	IF @ShowPercentage = 0
	BEGIN
		SET @Sql =		  'SELECT DATASET.*, ' + @ModelTotals + ' AS TotalVolume '				
		SET @Sql = @Sql + 'FROM ( '
		SET @Sql = @Sql + 'SELECT RANK() OVER (ORDER BY Display_Order, Feature_Code) AS Id, Display_Order, FeatureGroup, FeatureSubGroup, Feature_Code, BrandDescription, Feature_Id, FeatureComment, '
		SET @Sql = @Sql + 'SystemDescription, RuleCount, LongDescription, Model_Id, Volume '
		SET @Sql = @Sql + 'FROM #FeatureByMarket '
		SET @Sql = @Sql + 'WHERE Feature_Id <> -1) AS S1 '
		SET @Sql = @Sql + 'PIVOT ( '
		SET @Sql = @Sql + 'SUM([Volume]) FOR Model_Id '
		SET @Sql = @Sql + 'IN (' + @ModelIds + ')) AS DATASET '
		SET @Sql = @Sql + 'ORDER BY Display_Order, Feature_Code';
	END
	ELSE
	BEGIN
		SET @Sql =		  'SELECT DATASET.*, ' + @ModelTotals + ' AS TotalPercentageTakeRate '				
		SET @Sql = @Sql + 'FROM ( '
		SET @Sql = @Sql + 'SELECT RANK() OVER (ORDER BY Display_Order, Feature_Code) AS Id, Display_Order, FeatureGroup, FeatureSubGroup, Feature_Code, BrandDescription, Feature_Id, FeatureComment, '
		SET @Sql = @Sql + 'SystemDescription, RuleCount, LongDescription, Model_Id, PercentageTakeRate '
		SET @Sql = @Sql + 'FROM #FeatureByMarket '
		SET @Sql = @Sql + 'WHERE Feature_Id <> -1) AS S2 '
		SET @Sql = @Sql + 'PIVOT ( '
		SET @Sql = @Sql + 'SUM([PercentageTakeRate]) FOR Model_Id '
		SET @Sql = @Sql + 'IN (' + @ModelIds + ')) AS DATASET '
		SET @Sql = @Sql + 'ORDER BY Display_Order, Feature_Code';			
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
	
	SELECT @FilteredVolume = SUM(ISNULL(Volume, 0)) FROM #FeatureByMarket WHERE Feature_Id = -1
	
	-- Third dataset returning volume and percentage take rate by derivative
	
	SELECT 
		  M.Model_Id
		, ISNULL(FBM.Volume, 0) AS Volume
		, CASE 
			WHEN @FilteredVolume = 0 THEN 0.0
			ELSE ISNULL(FBM.Volume, 0) / CAST(@FilteredVolume AS DECIMAL(10,0)) 
		  END 
		  AS PercentageOfFilteredVolume
	FROM #Model					AS M
	LEFT JOIN #FeatureByMarket	AS FBM ON	M.Model_Id		= FBM.Model_Id
									   AND	FBM.Feature_Id	= -1;
	
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
	
	DROP TABLE #FeatureByMarket;
	DROP TABLE #Volume_Data;
	DROP TABLE #OXO_Code;
	DROP TABLE #Model;
	
	
	