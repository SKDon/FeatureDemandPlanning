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
	, @CDSId						AS NVARCHAR(16)		= NULL
	, @Note							AS NVARCHAR(MAX)	= NULL
AS
	SET NOCOUNT ON;
	
	DECLARE @FdpChangesetDataItemId AS INT;
	DECLARE @FdpVolumeHeaderId AS INT;
	DECLARE @ItemsToDelete AS TABLE
	(
		FdpChangesetDataItemId INT
	)

	SELECT TOP 1 @FdpVolumeHeaderId = FdpVolumeHeaderId FROM Fdp_Changeset WHERE FdpChangesetId = @FdpChangesetId AND @MarketId IS NULL;

	-- If an item already exists we must delete it, rather than update
	-- Any changes need to be applied from the changeset sequentially, so that any calculations are 
	-- performed in the correct order. New changes are appended to the changeset

	INSERT INTO @ItemsToDelete (FdpChangesetDataItemId)
	
	SELECT FdpChangesetDataItemId
	FROM
	Fdp_ChangesetDataItem AS D
	WHERE
	D.FdpChangesetId = @FdpChangesetId
	AND
	D.FdpVolumeHeaderId = @FdpVolumeHeaderId
	AND
	@FdpVolumeHeaderId IS NOT NULL

	UNION

	SELECT FdpChangesetDataItemId
	FROM
	Fdp_ChangesetDataItem AS D
	WHERE
	D.FdpChangesetId = @FdpChangesetId
	AND
	D.FdpVolumeDataItemId = @FdpVolumeDataItemId
	AND
	@FdpVolumeDataItemId IS NOT NULL
	AND
	D.Note IS NULL -- Do not delete notes for data items

	UNION

	SELECT FdpChangesetDataItemId
	FROM
	Fdp_ChangesetDataItem AS D
	WHERE
	D.FdpChangesetId = @FdpChangesetId
	AND
	D.FdpTakeRateSummaryId = @FdpTakeRateSummaryId
	AND
	@FdpTakeRateSummaryId IS NOT NULL
	AND
	D.Note IS NULL -- Do not delete notes for summary items

	UNION

	SELECT FdpChangesetDataItemId
	FROM
	Fdp_ChangesetDataItem AS D
	WHERE
	D.FdpChangesetId = @FdpChangesetId
	AND
	D.FdpTakeRateFeatureMixId = @FdpTakeRateFeatureMixId
	AND
	@FdpTakeRateFeatureMixId IS NOT NULL

	UNION

	SELECT FdpChangesetDataItemId
	FROM
	Fdp_ChangesetDataItem AS D
	WHERE
	D.FdpChangesetId = @FdpChangesetId
	AND
	D.FdpPowertrainDataItemId = @FdpPowertrainDataItemId
	AND
	@FdpPowertrainDataItemId IS NOT NULL

	UPDATE D SET IsDeleted = 1
	FROM Fdp_ChangesetDataItem AS D
	JOIN
	@ItemsToDelete AS D1 ON D.FdpChangesetDataItemId = D1.FdpChangesetDataItemId;

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
		, CreatedBy
		, FdpVolumeHeaderId
		, Note
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
		, @CDSId
		, CASE WHEN @MarketId IS NULL THEN @FdpVolumeHeaderId ELSE NULL END
		, LTRIM(RTRIM(@Note))
	);
	
	SET @FdpChangesetDataItemId = SCOPE_IDENTITY();
	
	EXEC Fdp_ChangesetDataItem_Get @FdpChangesetDataItemId = @FdpChangesetDataItemId;