CREATE PROCEDURE [dbo].[Fdp_PivotData_Update]
	  @FdpVolumeHeaderId AS INT
	, @MarketId AS INT
	, @ModelIds AS NVARCHAR(MAX)
	, @FdpPivotHeaderId AS INT OUTPUT
AS
	SET NOCOUNT ON;

	SELECT TOP 1 @FdpPivotHeaderId = FdpPivotHeaderId 
	FROM Fdp_PivotHeader 
	WHERE 
	FdpVolumeHeaderId = @FdpVolumeHeaderId
	AND
	(
		(@MarketId IS NULL AND MarketId IS NULL)
		OR
		(@MarketId IS NOT NULL AND MarketId = @MarketId)
	)
	AND
	ModelIds = @ModelIds;

	IF @FdpPivotHeaderId IS NOT NULL
	BEGIN
		DELETE FROM Fdp_PivotData WHERE FdpPivotHeaderId = @FdpPivotHeaderId;
		DELETE FROM Fdp_PivotHeader WHERE FdpPivotHeaderId = @FdpPivotHeaderId;
	END

	INSERT INTO Fdp_PivotHeader
	(
		  FdpVolumeHeaderId
		, MarketId
		, ModelIds
	)
	VALUES
	(
		  @FdpVolumeHeaderId
		, @MarketId
		, @ModelIds
	)

	SET @FdpPivotHeaderId = SCOPE_IDENTITY();

	INSERT INTO Fdp_RawModel
	(
		  ModelId
		, IsFdpModel
	)
	SELECT M.ModelId, M.IsFdpModel
	FROM dbo.fn_Fdp_SplitModelIds(@ModelIds) AS M
	LEFT JOIN Fdp_RawModel AS CUR ON M.ModelId = CUR.ModelId
	WHERE CUR.ModelId IS NULL

	DECLARE @ProcessId AS UNIQUEIDENTIFIER = NEWID();

	IF @MarketId IS NULL
	BEGIN
		INSERT INTO Fdp_RawTakeRateData
		(
			  ProcessId
			, ModelId
			, FeatureId		
			, FeaturePackId
			, Volume
			, PercentageTakeRate
			, IsOrphanedData
			, FdpVolumeHeaderId
		)
		SELECT 
			  @ProcessId
			, TR.ModelId
			, TR.FeatureId
			, TR.FeaturePackId
			, SUM(TR.Volume)
			, CASE WHEN SUM(TR.PercentageTakeRate) > 1 THEN 1 ELSE SUM(TR.PercentageTakeRate) END
			, CAST(0 AS BIT)
			, @FdpVolumeHeaderId
		FROM 
		dbo.fn_Fdp_TakeRateData_ByMarketGroup_Get(@FdpVolumeHeaderId, NULL, @ModelIds) AS TR
		WHERE
		TR.FeatureId IS NOT NULL
		GROUP BY
		TR.ModelId, TR.FeatureId, TR.FeaturePackId
	END
	ELSE
	BEGIN
		INSERT INTO Fdp_RawTakeRateData
		(
			  ProcessId
			, ModelId
			, FeatureId		
			, FeaturePackId
			, Volume
			, PercentageTakeRate
			, IsOrphanedData
			, FdpVolumeHeaderId
		)
		SELECT
			  @ProcessId 
			, TR.ModelId
			, TR.FeatureId
			, TR.FeaturePackId
			, TR.Volume
			, TR.PercentageTakeRate
			, CAST(0 AS BIT)
			, @FdpVolumeHeaderId 
		FROM 
		dbo.fn_Fdp_TakeRateData_ByMarket_Get(@FdpVolumeHeaderId, @MarketId, @ModelIds) AS TR
	END
	
	;WITH TakeRateDataByFeature AS
	(		
		SELECT
			  F.DisplayOrder
			, D.FeatureId
			, D.FeaturePackId
			, F.FeatureCode
			, F.FeatureGroupId 
			, F.FeatureGroup
			, F.FeatureSubGroup
			, ISNULL(F.BrandDescription, '*' + F.SystemDescription) AS BrandDescription
			, F.SystemDescription AS [Description]
			, F.FeatureComment
			, F.FeatureRuleText
			, F.LongDescription
			, D.ModelId
			, ISNULL(D.Volume, 0)									AS Volume
			, D.PercentageTakeRate
			, FA.Applicability	AS OxoCode
			, M.ModelIdentifier										AS StringIdentifier
			, 'O' + CAST(D.FeatureId AS NVARCHAR(10))				AS FeatureIdentifier
			, F.ExclusiveFeatureGroup
			, D.IsOrphanedData
			, CAST(CASE
				WHEN IGNORE.FdpImportErrorExclusionId IS NOT NULL THEN 1
				ELSE 0
			  END AS BIT) AS IsIgnoredData 
			, CAST(CASE
				WHEN MULTI.MappedFeatureCode IS NOT NULL THEN 1
				ELSE 0
			  END AS BIT) AS IsMappedToMultipleImportFeatures
		FROM 
		Fdp_VolumeHeader_VW						AS H
		JOIN Fdp_Feature_VW						AS F		ON	H.DocumentId		= F.DocumentId
		JOIN Fdp_RawTakeRateData				AS D		ON	H.FdpVolumeHeaderId = D.FdpVolumeHeaderId	
															AND F.FeatureId			= D.FeatureId												
		JOIN Fdp_RawModel						AS M		ON	D.ModelId			= M.ModelId
																		
		-- Feature applicability only applies to OXO models and features
		LEFT JOIN Fdp_FeatureApplicability		AS FA		ON	H.DocumentId	= FA.DocumentId
															AND FA.MarketId		= @MarketId
															AND D.FeatureId		= FA.FeatureId
															AND	D.ModelId		= FA.ModelId
															
		LEFT JOIN Fdp_ImportErrorExclusion		AS IGNORE	ON	H.DocumentId	= IGNORE.DocumentId
															AND IGNORE.FdpImportErrorTypeId = 2
															AND F.FeatureCode	= IGNORE.AdditionalData

		LEFT JOIN
		(
			SELECT DocumentId, MappedFeatureCode 
			FROM Fdp_FeatureMapping_VW
			GROUP BY DocumentId, MappedFeatureCode
			HAVING COUNT(DISTINCT ImportFeatureCode) > 1
		)
												AS MULTI	ON	H.DocumentId	= MULTI.DocumentId
															AND F.FeatureCode	= MULTI.MappedFeatureCode
																				
		WHERE
		H.FdpVolumeHeaderId = @FdpVolumeHeaderId
		AND
		D.ProcessId = @ProcessId

		UNION

		SELECT
			  F.DisplayOrder + 10000 AS DisplayOrder
			, D.FeatureId
			, D.FeaturePackId
			, F.FeatureCode
			, F.FeatureGroupId 
			, 'OPTION PACKS' AS FeatureGroup
			, NULL AS FeatureSubGroup
			, F.FeaturePackName AS BrandDescription
			, F.FeaturePackName AS [Description]
			, F.FeatureComment
			, F.FeatureRuleText
			, F.FeaturePackName AS LongDescription
			, D.ModelId
			, ISNULL(D.Volume, 0)									AS Volume
			, D.PercentageTakeRate
			, FA2.Applicability AS OxoCode
			, M.ModelIdentifier										AS StringIdentifier
			, 'P' + CAST(D.FeaturePackId AS NVARCHAR(10))			AS FeatureIdentifier
			, F.ExclusiveFeatureGroup
			, D.IsOrphanedData
			, CAST(CASE
				WHEN IGNORE.FdpImportErrorExclusionId IS NOT NULL THEN 1
				ELSE 0
			  END AS BIT) AS IsIgnoredData 
			, CAST(CASE
				WHEN MULTI.MappedFeatureCode IS NOT NULL THEN 1
				ELSE 0
			  END AS BIT) AS IsMappedToMultipleImportFeatures
		FROM 
		Fdp_VolumeHeader_VW						AS H
		JOIN Fdp_Feature_VW						AS F		ON	H.DocumentId		= F.DocumentId
															AND F.FeatureId			IS NULL
		JOIN Fdp_RawTakeRateData				AS D		ON	H.FdpVolumeHeaderId = D.FdpVolumeHeaderId	
															AND F.FeaturePackId		= D.FeaturePackId
															AND D.FeatureId			IS NULL												
		JOIN Fdp_RawModel						AS M		ON	D.ModelId			= M.ModelId
															
		-- Join on the feature tables without reference to the programme information as we may have data for uncoded features
		-- and need to at least return basic feature information
		
		LEFT JOIN Fdp_FeatureApplicability		AS FA2		ON	H.DocumentId	= FA2.DocumentId
															AND FA2.MarketId	= @MarketId
															AND	D.ModelId		= FA2.ModelId
															AND D.FeatureId		IS NULL
															AND D.FeaturePackId	= FA2.FeaturePackId
															
		LEFT JOIN Fdp_ImportErrorExclusion		AS IGNORE	ON	H.DocumentId	= IGNORE.DocumentId
															AND IGNORE.FdpImportErrorTypeId = 2
															AND F.FeatureCode	= IGNORE.AdditionalData

		LEFT JOIN
		(
			SELECT FdpVolumeHeaderId, MappedFeatureCode 
			FROM Fdp_ImportFeatureDescription
			GROUP BY FdpVolumeHeaderId, MappedFeatureCode
			HAVING COUNT(DISTINCT ImportFeatureCode) > 1
		)
												AS MULTI	ON	H.FdpVolumeHeaderId	= MULTI.FdpVolumeHeaderId
															AND F.FeatureCode	= MULTI.MappedFeatureCode
																				
		WHERE
		H.FdpVolumeHeaderId = @FdpVolumeHeaderId
		AND
		D.ProcessId = @ProcessId
	)
	INSERT INTO Fdp_PivotData
	(
		  FdpPivotHeaderId
		, DisplayOrder
		, FeatureGroup
		, FeatureSubGroup
		, FeatureCode
		, BrandDescription
		, FeatureId
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
		, StringIdentifier
		, FeatureIdentifier	
		, ExclusiveFeatureGroup
		, IsOrphanedData
		, IsIgnoredData
		, IsMappedToMultipleImportFeatures
	)
	SELECT 
		  @FdpPivotHeaderId
		, F.DisplayOrder
		, F.FeatureGroup
		, F.FeatureSubGroup
		, F.FeatureCode
		, F.BrandDescription
		, F.FeatureId
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
		, F.StringIdentifier
		, F.FeatureIdentifier
		, F.ExclusiveFeatureGroup
		, F.IsOrphanedData
		, F.IsIgnoredData
		, F.IsMappedToMultipleImportFeatures
	FROM
	TakeRateDataByFeature				AS F 
	ORDER BY
	F.DisplayOrder, F.BrandDescription;
	
	DELETE FROM Fdp_RawTakeRateData WHERE ProcessId = @ProcessId;