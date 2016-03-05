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
		FROM dbo.fn_Fdp_FeatureApplicability_GetMany(@FdpVolumeHeaderId, @MarketId)
	)
	SELECT
		  H.FdpVolumeHeaderId
		, D.FdpVolumeDataItemId
		, D.MarketId
		, M.Market_Name AS Market
		, D.MarketGroupId
		, M.Market_Group_Name AS MarketGroup
		, D.FeatureId
		, D.FdpFeatureId
		, D.FeaturePackId
		, CASE
			WHEN F1.ID IS NOT NULL THEN F1.FeatureCode
			WHEN F2.FdpFeatureId IS NOT NULL THEN F2.FeatureCode
			WHEN F3.Id IS NOT NULL THEN F3.Feature_Code
		  END
		  AS FeatureCode
		, CASE
			WHEN F1.ID IS NOT NULL THEN ISNULL(F1.BrandDescription, F1.SystemDescription)
			WHEN F2.FdpFeatureId IS NOT NULL THEN ISNULL(F2.BrandDescription, F2.SystemDescription)
			WHEN F3.Id IS NOT NULL THEN F3.Pack_Name
		  END
		  AS FeatureDescription
		, F1.EFGName AS ExclusiveFeatureGroup
		, PK.Pack_Name AS PackName
		, D.ModelId
		, D.FdpModelId
		, CASE
			WHEN MD1.Id IS NOT NULL THEN MD1.Name
			WHEN MD2.FdpModelId IS NOT NULL THEN MD2.Name
		  END
		  AS Model
		, FA.OxoCode
		, FA.IsStandardFeatureInGroup
		, FA.IsOptionalFeatureInGroup
		, FA.IsNonApplicableFeatureInGroup
		, FA.FeaturesInExclusiveFeatureGroup
		, FA.ApplicableFeaturesInExclusiveFeatureGroup
		, ISNULL(C.TotalVolume, D.Volume) AS Volume
		, ISNULL(C.PercentageTakeRate, D.PercentageTakeRate) AS PercentageTakeRate
		, C.FdpChangesetDataItemId
		, CAST(CASE WHEN D.FeatureId IS NOT NULL AND (F1.Id IS NULL OR F1.[Status] = 'REMOVED') THEN 1 ELSE 0 END AS BIT) AS IsOrphanedData
    FROM
    Fdp_VolumeHeader_VW						AS H
    JOIN Fdp_VolumeDataItem_VW				AS D	ON	H.FdpVolumeHeaderId = D.FdpVolumeHeaderId
    JOIN OXO_Programme_MarketGroupMarket_VW AS M	ON	D.MarketId			= M.Market_Id
													AND H.ProgrammeId		= M.Programme_Id
	-- Features
	LEFT JOIN OXO_Programme_Feature_VW		AS F1	ON	D.FeatureId			= F1.ID
													AND H.ProgrammeId		= F1.ProgrammeId
	-- Fdp Features
	LEFT JOIN Fdp_Feature_VW				AS F2	ON	D.FdpFeatureId		= F2.FdpFeatureId
													AND H.ProgrammeId		= F2.ProgrammeId
													AND H.Gateway			= F2.Gateway
	-- Feature Packs
	LEFT JOIN OXO_Programme_Pack			AS F3	ON	D.FeaturePackId		= F3.Id
													AND H.ProgrammeId		= F3.Programme_Id
													AND D.FeatureId			IS NULL
													AND D.FdpFeatureId		IS NULL
	LEFT JOIN OXO_Programme_Pack			AS PK	ON D.FeaturePackId		= PK.Id
													AND H.ProgrammeId		= PK.Programme_Id
	
	-- Model
	LEFT JOIN OXO_Models_VW					AS MD1	ON	D.ModelId			= MD1.Id
													AND H.ProgrammeId		= MD1.Programme_Id
													
	LEFT JOIN Fdp_Model_VW					AS MD2	ON	D.FdpModelId		= MD2.FdpModelId
													AND H.ProgrammeId		= MD2.ProgrammeId
													AND H.Gateway			= MD2.Gateway
													
	-- Feature Applicability
	
	LEFT JOIN FeatureApplicability			AS FA	ON	D.FeatureId			= FA.FeatureId
													AND D.ModelId			= FA.ModelId
													
	-- Any changeset information
	LEFT JOIN Fdp_ChangesetDataItem_VW		AS C	ON	D.FdpVolumeDataItemId	= C.FdpVolumeDataItemId
													AND C.FdpChangesetId		= @FdpChangesetId
	
    WHERE
    H.FdpVolumeHeaderId = @FdpVolumeHeaderId
    AND
    (@MarketId IS NULL OR D.MarketId = @MarketId);
    
END