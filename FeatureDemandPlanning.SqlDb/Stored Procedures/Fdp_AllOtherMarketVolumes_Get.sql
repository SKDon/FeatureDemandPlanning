CREATE PROCEDURE [dbo].[Fdp_AllOtherMarketVolumes_Get]
	  @FdpVolumeHeaderId	INT
	, @MarketId				INT
	, @CDSId				NVARCHAR(16)
AS

	SET NOCOUNT ON;

	SELECT SUM(S.TotalVolume) AS TotalVolume
	FROM
	Fdp_VolumeHeader AS H
	JOIN Fdp_TakeRateSummaryByMarket_VW		AS S	ON	H.FdpVolumeHeaderId		= S.FdpVolumeHeaderId
													AND S.MarketId				<> @MarketId
	--LEFT JOIN Fdp_Changeset					AS C	ON	H.FdpVolumeHeaderId		= C.FdpVolumeHeaderId
	--												AND C.CreatedBy				= @CDSId
	--												AND C.IsDeleted				= 0
	--												AND C.IsSaved				= 0
	--												AND S.MarketId				= C.MarketId
	--LEFT JOIN Fdp_ChangesetDataItem			AS D	ON	C.FdpChangesetId		= D.FdpChangesetId
	--												AND D.ModelId				IS NULL
	--												AND D.FdpModelId			IS NULL
	--												AND D.FeatureId				IS NULL
	--												AND D.FdpFeatureId			IS NULL
	--												AND S.MarketId				= D.MarketId
	--												AND D.IsDeleted				= 0
	WHERE
	H.FdpVolumeHeaderId = @FdpVolumeHeaderId
	GROUP BY
	H.FdpVolumeHeaderId;