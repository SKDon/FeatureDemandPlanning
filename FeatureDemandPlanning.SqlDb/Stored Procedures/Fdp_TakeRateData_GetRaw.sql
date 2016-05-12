CREATE PROCEDURE [dbo].[Fdp_TakeRateData_GetRaw]
	  @FdpVolumeHeaderId	INT
	, @MarketId				INT = NULL
	, @CDSId				NVARCHAR(16)
AS
BEGIN
	SET NOCOUNT ON;
	SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;
	
	DECLARE @FdpChangesetId INT;
	IF @MarketId IS NOT NULL
		SET @FdpChangesetId = dbo.fn_Fdp_Changeset_GetLatestByUser(@FdpVolumeHeaderId, @MarketId, @CDSId);

    WITH FeatureApplicability AS
	(
		SELECT 
			  FeatureId
			, ModelId
			, FeaturePackId
			, EFGName
			, FeaturesInExclusiveFeatureGroup
			, IsStandardFeatureInGroup
			, IsOptionalFeatureInGroup
			, IsNonApplicableFeatureInGroup
			, ApplicableFeaturesInExclusiveFeatureGroup
			, OxoCode
		FROM
		dbo.fn_Fdp_FeatureApplicability_GetMany(@FdpVolumeHeaderId, @MarketId)
	)
	, Models AS 
	(
		SELECT
			  @FdpVolumeHeaderId	AS FdpVolumeHeaderId
			, M.Id					AS ModelId
			, M.FdpModelId			AS FdpModelId
			, M.Name
		FROM
		dbo.fn_Fdp_AvailableModelByMarketWithPaging_GetMany(@FdpVolumeHeaderId, @MarketId, NULL, NULL) AS M
	)
	SELECT
		  H.FdpVolumeHeaderId
		, CASE
			WHEN F.FeaturePackId IS NOT NULL AND F.FeatureId IS NULL THEN D2.FdpVolumeDataItemId
			WHEN F.FeatureId IS NOT NULL THEN D1.FdpVolumeDataItemId
			ELSE NULL
		  END AS FdpVolumeDataItemId
		, MK.Market_Id AS MarketId
		, MK.Market_Name AS Market
		, MK.Market_Group_Id AS MarketGroupId
		, MK.Market_Group_Name AS MarketGroup
		, F.FeatureId
		, F.FdpFeatureId
		, F.FeaturePackId
		, CASE
			WHEN F.FeatureId IS NOT NULL THEN F.FeatureCode
			WHEN F.FeaturePackId IS NOT NULL THEN F.FeaturePackCode
		  END
		  AS FeatureCode
		, CASE
			WHEN F.FeatureId IS NOT NULL THEN F.SystemDescription --ISNULL(F.BrandDescription, F.SystemDescription)
			WHEN F.FeaturePackId IS NOT NULL THEN F.FeaturePackName
		  END
		  AS FeatureDescription
		, F.ExclusiveFeatureGroup
		, F.FeaturePackName AS PackName
		, M.ModelId
		, M.FdpModelId
		, M.Name AS Model
		, ISNULL(FA.OxoCode, FA2.OxoCode) AS OxoCode
		, ISNULL(FA.IsStandardFeatureInGroup, FA2.IsStandardFeatureInGroup) AS IsStandardFeatureInGroup
		, ISNULL(FA.IsOptionalFeatureInGroup, FA2.IsOptionalFeatureInGroup) AS IsOptionalFeatureInGroup
		, ISNULL(FA.IsNonApplicableFeatureInGroup, FA2.IsNonApplicableFeatureInGroup) AS IsNonApplicableFeatureInGroup
		, ISNULL(FA.FeaturesInExclusiveFeatureGroup, FA2.FeaturesInExclusiveFeatureGroup) AS FeaturesInExclusiveFeatureGroup
		, ISNULL(FA.ApplicableFeaturesInExclusiveFeatureGroup, FA2.ApplicableFeaturesInExclusiveFeatureGroup) AS ApplicableFeaturesInExclusiveFeatureGroup
		, CASE
			WHEN F.FeaturePackId IS NOT NULL AND F.FeatureId IS NULL THEN ISNULL(ISNULL(C2.TotalVolume, D2.Volume), 0)
			WHEN F.FeatureId IS NOT NULL THEN ISNULL(ISNULL(C1.TotalVolume, D1.Volume), 0)
			ELSE NULL
		  END AS Volume
		, CASE
			WHEN F.FeaturePackId IS NOT NULL AND F.FeatureId IS NULL THEN ISNULL(ISNULL(C2.PercentageTakeRate, D2.PercentageTakeRate), 
			CASE 
				WHEN FA.OxoCode LIKE '%S%' AND FA.FeatureId IS NOT NULL THEN 1
				WHEN FA2.OxoCode LIKE '%S%' AND FA2.FeaturePackId IS NOT NULL THEN 1 
				ELSE 0 
			END)
			WHEN F.FeatureId IS NOT NULL THEN ISNULL(ISNULL(C1.PercentageTakeRate, D1.PercentageTakeRate), 
			CASE 
				WHEN FA.OxoCode LIKE '%S%' AND FA.FeatureId IS NOT NULL THEN 1
				WHEN FA2.OxoCode LIKE '%S%' AND FA2.FeaturePackId IS NOT NULL THEN 1 
				ELSE 0 
			END)
			ELSE 0
		  END AS PercentageTakeRate
		, CASE
			WHEN F.FeaturePackId IS NOT NULL AND F.FeatureId IS NULL THEN C2.FdpChangesetDataItemId
			WHEN F.FeatureId IS NOT NULL THEN C1.FdpChangesetDataItemId
			ELSE NULL
		  END
			AS FdpChangesetDataItemId
		, CAST(0 AS BIT) AS IsOrphanedData
    FROM
    Fdp_VolumeHeader_VW						AS H
    JOIN Models								AS M	ON	H.FdpVolumeHeaderId	= M.FdpVolumeHeaderId
    JOIN OXO_Programme_MarketGroupMarket_VW AS MK	ON	H.ProgrammeId		= MK.Programme_Id
	
	-- Features
	JOIN Fdp_Feature_VW						AS F	ON	H.DocumentId		= F.DocumentId
	
	-- Feature Packs
	LEFT JOIN OXO_Programme_Pack			AS PK1	ON	F.FeaturePackId		= PK1.Id
													AND H.ProgrammeId		= PK1.Programme_Id
													AND F.FeatureId			IS NULL
													
	-- Feature Applicability
	
	LEFT JOIN FeatureApplicability			AS FA	ON	F.FeatureId			= FA.FeatureId
													AND M.ModelId			= FA.ModelId

	LEFT JOIN FeatureApplicability			AS FA2	ON	F.FeaturePackId		= FA2.FeaturePackId
													AND F.FeatureId			IS NULL
													AND M.ModelId			= FA2.ModelId

	-- Any existing data
	LEFT JOIN Fdp_VolumeDataItem_VW			AS D1	ON	H.FdpVolumeHeaderId = D1.FdpVolumeHeaderId
													AND MK.Market_Id		= D1.MarketId
													AND M.ModelId			= D1.ModelId
													AND F.FeatureId			= D1.FeatureId

	-- Any existing data
	LEFT JOIN Fdp_VolumeDataItem_VW			AS D2	ON	H.FdpVolumeHeaderId = D2.FdpVolumeHeaderId
													AND MK.Market_Id		= D2.MarketId
													AND M.ModelId			= D2.ModelId
													AND F.FeaturePackId		= D2.FeaturePackId
													AND F.FeatureId			IS NULL
													AND D2.FeatureId		IS NULL
													
	-- Any changeset information
	LEFT JOIN Fdp_ChangesetDataItem_VW		AS C1	ON	C1.FdpChangesetId		= @FdpChangesetId
													AND MK.Market_Id			= C1.MarketId
													AND M.ModelId				= C1.ModelId
													AND F.FeatureId				= C1.FeatureId

	LEFT JOIN Fdp_ChangesetDataItem_VW		AS C2	ON	C2.FdpChangesetId		= @FdpChangesetId
													AND MK.Market_Id			= C2.MarketId
													AND M.ModelId				= C2.ModelId
													AND F.FeatureId				IS NULL
													AND F.FeaturePackId			= C2.FeaturePackId
													AND C2.FeatureId			IS NULL
    WHERE
    H.FdpVolumeHeaderId = @FdpVolumeHeaderId
    AND
    (@MarketId IS NULL OR MK.Market_Id = @MarketId)
    
END