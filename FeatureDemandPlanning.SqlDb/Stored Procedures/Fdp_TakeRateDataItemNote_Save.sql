CREATE PROCEDURE [dbo].[Fdp_TakeRateDataItemNote_Save]
	  @FdpVolumeHeaderId	INT
	, @MarketId				INT	= NULL
	, @MarketGroupId		INT = NULL
	, @ModelId				INT = NULL
	, @FdpModelId			INT = NULL
	, @FeatureId			INT = NULL
	, @FdpFeatureId			INT = NULL
	, @FeaturePackId		INT = NULL
	, @CDSID				NVARCHAR(16)
	, @Note					NVARCHAR(MAX)
AS
	
	SET NOCOUNT ON;

	DECLARE @FdpChangesetId AS INT;
	DECLARE @FdpChangesetDataItemId AS INT;

	SELECT @FdpChangesetId = dbo.fn_Fdp_Changeset_GetLatestByUser(@FdpVolumeHeaderId, @MarketId, @CDSID);

	IF @FdpChangesetId IS NULL
	BEGIN
		EXEC Fdp_Changeset_Save @FdpVolumeHeaderId, @MarketId, @CDSID, 0
	END;

	DECLARE @FdpVolumeDataItemId INT;
	DECLARE @FdpTakeRateSummaryId INT;
	DECLARE @FdpTakeRateFeatureMixId INT;
	
	IF (@FeatureId IS NOT NULL OR @FeaturePackId IS NOT NULL) AND @ModelId IS NOT NULL 
	BEGIN
		SELECT TOP 1 @FdpVolumeDataItemId = FdpVolumeDataItemId
		FROM
		Fdp_VolumeHeader			AS H
		JOIN Fdp_VolumeDataItem_VW	AS D ON H.FdpVolumeHeaderId = D.FdpVolumeHeaderId
		WHERE
		H.FdpVolumeHeaderId = @FdpVolumeHeaderId
		AND
		(@MarketId IS NULL OR D.MarketId = @MarketId)
		AND
		(@ModelId IS NULL OR D.ModelId = @ModelId)
		AND
		(@FeatureId IS NULL OR D.FeatureId = @FeatureId)
		AND
		(@FeaturePackId IS NULL OR D.FeaturePackId = @FeaturePackId)
		AND
		D.IsFeatureData = 1;
	END
	ELSE IF (@FeatureId IS NOT NULL OR @FeaturePackId IS NOT NULL) AND @ModelId IS NULL 
	BEGIN
		SELECT TOP 1 @FdpTakeRateFeatureMixId = FdpTakeRateFeatureMixId
		FROM
		Fdp_VolumeHeader			AS H
		JOIN Fdp_TakeRateFeatureMix	AS F ON H.FdpVolumeHeaderId = F.FdpVolumeHeaderId
		WHERE
		H.FdpVolumeHeaderId = @FdpVolumeHeaderId
		AND
		(@MarketId IS NULL OR F.MarketId = @MarketId)
		AND
		(@FeatureId IS NULL OR F.FeatureId = @FeatureId)
		AND
		(@FeaturePackId IS NULL OR F.FeaturePackId = @FeaturePackId)
	END
	ELSE
	BEGIN
		SELECT TOP 1 @FdpTakeRateSummaryId = FdpTakeRateSummaryId
		FROM
		Fdp_VolumeHeader			AS H
		JOIN Fdp_TakeRateSummary	AS S ON H.FdpVolumeHeaderId = S.FdpVolumeHeaderId
		WHERE
		H.FdpVolumeHeaderId = @FdpVolumeHeaderId
		AND
		(@MarketId IS NULL OR S.MarketId = @MarketId)
		AND
		(@ModelId IS NULL OR S.ModelId = @ModelId)
	END

	-- Add the note as a changeset item that will be incorporated into the dataset when merged

	EXEC Fdp_ChangesetDataItem_Save 
		  @FdpChangesetId
		, NULL
		, @MarketId
		, @ModelId
		, NULL
		, @FeatureId
		, NULL
		, @FeaturePackId
		, NULL
		, 0
		, 0
		, 0
		, 0
		, @FdpVolumeDataItemId
		, @FdpTakeRateSummaryId
		, @FdpTakeRateFeatureMixId
		, NULL
		, 0
		, 0
		, @CDSID
		, @Note

	SET @FdpChangesetDataItemId = SCOPE_IDENTITY();

	EXEC Fdp_ChangesetDataItem_Get @FdpChangesetDataItemId;