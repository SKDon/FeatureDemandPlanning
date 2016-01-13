CREATE PROCEDURE [dbo].[Fdp_TakeRateDataItemNote_Save]
	  @FdpVolumeHeaderId INT
	, @MarketId INT = NULL
	, @MarketGroupId INT = NULL
	, @ModelId INT = NULL
	, @FdpModelId INT = NULL
	, @FeatureId INT = NULL
	, @FdpFeatureId INT = NULL
	, @CDSID NVARCHAR(16)
	, @Note NVARCHAR(MAX)
AS
	
	SET NOCOUNT ON;
	
	DECLARE @FdpVolumeDataItemId INT;
	DECLARE @FdpTakeRateSummaryId INT;
	
	IF @FeatureId IS NOT NULL OR @FdpFeatureId IS NOT NULL
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
		(@MarketGroupId IS NULL OR D.MarketGroupId = @MarketGroupId)
		AND
		(@ModelId IS NULL OR D.ModelId = @ModelId)
		AND
		(@FdpModelId IS NULL OR D.FdpModelId = @FdpModelId)
		AND
		(@FeatureId IS NULL OR D.FeatureId = @FeatureId)
		AND
		(@FdpFeatureId IS NULL OR D.FdpFeatureId = @FdpFeatureId)
		AND
		D.IsFeatureData = 1;
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
		--AND
		--(@MarketGroupId IS NULL OR S.MarketGroupId = @MarketGroupId)
		AND
		(@ModelId IS NULL OR S.ModelId = @ModelId)
		AND
		(@FdpModelId IS NULL OR S.FdpModelId = @FdpModelId)
	END
	
	IF @FdpVolumeDataItemId IS NOT NULL OR @FdpTakeRateSummaryId IS NOT NULL
	BEGIN
	
		INSERT INTO Fdp_TakeRateDataItemNote
		(
			  FdpTakeRateDataItemId
			, FdpTakeRateSummaryId
			, EnteredBy
			, Note
		)
		VALUES
		(
			  @FdpVolumeDataItemId
			, @FdpTakeRateSummaryId
			, @CDSID
			, LTRIM(RTRIM(@Note))
		);
		
		SELECT 
			  FdpTakeRateDataItemNoteId
			, FdpTakeRateDataItemId
			, FdpTakeRateSummaryId
			, EnteredOn
			, EnteredBy
			, Note
		FROM
		Fdp_TakeRateDataItemNote
		WHERE
		FdpTakeRateDataItemId = SCOPE_IDENTITY();
	END