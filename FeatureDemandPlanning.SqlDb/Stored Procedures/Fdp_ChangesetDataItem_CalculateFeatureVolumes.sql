CREATE PROCEDURE dbo.Fdp_ChangesetDataItem_CalculateFeatureVolumes
	@FdpChangesetDataItemId INT
AS

	SET NOCOUNT ON;

	UPDATE D1 SET 
		TotalVolume = D.TotalVolume * D1.PercentageTakeRate
	FROM
	Fdp_Changeset AS C
	JOIN Fdp_ChangesetDataItem AS D ON C.FdpChangesetId = D.FdpChangesetId
	JOIN Fdp_ChangesetDataItem AS D1 ON D.ModelId		= D1.ModelId
									 AND D.MarketId		= D1.MarketId
									 AND D1.IsDeleted	= 0
									 AND (D1.FeatureId IS NOT NULL OR D1.FdpFeatureId IS NOT NULL)
									 AND D.FdpChangesetDataItemId <> D1.FdpChangesetDataItemId
	WHERE
	D.FdpChangesetDataItemId = @FdpChangesetDataItemId;

	UPDATE D1 SET 
		TotalVolume = D.TotalVolume * D1.PercentageTakeRate
	FROM
	Fdp_Changeset AS C
	JOIN Fdp_ChangesetDataItem AS D ON C.FdpChangesetId		= D.FdpChangesetId
	JOIN Fdp_ChangesetDataItem AS D1 ON D.FdpModelId		= D1.FdpModelId
									 AND D.MarketId			= D1.MarketId
									 AND D1.IsDeleted		= 0
									 AND (D1.FeatureId IS NOT NULL OR D1.FdpFeatureId IS NOT NULL)
									 AND D.FdpChangesetDataItemId <> D1.FdpChangesetDataItemId
	WHERE
	D.FdpChangesetDataItemId = @FdpChangesetDataItemId;

	-- Add a new changeset data item where there is no change existing already

	INSERT INTO Fdp_ChangesetDataItem
	(
		  FdpChangesetId
		, MarketId
		, ModelId
		, FdpModelId
		, FeatureId
		, FdpFeatureId
		, TotalVolume
		, PercentageTakeRate
		, IsVolumeUpdate
		, IsPercentageUpdate
		, OriginalVolume
		, OriginalPercentageTakeRate
		, FdpVolumeDataItemId
	)
	SELECT
		  C.FdpChangesetId
		, D1.MarketId
		, D1.ModelId
		, D1.FdpModelId
		, D1.FeatureId
		, D1.FdpFeatureId
		, D.TotalVolume * D1.PercentageTakeRate
		, D1.PercentageTakeRate
		, 0
		, 1
		, D1.Volume
		, D1.PercentageTakeRate
		, D1.FdpVolumeDataItemId
	FROM
	Fdp_Changeset					AS C
	JOIN Fdp_VolumeHeader			AS H	ON	C.FdpVolumeHeaderId = C.FdpVolumeHeaderId
	JOIN Fdp_ChangesetDataItem		AS D	ON	C.FdpChangesetId	= D.FdpChangesetId
	JOIN Fdp_VolumeDataItem			AS D1	ON	H.FdpVolumeHeaderId = D1.FdpVolumeHeaderId
											AND D.ModelId			= D1.ModelId
											AND D.MarketId			= D1.MarketId
											AND (D1.FeatureId IS NOT NULL OR D1.FdpFeatureId IS NOT NULL)
	LEFT JOIN Fdp_ChangesetDataItem AS D2	ON D1.FdpVolumeDataItemId = D2.FdpVolumeDataItemId
											AND D2.IsDeleted = 0
	WHERE
	D.FdpChangesetDataItemId = @FdpChangesetDataItemId
	AND
	D2.FdpChangesetDataItemId IS NULL

	UNION

	SELECT
		  C.FdpChangesetId
		, D1.MarketId
		, D1.ModelId
		, D1.FdpModelId
		, D1.FeatureId
		, D1.FdpFeatureId
		, D.TotalVolume * D1.PercentageTakeRate
		, D1.PercentageTakeRate
		, 0
		, 1
		, D1.Volume
		, D1.PercentageTakeRate
		, D1.FdpVolumeDataItemId
	FROM
	Fdp_Changeset					AS C
	JOIN Fdp_VolumeHeader			AS H	ON	C.FdpVolumeHeaderId = C.FdpVolumeHeaderId
	JOIN Fdp_ChangesetDataItem		AS D	ON	C.FdpChangesetId	= D.FdpChangesetId
	JOIN Fdp_VolumeDataItem			AS D1	ON	H.FdpVolumeHeaderId = D1.FdpVolumeHeaderId
											AND D.FdpModelId		= D1.FdpModelId
											AND D.MarketId			= D1.MarketId
											AND (D1.FeatureId IS NOT NULL OR D1.FdpFeatureId IS NOT NULL)
	LEFT JOIN Fdp_ChangesetDataItem AS D2	ON D1.FdpVolumeDataItemId = D2.FdpVolumeDataItemId
											AND D2.IsDeleted = 0
	WHERE
	D.FdpChangesetDataItemId = @FdpChangesetDataItemId
	AND
	D2.FdpChangesetDataItemId IS NULL;