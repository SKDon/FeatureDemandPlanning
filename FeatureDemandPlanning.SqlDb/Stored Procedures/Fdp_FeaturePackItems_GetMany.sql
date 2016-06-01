CREATE PROCEDURE dbo.Fdp_FeaturePackItems_GetMany
	  @FdpVolumeHeaderId AS INT
	, @MarketId AS INT
AS
	SET NOCOUNT ON;

	SELECT
		  @FdpVolumeHeaderId AS FdpVolumeHeaderId
		, @MarketId AS MarketId
		, M.Id AS ModelId
		, P.Id AS FeatureId 
		, PackId AS FeaturePackId
		, PackName AS FeaturePackName
		, ISNULL(P.BrandDescription, P.SystemDescription) AS Feature
	FROM
	Fdp_VolumeHeader_VW AS H
	CROSS APPLY dbo.fn_Fdp_AvailableModelByMarketWithPaging_GetMany(@FdpVolumeHeaderId, @MarketId, NULL, NULL) AS M
	JOIN OXO_Pack_Feature_VW AS P ON H.ProgrammeId = P.ProgrammeId
	WHERE
	H.FdpVolumeHeaderId = @FdpVolumeHeaderId
	ORDER BY
	ModelId, FeaturePackId, FeatureId