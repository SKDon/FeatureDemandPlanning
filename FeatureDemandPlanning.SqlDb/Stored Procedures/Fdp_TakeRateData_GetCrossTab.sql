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
	DECLARE @OxoModelIds		NVARCHAR(MAX) = N'';

	CREATE TABLE #RawTakeRateData
	(
		  FeatureId		INT NULL
		, FdpFeatureId	INT	NULL
		, FeaturePackId	INT NULL
		, ModelId		INT NULL
		, FdpModelId	INT NULL
		, Volume		INT NULL
		, PercentageTakeRate DECIMAL(5,4)
		, IsOrphanedData BIT
		, FdpVolumeHeaderId INT
	);
	CREATE TABLE #TakeRateDataByFeature
	(
		  DisplayOrder			INT				NULL
		, FeatureGroup			NVARCHAR(200)	NULL
		, FeatureSubGroup		NVARCHAR(200)	NULL
		, FeatureCode			NVARCHAR(20)	NULL
		, BrandDescription		NVARCHAR(2000)	NULL
		, FeatureId				INT				NULL
		, FdpFeatureId			INT				NULL
		, FeaturePackId			INT				NULL
		, FeatureComment		NVARCHAR(MAX)	NULL
		, FeatureRuleText		NVARCHAR(MAX)
		, SystemDescription		NVARCHAR(200)	NULL
		, HasRule				BIT
		, LongDescription		NVARCHAR(MAX)	NULL
		, Volume				INT
		, PercentageTakeRate	DECIMAL(5,4)
		, OxoCode				NVARCHAR(100)	NULL
		, ModelId				INT
		, FdpModelId			INT
		, StringIdentifier		NVARCHAR(10)
		, FeatureIdentifier		NVARCHAR(10)
		, S INT
		, ExclusiveFeatureGroup NVARCHAR(100)	NULL
		, IsOrphanedData		BIT
	);
	CREATE TABLE #AggregatedVolumeByFeature
	(
		  AggregatedFeatureIdentifier	NVARCHAR(10)
		, AggregatedVolume				INT
		, AggregatedPercentageTakeRate	DECIMAL(5, 4)
		, CONSTRAINT [PK_AggregatedVolumeByFeature] PRIMARY KEY CLUSTERED 
		(
			AggregatedFeatureIdentifier ASC
		)
	)
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
			, FeatureId		
			, FeaturePackId
			, Volume
			, PercentageTakeRate
			, IsOrphanedData
			, FdpVolumeHeaderId
		)
		SELECT 
			  TR.ModelId
			, TR.FeatureId
			, MAX(TR.FeaturePackId)
			, SUM(TR.Volume)
			, CASE WHEN SUM(TR.PercentageTakeRate) > 1 THEN 1 ELSE SUM(TR.PercentageTakeRate) END
			, CAST(0 AS BIT)
			, @FdpVolumeHeaderId
		FROM 
		dbo.fn_Fdp_TakeRateData_ByMarketGroup_Get(@FdpVolumeHeaderId, @MarketGroupId, @ModelIds) AS TR
		WHERE
		TR.FeatureId IS NOT NULL
		GROUP BY
		TR.ModelId, TR.FeatureId

		UNION

		SELECT 
			  TR.ModelId
			, NULL
			, TR.FeaturePackId
			, SUM(TR.Volume)
			, CASE WHEN SUM(TR.PercentageTakeRate) > 1 THEN 1 ELSE SUM(TR.PercentageTakeRate) END
			, CAST(0 AS BIT)
			, @FdpVolumeHeaderId
		FROM 
		dbo.fn_Fdp_TakeRateData_ByMarketGroup_Get(@FdpVolumeHeaderId, @MarketGroupId, @ModelIds) AS TR
		WHERE
		TR.FeatureId IS NULL
		AND
		TR.FeaturePackId IS NOT NULL
		GROUP BY
		TR.ModelId, TR.FeaturePackId
	END
	ELSE
	BEGIN
		INSERT INTO #RawTakeRateData
		(
			  ModelId
			, FeatureId		
			, FeaturePackId
			, Volume
			, PercentageTakeRate
			, IsOrphanedData
			, FdpVolumeHeaderId
		)
		SELECT 
			  TR.ModelId
			, TR.FeatureId
			, MAX(TR.FeaturePackId)
			, SUM(TR.Volume)
			, CASE WHEN SUM(TR.PercentageTakeRate) > 1 THEN 1 ELSE SUM(TR.PercentageTakeRate) END
			, CAST(0 AS BIT)
			, @FdpVolumeHeaderId 
		FROM 
		dbo.fn_Fdp_TakeRateData_ByMarket_Get(@FdpVolumeHeaderId, @ObjectId, @ModelIds) AS TR
		WHERE
		TR.FeatureId IS NOT NULL
		GROUP BY
		TR.ModelId, TR.FeatureId

		UNION

		SELECT 
			  TR.ModelId
			, NULL
			, TR.FeaturePackId
			, SUM(TR.Volume)
			, CASE WHEN SUM(TR.PercentageTakeRate) > 1 THEN 1 ELSE SUM(TR.PercentageTakeRate) END
			, CAST(0 AS BIT)
			, @FdpVolumeHeaderId 
		FROM 
		dbo.fn_Fdp_TakeRateData_ByMarket_Get(@FdpVolumeHeaderId, @ObjectId, @ModelIds) AS TR
		WHERE
		TR.FeatureId IS NULL
		AND
		TR.FeaturePackId IS NOT NULL
		GROUP BY
		TR.ModelId, TR.FeaturePackId
	END
	
	CREATE NONCLUSTERED INDEX Ix_TmpRawTakeRateData_Code ON #RawTakeRateData
	(
		FeatureId, FeaturePackId, Volume, PercentageTakeRate
	)
	
	;WITH TakeRateDataByFeature AS
	(		
		SELECT
			  CASE 
				WHEN D.FeatureId IS NOT NULL OR D.FdpFeatureId IS NOT NULL THEN OXOG.Display_Order
				WHEN D.FeatureId IS NULL AND D.FeaturePackId IS NOT NULL THEN RANK() OVER (ORDER BY FP.PackName) + 10000 
			  END
																	AS DisplayOrder
			, D.FeatureId
			, D.FdpFeatureId
			, D.FeaturePackId
			, CASE
				WHEN D.FeatureId IS NOT NULL THEN OXOF.Feat_Code
				--WHEN D.FdpFeatureId IS NOT NULL THEN FDPF.FeatureCode
				WHEN D.FeatureId IS NULL AND D.FeaturePackId IS NOT NULL THEN FP.PackFeatureCode
			  END													
																	AS FeatureCode
			, OXOG.Id							AS FeatureGroupId 
			, CASE
				WHEN D.FeatureId IS NOT NULL THEN OXOG.Group_Name
				--WHEN D.FdpFeatureId IS NOT NULL THEN FDPG.Group_Name
				WHEN D.FeatureId IS NULL AND D.FeaturePackId IS NOT NULL THEN 'OPTION PACKS'
			  END													AS FeatureGroup
			, CASE
				WHEN D.FeatureId IS NOT NULL THEN OXOG.Sub_Group_Name
				--WHEN D.FdpFeatureId IS NOT NULL THEN FDPG.Sub_Group_Name
				WHEN D.FeatureId IS NULL AND D.FeaturePackId IS NOT NULL THEN NULL
			  END													AS FeatureSubGroup
			, CASE
				WHEN D.FeatureId IS NOT NULL THEN ISNULL(OXOBD.Brand_Desc, '*' + OXOF.[Description]) 
				--WHEN D.FdpFeatureId IS NOT NULL THEN FDPF.FeatureDescription
				WHEN D.FeatureId IS NULL AND D.FeaturePackId IS NOT NULL THEN FP.PackName
			  END
																	AS BrandDescription
			, CASE
				WHEN D.FeatureId IS NOT NULL THEN OXOF.[Description] 
				--WHEN D.FdpFeatureId IS NOT NULL THEN FDPF.FeatureDescription
				WHEN D.FeatureId IS NULL AND D.FeaturePackId IS NOT NULL THEN FP.PackName
			  END
																	AS [Description]
			, OXOFL.Comment											AS FeatureComment
			, OXOFL.Rule_Text										AS FeatureRuleText
			, CASE
				WHEN D.FeatureId IS NOT NULL THEN OXOF.Long_Desc 
				--WHEN D.FdpFeatureId IS NOT NULL THEN FDPF.FeatureDescription
				WHEN D.FeatureId IS NULL AND D.FeaturePackId IS NOT NULL THEN FP.PackName
			  END
																	AS LongDescription
			, D.ModelId
			, D.FdpModelId 
			, ISNULL(D.Volume, 0)									AS Volume
			, D.PercentageTakeRate
			, CASE 
				WHEN D.FeatureId IS NOT NULL THEN FA.Applicability
				WHEN D.FdpFeatureId IS NOT NULL THEN 'NA'
				WHEN D.FeatureId IS NULL AND D.FeaturePackId IS NOT NULL THEN FA2.Applicability
			  END													AS OxoCode
			, M.StringIdentifier
			, CASE 
				WHEN D.FeatureId IS NOT NULL THEN 'O' + CAST(D.FeatureId AS NVARCHAR(10)) 
				WHEN D.FdpFeatureId IS NOT NULL THEN 'F' + CAST(D.FdpFeatureId AS NVARCHAR(10)) 
				WHEN D.FeatureId IS NULL AND D.FeaturePackId IS NOT NULL THEN 'P' + CAST(D.FeaturePackId AS NVARCHAR(10))
			  END													AS FeatureIdentifier
			, 1 AS S
			, OXOEFG.EFG_Desc		AS ExclusiveFeatureGroup
			, D.IsOrphanedData
		FROM 
		Fdp_VolumeHeader_VW						AS H
		JOIN OXO_Programme_VW					AS P		ON	H.ProgrammeId		= P.Id
		JOIN #RawTakeRateData					AS D		ON	H.FdpVolumeHeaderId = D.FdpVolumeHeaderId
		JOIN #Model								AS M		ON	D.ModelId = M.ModelId
															
		-- Join on the feature tables without reference to the programme information as we may have data for uncoded features
		-- and need to at least return basic feature information
		LEFT JOIN OXO_Feature_Ext				AS OXOF		ON	D.FeatureId		= OXOF.Id
		LEFT JOIN OXO_Feature_Group				AS OXOG		ON	OXOF.OXO_Grp	= OXOG.Id
		LEFT JOIN OXO_Feature_Brand_Desc		AS OXOBD	ON	OXOF.Feat_Code	= OXOBD.Feat_Code
															AND P.VehicleMake	= OXOBD.Brand
		LEFT JOIN OXO_Exclusive_Feature_Group	AS OXOEFG	ON	OXOF.Feat_EFG	= OXOEFG.EFG_Code
		LEFT JOIN OXO_Programme_Feature_Link	AS OXOFL	ON	D.FeatureId		= OXOFL.Feature_Id
															AND H.ProgrammeId	= OXOFL.Programme_Id
															
		-- Feature packs, can't use OXO_Programme_Pack as we may have orphaned packs not associated with a programme
		LEFT JOIN
		(
			SELECT 
			  PackId
			, MAX(P.PackFeatureCode) AS PackFeatureCode
			, MAX(P.PackName) AS PackName
			FROM
			OXO_Pack_Feature_VW AS P
			GROUP BY
			P.PackId
		)										AS FP		ON	D.FeatureId		IS NULL
															AND D.FeaturePackId	= FP.PackId													
															
		-- Feature applicability only applies to OXO models and features
		LEFT JOIN Fdp_FeatureApplicability		AS FA		ON	H.DocumentId	= FA.DocumentId
															AND FA.MarketId		= @ObjectId
															AND D.FeatureId		= FA.FeatureId
															AND	D.ModelId		= FA.ModelId

		LEFT JOIN Fdp_FeatureApplicability		AS FA2		ON	H.DocumentId	= FA2.DocumentId
															AND FA2.MarketId	= @ObjectId
															AND	D.ModelId		= FA2.ModelId
															AND D.FeatureId		IS NULL
															AND D.FeaturePackId	= FA2.FeaturePackId											
		WHERE
		H.FdpVolumeHeaderId = @FdpVolumeHeaderId
		AND 
		(
			@Filter IS NULL 
			OR 
			OXOF.Feat_Code LIKE '%' + @Filter + '%' 
			OR 
			OXOF.[Description] LIKE '%' + @Filter + '%'
			OR 
			OXOBD.Brand_Desc LIKE '%' + @Filter + '%'
			OR
			OXOEFG.EFG_Desc LIKE '%' + @Filter + '%'
		)
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
		, FeaturePackId
		, FeatureComment
		, FeatureRuleText
		, SystemDescription
		, HasRule
		, LongDescription
		, Volume	
		, PercentageTakeRate
		, OxoCode		
		, ModelId
		, FdpModelId
		, StringIdentifier
		, FeatureIdentifier	
		, S
		, ExclusiveFeatureGroup
		, IsOrphanedData
	)
	SELECT 
		  F.DisplayOrder
		, F.FeatureGroup
		, F.FeatureSubGroup
		, F.FeatureCode
		, F.BrandDescription
		, F.FeatureId
		, F.FdpFeatureId
		, F.FeaturePackId	 
		, F.FeatureComment
		, F.FeatureRuleText
		, F.[Description]
		, CAST(CASE WHEN LEN(F.FeatureRuleText) > 0 THEN 1 ELSE 0 END AS BIT)
		, F.LongDescription
		, ISNULL(F.Volume, 0)
		, F.PercentageTakeRate
		, F.OxoCode
		, F.ModelId
		, F.FdpModelId 
		, F.StringIdentifier
		, F.FeatureIdentifier
		, F.S
		, F.ExclusiveFeatureGroup
		, F.IsOrphanedData
	FROM
	TakeRateDataByFeature				AS F 
	ORDER BY
	F.DisplayOrder, F.BrandDescription 
	
	CREATE NONCLUSTERED INDEX Ix_NC_TmpTakeRateDataByFeature ON #TakeRateDataByFeature
	(
		  FeatureId
		, FeaturePackId
		, ModelId
		, StringIdentifier
		, FeatureIdentifier
		, FeatureCode
	) 
	
	INSERT INTO #AggregatedVolumeByFeature
	(
		  AggregatedFeatureIdentifier
		, AggregatedVolume
		, AggregatedPercentageTakeRate
	)
	SELECT 'O' + CAST(M.FeatureId AS NVARCHAR(10)), M.Volume, M.PercentageTakeRate 
	FROM 
	Fdp_TakeRateFeatureMix AS M
	WHERE
	M.FdpVolumeHeaderId = @FdpVolumeHeaderId
	AND
	(
		@Mode = 'MG'
		OR
		(
			@Mode <> 'MG'
			AND
			M.MarketId = @ObjectId
		)
	)
	AND
	M.FeatureId IS NOT NULL

	UNION

	SELECT 'P' + CAST(M.FeaturePackId AS NVARCHAR(10)), M.Volume, M.PercentageTakeRate 
	FROM 
	Fdp_TakeRateFeatureMix AS M
	WHERE
	M.FdpVolumeHeaderId = @FdpVolumeHeaderId
	AND
	(
		(
			@Mode = 'MG'
			AND
			M.MarketId IS NULL
		)
		OR
		(
			@Mode <> 'MG'
			AND
			M.MarketId = @ObjectId
		)
	)
	AND
	M.FeatureId IS NULL
	AND
	M.FeaturePackId IS NOT NULL
	
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

		IF ISNULL(@TotalVolume, 0) = 0
		BEGIN
			SELECT @FilteredPercentage = 0
		END
		ELSE
		BEGIN
			SELECT @FilteredPercentage = @FilteredVolume / CAST(@TotalVolume AS DECIMAL(10,4));
		END
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
	
	IF @ShowPercentage = 0
	BEGIN
		SET @Sql =		  'SELECT DATASET.*, AggregatedVolume AS TotalVolume '				
		SET @Sql = @Sql + 'FROM ( '
		SET @Sql = @Sql + 'SELECT RANK() OVER (ORDER BY DisplayOrder, FeatureCode, FeatureIdentifier) AS Id, DisplayOrder, FeatureIdentifier, FeatureGroup, FeatureSubGroup, FeatureCode, BrandDescription, FeatureComment, FeatureRuleText, ExclusiveFeatureGroup, StringIdentifier, '
		SET @Sql = @Sql + 'SystemDescription, HasRule, LongDescription, FeaturePackId, IsOrphanedData, ISNULL(Volume, 0) AS Volume '
		SET @Sql = @Sql + 'FROM #TakeRateDataByFeature) AS S1 '
		SET @Sql = @Sql + 'LEFT JOIN #AggregatedVolumeByFeature AS F ON S1.FeatureIdentifier = F.AggregatedFeatureIdentifier '
		SET @Sql = @Sql + 'PIVOT ( '
		SET @Sql = @Sql + 'SUM([Volume]) FOR StringIdentifier '
		SET @Sql = @Sql + 'IN (' + @ModelIds + ')) AS DATASET '
		SET @Sql = @Sql + 'ORDER BY DisplayOrder, FeatureCode';
	END
	ELSE
	BEGIN
		--SET @Sql =		  'SELECT DATASET.*, dbo.fn_Fdp_PercentageTakeRate_Get(AggregatedVolume, ' + CAST(ISNULL(@FilteredVolume, 0) AS NVARCHAR(10)) + ') AS TotalPercentageTakeRate '
		SET @Sql =		  'SELECT DATASET.*, AggregatedPercentageTakeRate AS TotalPercentageTakeRate '
		SET @Sql = @Sql + 'FROM ( '
		SET @Sql = @Sql + '  SELECT RANK() OVER (ORDER BY DisplayOrder, FeatureCode, FeatureIdentifier) AS Id, DisplayOrder, FeatureIdentifier, FeatureGroup, FeatureSubGroup, FeatureCode, BrandDescription, FeatureComment, FeatureRuleText, ExclusiveFeatureGroup, StringIdentifier, '
		SET @Sql = @Sql + '  SystemDescription, HasRule, LongDescription, FeaturePackId, IsOrphanedData, PercentageTakeRate '
		SET @Sql = @Sql + '  FROM #TakeRateDataByFeature '
		SET @Sql = @Sql + ') AS S2 '
		SET @Sql = @Sql + 'LEFT JOIN #AggregatedVolumeByFeature AS F ON S2.FeatureIdentifier = F.AggregatedFeatureIdentifier '
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
	SET @Sql = @Sql + 'SystemDescription, HasRule, LongDescription, FeaturePackId, IsOrphanedData, OXOCode '
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
	
	-- Exclusive feature groups
	
	SELECT RANK() OVER (ORDER BY F.EFGName) AS EfgId
		, F.EFGName AS ExclusiveFeatureGroup
		, F.FeatureCode
		, F.ID AS FeatureId
		, ISNULL(F.BrandDescription, F.SystemDescription) AS Feature
		, F.FeatureGroup
		, F.FeatureSubGroup
	FROM
	Fdp_VolumeHeader AS H
	JOIN OXO_Doc	AS D ON H.DocumentId = D.Id
	JOIN OXO_Programme_Feature_VW AS F ON D.Programme_Id = F.ProgrammeId
	WHERE
	H.FdpVolumeHeaderId = @FdpVolumeHeaderId
	AND
	F.EFGName IS NOT NULL

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
	
	-- Tidy up
	
	DROP TABLE #TakeRateDataByFeature;
	DROP TABLE #RawTakeRateData;
	DROP TABLE #Model;