CREATE PROCEDURE [dbo].[Fdp_ChangesetDataItem_Save]
	  @FdpChangesetId				AS INT
	, @ParentFdpChangesetDataItemId AS INT = NULL
	, @MarketId						AS INT
	, @ModelId						AS INT = NULL
	, @FdpModelId					AS INT = NULL
	, @FeatureId					AS INT = NULL
	, @FdpFeatureId					AS INT = NULL
	, @FeaturePackId				AS INT = NULL
	, @DerivativeCode				AS NVARCHAR(20) = NULL
	, @TotalVolume					AS INT = NULL
	, @PercentageTakeRate			AS DECIMAL(5, 4) = NULL
	, @OriginalVolume				AS INT = NULL
	, @OriginalPercentageTakeRate	AS DECIMAL(5, 4) = NULL
	, @FdpVolumeDataItemId			AS INT = NULL
	, @FdpTakeRateSummaryId			AS INT = NULL
	, @FdpTakeRateFeatureMixId		AS INT = NULL
	, @FdpPowertrainDataItemId		AS INT = NULL
	, @IsVolumeUpdate				AS BIT = 0
	, @IsPercentageUpdate			AS BIT = 0
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
	ModelId = @ModelId
	AND
	FeatureId = @FeatureId
	AND
	(@ParentFdpChangesetDataItemId IS NULL OR D.ParentFdpChangesetDataItemId <> @ParentFdpChangesetDataItemId OR D.FdpChangesetDataItemId <> @ParentFdpChangesetDataItemId)

	UPDATE D SET IsDeleted = 1
	FROM Fdp_ChangesetDataItem AS D
	WHERE
	D.FdpChangesetId = @FdpChangesetId
	AND
	D.MarketId = @MarketId
	AND
	ModelId = @ModelId
	AND
	FdpFeatureId = @FdpFeatureId
	AND
	(@ParentFdpChangesetDataItemId IS NULL OR D.ParentFdpChangesetDataItemId <> @ParentFdpChangesetDataItemId OR D.FdpChangesetDataItemId <> @ParentFdpChangesetDataItemId)

	UPDATE D SET IsDeleted = 1
	FROM Fdp_ChangesetDataItem AS D
	WHERE
	D.FdpChangesetId = @FdpChangesetId
	AND
	D.MarketId = @MarketId
	AND
	FdpModelId = @FdpModelId
	AND
	FeatureId = @FeatureId
	AND
	(@ParentFdpChangesetDataItemId IS NULL OR D.ParentFdpChangesetDataItemId <> @ParentFdpChangesetDataItemId OR D.FdpChangesetDataItemId <> @ParentFdpChangesetDataItemId)

	UPDATE D SET IsDeleted = 1
	FROM Fdp_ChangesetDataItem AS D
	WHERE
	D.FdpChangesetId = @FdpChangesetId
	AND
	D.MarketId = @MarketId
	AND
	FdpModelId = @FdpModelId
	AND
	FdpFeatureId = @FdpFeatureId
	AND
	(@ParentFdpChangesetDataItemId IS NULL OR D.ParentFdpChangesetDataItemId <> @ParentFdpChangesetDataItemId OR D.FdpChangesetDataItemId <> @ParentFdpChangesetDataItemId)

	UPDATE D SET IsDeleted = 1
	FROM Fdp_ChangesetDataItem AS D
	WHERE
	D.FdpChangesetId = @FdpChangesetId
	AND
	D.MarketId = @MarketId
	AND
	ModelId = @ModelId
	AND
	FeatureId IS NULL
	AND
	FeaturePackId = @FeaturePackId
	AND
	(@ParentFdpChangesetDataItemId IS NULL OR D.ParentFdpChangesetDataItemId <> @ParentFdpChangesetDataItemId OR D.FdpChangesetDataItemId <> @ParentFdpChangesetDataItemId)

	-- Clear model summary

	UPDATE D SET IsDeleted = 1
	FROM Fdp_ChangesetDataItem AS D
	WHERE
	D.FdpChangesetId = @FdpChangesetId
	AND
	D.MarketId = @MarketId
	AND
	ModelId = @ModelId
	AND
	FeatureId IS NULL
	AND
	FdpFeatureId IS NULL
	AND
	FeaturePackId IS NULL
	AND
	(@ParentFdpChangesetDataItemId IS NULL OR D.ParentFdpChangesetDataItemId <> @ParentFdpChangesetDataItemId OR D.FdpChangesetDataItemId <> @ParentFdpChangesetDataItemId)

	UPDATE D SET IsDeleted = 1
	FROM Fdp_ChangesetDataItem AS D
	WHERE
	D.FdpChangesetId = @FdpChangesetId
	AND
	D.MarketId = @MarketId
	AND
	FdpModelId = @FdpModelId
	AND
	FeatureId IS NULL
	AND
	FdpFeatureId IS NULL
	AND
	(@ParentFdpChangesetDataItemId IS NULL OR D.ParentFdpChangesetDataItemId <> @ParentFdpChangesetDataItemId OR D.FdpChangesetDataItemId <> @ParentFdpChangesetDataItemId)

	-- Always clear any feature mix entries

	UPDATE D SET IsDeleted = 1
	FROM Fdp_ChangesetDataItem AS D
	WHERE
	D.FdpChangesetId = @FdpChangesetId
	AND
	D.MarketId = @MarketId
	AND
	ModelId IS NULL
	AND
	FdpModelId IS NULL
	AND
	FeatureId = @FeatureId
	AND
	(@ParentFdpChangesetDataItemId IS NULL OR D.ParentFdpChangesetDataItemId <> @ParentFdpChangesetDataItemId OR D.FdpChangesetDataItemId <> @ParentFdpChangesetDataItemId)
	
	UPDATE D SET IsDeleted = 1
	FROM Fdp_ChangesetDataItem AS D
	WHERE
	D.FdpChangesetId = @FdpChangesetId
	AND
	D.MarketId = @MarketId
	AND
	ModelId IS NULL
	AND
	FdpModelId IS NULL
	AND
	FdpFeatureId = @FdpFeatureId
	AND
	(@ParentFdpChangesetDataItemId IS NULL OR D.ParentFdpChangesetDataItemId <> @ParentFdpChangesetDataItemId OR D.FdpChangesetDataItemId <> @ParentFdpChangesetDataItemId)

	UPDATE D SET IsDeleted = 1
	FROM Fdp_ChangesetDataItem AS D
	WHERE
	D.FdpChangesetId = @FdpChangesetId
	AND
	D.MarketId = @MarketId
	AND
	ModelId IS NULL
	AND
	FdpModelId IS NULL
	AND
	FeatureId IS NULL
	AND
	FeaturePackId = @FeaturePackId
	AND
	(@ParentFdpChangesetDataItemId IS NULL OR D.ParentFdpChangesetDataItemId <> @ParentFdpChangesetDataItemId OR D.FdpChangesetDataItemId <> @ParentFdpChangesetDataItemId)

	-- Clear any powertrain level changes

	UPDATE D SET IsDeleted = 1
	FROM Fdp_ChangesetDataItem AS D
	WHERE
	D.FdpChangesetId = @FdpChangesetId
	AND
	D.MarketId = @MarketId
	AND
	D.DerivativeCode IS NOT NULL
	AND
	(@ParentFdpChangesetDataItemId IS NULL OR D.ParentFdpChangesetDataItemId <> @ParentFdpChangesetDataItemId OR D.FdpChangesetDataItemId <> @ParentFdpChangesetDataItemId)

	INSERT INTO Fdp_ChangesetDataItem
	(
		  FdpChangesetId
		, MarketId
		, ModelId
		, FdpModelId
		, FeatureId
		, FdpFeatureId
		, FeaturePackId
		, DerivativeCode
		, TotalVolume
		, PercentageTakeRate
		, IsVolumeUpdate
		, IsPercentageUpdate
		, OriginalVolume
		, OriginalPercentageTakeRate
		, FdpVolumeDataItemId
		, FdpTakeRateSummaryId
		, FdpTakeRateFeatureMixId
		, FdpPowertrainDataItemId
		, ParentFdpChangesetDataItemId
	)
	VALUES
	(
		  @FdpChangesetId
		, @MarketId
		, @ModelId
		, @FdpModelId
		, @FeatureId
		, @FdpFeatureId
		, @FeaturePackId
		, @DerivativeCode
		, @TotalVolume
		, @PercentageTakeRate
		, @IsVolumeUpdate
		, @IsPercentageUpdate
		, @OriginalVolume
		, @OriginalPercentageTakeRate
		, @FdpVolumeDataItemId
		, @FdpTakeRateSummaryId
		, @FdpTakeRateFeatureMixId
		, @FdpPowertrainDataItemId
		, @ParentFdpChangesetDataItemId
	);
	
	SET @FdpChangesetDataItemId = SCOPE_IDENTITY();
	
	EXEC Fdp_ChangesetDataItem_Get @FdpChangesetDataItemId = @FdpChangesetDataItemId;