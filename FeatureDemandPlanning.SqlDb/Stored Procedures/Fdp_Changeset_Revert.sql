CREATE PROCEDURE [dbo].[Fdp_Changeset_Revert]
	  @DocumentId	AS INT
	, @CDSID		AS NVARCHAR(16)
AS
	SET NOCOUNT ON;
	
	DECLARE @FdpChangesetId AS INT;
	
	SELECT TOP 1 @FdpChangesetId = C.FdpChangesetId
	FROM
	Fdp_VolumeHeader	AS H
	JOIN Fdp_Changeset	AS C	ON H.FdpVolumeHeaderId = C.FdpVolumeHeaderId
	WHERE
	H.DocumentId = @DocumentId
	AND
	C.CreatedBy = @CDSID
	AND
	C.IsDeleted = 0
	AND
	C.IsSaved = 0
	ORDER BY
	C.CreatedOn DESC;
	
	EXEC Fdp_Changeset_Get @FdpChangesetId = @FdpChangesetId;

	SELECT
		  D.MarketId
		, 'O' + CAST(D.ModelId AS NVARCHAR(10))		AS ModelIdentifier
		, 'O' + CAST(D.FeatureId AS NVARCHAR(10))	AS FeatureIdentifier
		, ISNULL(OLD.Volume, 0)							AS TotalVolume
		, ISNULL(OLD.PercentageTakeRate, 0)				AS PercentageTakeRate
		, D.TotalVolume								AS RevertedVolume
		, D.PercentageTakeRate						AS RevertedPercentageTakeRate
	FROM
	Fdp_Changeset				AS C
	JOIN Fdp_VolumeHeader		AS H	ON	C.FdpVolumeHeaderId = H.FdpVolumeHeaderId
	JOIN Fdp_ChangesetDataItem	AS D	ON	C.FdpChangesetId	= D.FdpChangesetId
										AND D.IsDeleted			= 0
	JOIN Fdp_VolumeDataItem		AS OLD	ON	H.FdpVolumeHeaderId	= OLD.FdpVolumeHeaderId
										AND D.MarketId			= OLD.MarketId
										AND D.ModelId			= OLD.ModelId
										AND D.FeatureId			= OLD.FeatureId
	WHERE
	C.FdpChangesetId = @FdpChangesetId
	
	UNION
	
	SELECT
		  D.MarketId
		, 'F' + CAST(D.FdpModelId AS NVARCHAR(10))	AS ModelIdentifier
		, 'O' + CAST(D.FeatureId AS NVARCHAR(10))	AS FeatureIdentifier
		, ISNULL(OLD.Volume, 0)							AS TotalVolume
		, ISNULL(OLD.PercentageTakeRate, 0)				AS PercentageTakeRate
		, D.TotalVolume								AS RevertedVolume
		, D.PercentageTakeRate						AS RevertedPercentageTakeRate
	FROM
	Fdp_Changeset				AS C
	JOIN Fdp_VolumeHeader		AS H	ON	C.FdpVolumeHeaderId = H.FdpVolumeHeaderId
	JOIN Fdp_ChangesetDataItem	AS D	ON	C.FdpChangesetId	= D.FdpChangesetId
										AND D.IsDeleted			= 0
	JOIN Fdp_VolumeDataItem		AS OLD	ON	H.FdpVolumeHeaderId	= OLD.FdpVolumeHeaderId
										AND D.MarketId			= OLD.MarketId
										AND D.FdpModelId		= OLD.FdpModelId
										AND D.FeatureId			= OLD.FeatureId
	WHERE
	C.FdpChangesetId = @FdpChangesetId
	
	UNION
	
	SELECT
		  D.MarketId
		, 'O' + CAST(D.ModelId AS NVARCHAR(10))			AS ModelIdentifier
		, 'F' + CAST(D.FdpFeatureId AS NVARCHAR(10))	AS FeatureIdentifier
		, ISNULL(OLD.Volume, 0)							AS TotalVolume
		, ISNULL(OLD.PercentageTakeRate, 0)				AS PercentageTakeRate
		, D.TotalVolume									AS RevertedVolume
		, D.PercentageTakeRate							AS RevertedPercentageTakeRate
	FROM
	Fdp_Changeset				AS C
	JOIN Fdp_VolumeHeader		AS H	ON	C.FdpVolumeHeaderId = H.FdpVolumeHeaderId
	JOIN Fdp_ChangesetDataItem	AS D	ON	C.FdpChangesetId	= D.FdpChangesetId
										AND D.IsDeleted			= 0
	JOIN Fdp_VolumeDataItem		AS OLD	ON	H.FdpVolumeHeaderId	= OLD.FdpVolumeHeaderId
										AND D.MarketId			= OLD.MarketId
										AND D.ModelId			= OLD.ModelId
										AND D.FdpFeatureId		= OLD.FdpFeatureId
	WHERE
	C.FdpChangesetId = @FdpChangesetId
	
	UNION
	
	SELECT
		  D.MarketId
		, 'F' + CAST(D.FdpModelId AS NVARCHAR(10))		AS ModelIdentifier
		, 'F' + CAST(D.FdpFeatureId AS NVARCHAR(10))	AS FeatureIdentifier
		, ISNULL(OLD.Volume, 0)							AS TotalVolume
		, ISNULL(OLD.PercentageTakeRate, 0)				AS PercentageTakeRate
		, D.TotalVolume									AS RevertedVolume
		, D.PercentageTakeRate							AS RevertedPercentageTakeRate
	FROM
	Fdp_Changeset				AS C
	JOIN Fdp_VolumeHeader		AS H	ON	C.FdpVolumeHeaderId = H.FdpVolumeHeaderId
	JOIN Fdp_ChangesetDataItem	AS D	ON	C.FdpChangesetId	= D.FdpChangesetId
										AND D.IsDeleted			= 0
	LEFT JOIN Fdp_VolumeDataItem	AS OLD	ON	H.FdpVolumeHeaderId	= OLD.FdpVolumeHeaderId
										AND D.MarketId			= OLD.MarketId
										AND D.FdpModelId		= OLD.FdpModelId
										AND D.FdpFeatureId		= OLD.FdpFeatureId
	WHERE
	C.FdpChangesetId = @FdpChangesetId