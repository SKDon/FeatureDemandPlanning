CREATE PROCEDURE dbo.Fdp_VolumeByMarket_Get
	  @DocumentId	INT
	, @MarketId		INT
	, @CDSId		NVARCHAR(16)
AS

	SET NOCOUNT ON;

	WITH UPDATES AS
	(
		SELECT
			  C.MarketId
			, SUM(D.TotalVolume) AS TotalVolume
		FROM
		Fdp_VolumeHeader AS H
		JOIN Fdp_Changeset			AS C	ON	H.FdpVolumeHeaderId	= C.FdpVolumeHeaderId
											AND C.CreatedBy			= @CDSId
											AND C.IsDeleted			= 0
											AND C.IsSaved			= 0
											AND C.MarketId			= @MarketId
		JOIN Fdp_ChangesetDataItem	AS D	ON C.FdpChangesetId		= D.FdpChangesetDataItemId
											AND D.ModelId			IS NULL
											AND D.FdpModelId		IS NULL
											AND D.FeatureId			IS NULL
											AND D.FdpFeatureId		IS NULL
											AND D.IsDeleted			= 0
		WHERE
		H.DocumentId = @DocumentId
		GROUP BY
		C.MarketId
	)

	SELECT ISNULL(UPDATES.TotalVolume, S.TotalVolume) AS TotalVolume
	FROM Fdp_TakeRateSummaryByMarket_VW AS S
	LEFT JOIN UPDATES ON S.MarketId = UPDATES.MarketId
	WHERE
	S.DocumentId = @DocumentId
	AND
	S.MarketId = @MarketId