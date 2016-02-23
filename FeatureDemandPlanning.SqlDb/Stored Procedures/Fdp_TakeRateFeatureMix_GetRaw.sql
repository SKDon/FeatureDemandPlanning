CREATE PROCEDURE [dbo].[Fdp_TakeRateFeatureMix_GetRaw]
	  @FdpVolumeHeaderId	INT
	, @MarketId				INT
	, @CDSId				NVARCHAR(16)
AS
BEGIN
	SET NOCOUNT ON;
	
	DECLARE @FdpChangesetId INT;
	SET @FdpChangesetId = dbo.fn_Fdp_Changeset_GetLatestByUser(@FdpVolumeHeaderId, @MarketId, @CDSId);

	SELECT
		  H.FdpVolumeHeaderId
		, FM.FdpTakeRateFeatureMixId
		, FM.MarketId
		, M.Market_Name AS Market
		, M.Market_Group_Id AS MarketGroupId
		, M.Market_Group_Name AS MarketGroup
		, FM.FeatureId
		, FM.FdpFeatureId
		, FM.FeaturePackId
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
		, ISNULL(C.TotalVolume, FM.Volume) AS Volume
		, ISNULL(C.PercentageTakeRate, FM.PercentageTakeRate) AS PercentageTakeRate
    FROM
    Fdp_VolumeHeader_VW						AS H
    JOIN Fdp_TakeRateFeatureMix				AS FM	ON	H.FdpVolumeHeaderId = FM.FdpVolumeHeaderId
    JOIN OXO_Programme_MarketGroupMarket_VW AS M	ON	FM.MarketId			= M.Market_Id
													AND H.ProgrammeId		= M.Programme_Id
	-- Features
	LEFT JOIN OXO_Programme_Feature_VW		AS F1	ON	FM.FeatureId		= F1.ID
													AND H.ProgrammeId		= F1.ProgrammeId
	-- Fdp Features
	LEFT JOIN Fdp_Feature_VW				AS F2	ON	FM.FdpFeatureId		= F2.FdpFeatureId
													AND H.ProgrammeId		= F2.ProgrammeId
													AND H.Gateway			= F2.Gateway
	-- Feature Packs
	LEFT JOIN OXO_Programme_Pack			AS F3	ON	FM.FeaturePackId		= F3.Id
													AND H.ProgrammeId		= F3.Programme_Id
													AND FM.FeatureId			IS NULL
													AND FM.FdpFeatureId		IS NULL
													
	-- Any changeset information
	LEFT JOIN Fdp_ChangesetDataItem_VW		AS C	ON	FM.FdpTakeRateFeatureMixId	= C.FdpTakeRateFeatureMixId
													AND C.FdpChangesetId		= @FdpChangesetId
	
    WHERE
    H.FdpVolumeHeaderId = @FdpVolumeHeaderId
    AND
    FM.MarketId = @MarketId;
    
END