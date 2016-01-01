CREATE PROCEDURE [dbo].[Fdp_ChangesetDataItem_Save]
	  @FdpChangesetId		AS INT
	, @MarketId				AS INT
	, @ModelId				AS INT = NULL
	, @FdpModelId			AS INT = NULL
	, @FeatureId			AS INT = NULL
	, @FdpFeatureId			AS INT = NULL
	, @TotalVolume			AS INT = NULL
	, @PercentageTakeRate	AS DECIMAL(5, 4) = NULL
AS
	SET NOCOUNT ON;
	
	DECLARE @FdpChangesetDataItemId AS INT;
	
	-- If an item already exists we must delete it, rather than update
	-- Any changes need to be applied from the changeset sequentially, so that any calculations are 
	-- performed in the correct order. New changes are appended to the changeset
	
	UPDATE D SET IsDeleted = 1
	FROM Fdp_ChangesetDataItem AS D
	WHERE
	D.FdpChangesetId = @FdpChangesetId
	AND
	D.MarketId = @MarketId
	AND
	(@ModelId IS NULL OR D.ModelId = @ModelId)
	AND
	(@FdpModelId IS NULL OR D.FdpModelId = @FdpModelId)
	AND
	(@FeatureId IS NULL OR D.FeatureId = @FeatureId)
	AND
	(@FdpFeatureId IS NULL OR D.FdpFeatureId = @FdpFeatureId)
	AND
	D.IsDeleted = 0;
	
	-- Work out the original volume and percentage
	
	DECLARE @OriginalVolume INT;
	DECLARE @OriginalPercentageTakeRate DECIMAL(5, 4);
	DECLARE @FdpVolumeDataItemId INT;
	DECLARE @FdpTakeRateSummaryId INT;
	
	SELECT TOP 1 
		  @OriginalVolume = OLD.Volume
		, @OriginalPercentageTakeRate = OLD.PercentageTakeRate
		, @FdpVolumeDataItemId = OLD.FdpVolumeDataItemId
		, @FdpTakeRateSummaryId = OLD.FdpTakeRateSummaryId
	FROM
	(
		SELECT 
			Volume
		  , PercentageTakeRate
		  , FdpVolumeDataItemId
		  , CAST(NULL AS INT) AS FdpTakeRateSummaryId
		FROM
		Fdp_Changeset			AS C
		JOIN Fdp_VolumeHeader	AS H ON C.FdpVolumeHeaderId = H.FdpVolumeHeaderId
		JOIN Fdp_VolumeDataItem AS D ON H.FdpVolumeHeaderId = D.FdpVolumeHeaderId
									 AND D.MarketId = @MarketId
									 AND D.ModelId = @ModelId
									 AND D.FeatureId = @FeatureId
									 
		UNION
		
		SELECT 
			Volume
		  , PercentageTakeRate
		  , FdpVolumeDataItemId
		  , CAST(NULL AS INT) AS FdpTakeRateSummaryId
		FROM
		Fdp_Changeset			AS C
		JOIN Fdp_VolumeHeader	AS H ON C.FdpVolumeHeaderId = H.FdpVolumeHeaderId
		JOIN Fdp_VolumeDataItem AS D ON H.FdpVolumeHeaderId = D.FdpVolumeHeaderId
									 AND D.MarketId = @MarketId
									 AND D.FdpModelId = @FdpModelId
									 AND D.FeatureId = @FeatureId
									 
		UNION
		
		SELECT 
			Volume
		  , PercentageTakeRate
		  , FdpVolumeDataItemId
		  , CAST(NULL AS INT) AS FdpTakeRateSummaryId
		FROM
		Fdp_Changeset			AS C
		JOIN Fdp_VolumeHeader	AS H ON C.FdpVolumeHeaderId = H.FdpVolumeHeaderId
		JOIN Fdp_VolumeDataItem AS D ON H.FdpVolumeHeaderId = D.FdpVolumeHeaderId
									 AND D.MarketId = @MarketId
									 AND D.ModelId = @ModelId
									 AND D.FdpFeatureId = @FdpFeatureId
									 
		UNION
		
		SELECT 
			D.Volume
		  , D.PercentageTakeRate
		  , D.FdpVolumeDataItemId
		  , CAST(NULL AS INT) AS FdpTakeRateSummaryId
		FROM
		Fdp_Changeset			AS C
		JOIN Fdp_VolumeHeader	AS H ON C.FdpVolumeHeaderId = H.FdpVolumeHeaderId
		JOIN Fdp_VolumeDataItem AS D ON H.FdpVolumeHeaderId = D.FdpVolumeHeaderId
									 AND D.MarketId			= @MarketId
									 AND D.FdpModelId		= @FdpModelId
									 AND D.FdpFeatureId		= @FdpFeatureId

		UNION

		SELECT
			  S.Volume
			, S.PercentageTakeRate
			, CAST(NULL AS INT) AS FdpVolumeDataItemId
			, S.FdpTakeRateSummaryId
		FROM
		Fdp_Changeset				AS C
		JOIN Fdp_VolumeHeader		AS H ON C.FdpVolumeHeaderId = H.FdpVolumeHeaderId
		JOIN Fdp_TakeRateSummary	AS S ON H.FdpVolumeHeaderId = S.FdpVolumeHeaderId
										 AND S.MarketId			= @MarketId
										 AND S.ModelId			= @ModelId

		UNION

		SELECT
			  S.Volume
			, S.PercentageTakeRate
			, CAST(NULL AS INT) AS FdpVolumeDataItemId
			, S.FdpTakeRateSummaryId
		FROM
		Fdp_Changeset				AS C
		JOIN Fdp_VolumeHeader		AS H ON C.FdpVolumeHeaderId = H.FdpVolumeHeaderId
		JOIN Fdp_TakeRateSummary	AS S ON H.FdpVolumeHeaderId = S.FdpVolumeHeaderId
										 AND S.MarketId			= @MarketId
										 AND S.FdpModelId		= @FdpModelId
	)
	AS OLD

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
		, FdpTakeRateSummaryId
	)
	VALUES
	(
		  @FdpChangesetId
		, @MarketId
		, @ModelId
		, @FdpModelId
		, @FeatureId
		, @FdpFeatureId
		, @TotalVolume
		, @PercentageTakeRate
		, CASE WHEN @TotalVolume IS NOT NULL THEN 1 ELSE 0 END
		, CASE WHEN @PercentageTakeRate IS NOT NULL THEN 1 ELSE 0 END
		, @OriginalVolume
		, @OriginalPercentageTakeRate
		, @FdpVolumeDataItemId
		, @FdpTakeRateSummaryId
	);
	
	SET @FdpChangesetDataItemId = SCOPE_IDENTITY();
	
	EXEC Fdp_ChangesetDataItem_Get @FdpChangesetDataItemId = @FdpChangesetDataItemId;