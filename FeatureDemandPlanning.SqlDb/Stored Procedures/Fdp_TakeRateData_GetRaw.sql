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
		, D.FdpVolumeDataItemId
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
			WHEN F.FeatureId IS NOT NULL THEN ISNULL(F.BrandDescription, F.SystemDescription)
			WHEN F.FeaturePackId IS NOT NULL THEN F.FeaturePackName
		  END
		  AS FeatureDescription
		, F.ExclusiveFeatureGroup
		, F.FeaturePackName AS PackName
		, M.ModelId
		, M.FdpModelId
		, M.Name AS Model
		, FA.OxoCode
		, FA.IsStandardFeatureInGroup
		, FA.IsOptionalFeatureInGroup
		, FA.IsNonApplicableFeatureInGroup
		, FA.FeaturesInExclusiveFeatureGroup
		, FA.ApplicableFeaturesInExclusiveFeatureGroup
		, ISNULL(ISNULL(C.TotalVolume, D.Volume), 0) AS Volume
		, ISNULL(ISNULL(C.PercentageTakeRate, D.PercentageTakeRate), CASE WHEN FA.OxoCode LIKE '%S%' THEN 1 ELSE 0 END) AS PercentageTakeRate
		, C.FdpChangesetDataItemId
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
	-- Any existing data
	LEFT JOIN Fdp_VolumeDataItem_VW			AS D	ON	H.FdpVolumeHeaderId = D.FdpVolumeHeaderId
													AND MK.Market_Id		= D.MarketId
													AND M.ModelId			= D.ModelId
													AND F.FeatureId			= D.FeatureId
													
	-- Any changeset information
	LEFT JOIN Fdp_ChangesetDataItem_VW		AS C	ON	C.FdpChangesetId		= @FdpChangesetId
													AND MK.Market_Id			= C.MarketId
													AND M.ModelId				= C.ModelId
													AND F.FeatureId				= C.FeatureId
	
    WHERE
    H.FdpVolumeHeaderId = @FdpVolumeHeaderId
    AND
    (@MarketId IS NULL OR MK.Market_Id = @MarketId)
    
END