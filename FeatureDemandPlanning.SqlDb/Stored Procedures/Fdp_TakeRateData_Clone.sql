CREATE PROCEDURE dbo.Fdp_TakeRateData_Clone
	  @SourceFdpVolumeHeaderId	INT
	, @DestinationDocumentId	INT
	, @CDSId					NVARCHAR(16)
AS
	SET NOCOUNT ON;
	
	-- Clear any information that already exists for the document
	
	DECLARE @FdpVolumeHeaderId AS INT;
	SELECT @FdpVolumeHeaderId = dbo.fn_Fdp_LatestTakeRateFileByDocument_Get(@DestinationDocumentId);
	
	IF @FdpVolumeHeaderId IS NOT NULL
	BEGIN
		-- Clear all information from the current take rate file
		EXEC Fdp_TakeRateHeader_Clear @FdpVolumeHeaderId = @FdpVolumeHeaderId;
	END
	
	-- Create a new header entry
	
	INSERT INTO Fdp_VolumeHeader
	(
		  CreatedBy
		, DocumentId
		, IsManuallyEntered
		, TotalVolume
		, FdpTakeRateStatusId
	)
	SELECT 
		  @CDSId
		, @DestinationDocumentId
		, 0
		, H.TotalVolume
		, 1 -- WIP
	FROM
	Fdp_VolumeHeader AS H
	WHERE
	H.FdpVolumeHeaderId = @SourceFdpVolumeHeaderId;
	
	SET @FdpVolumeHeaderId = SCOPE_IDENTITY();
	
	-- Create a new version entry
	
	INSERT INTO Fdp_TakeRateVersion
	(
		  FdpTakeRateHeaderId
		, MajorVersion
		, MinorVersion
		, Revision
	)
	VALUES
	(
		  @FdpVolumeHeaderId
		, 0
		, 0
		, 1
	)
	
	-- Copy any data over
	
	INSERT INTO Fdp_VolumeDataItem
	(
		  CreatedBy
		, FdpVolumeHeaderId
		, IsManuallyEntered
		, MarketId
		, MarketGroupId
		, ModelId
		, FdpModelId
		, TrimId
		, FdpTrimId
		, FeatureId
		, FdpFeatureId
		, FeaturePackId
		, Volume
		, PercentageTakeRate
		, OriginalFdpVolumeDataItemId
	)
	SELECT
		  @CDSId
		, @FdpVolumeHeaderId
		, 0
		, D.MarketId
		, D.MarketGroupId
		, D.ModelId
		, D.FdpModelId
		, D.TrimId
		, D.FdpTrimId
		, D.FeatureId
		, D.FdpFeatureId
		, D.FeaturePackId
		, D.Volume
		, D.PercentageTakeRate
		, D.FdpVolumeDataItemId
	FROM
	Fdp_VolumeDataItem AS D
	WHERE
	D.FdpVolumeHeaderId = @SourceFdpVolumeHeaderId;
	
	INSERT INTO Fdp_TakeRateSummary
	(
		  CreatedBy
		, FdpVolumeHeaderId
		, FdpSpecialFeatureMappingId
		, MarketId
		, ModelId
		, FdpModelId
		, Volume
		, PercentageTakeRate
		, OriginalTakeRateSummaryId
	)
	SELECT
		  @CDSId
		, @FdpVolumeHeaderId
		, S.FdpSpecialFeatureMappingId
		, S.MarketId
		, S.ModelId
		, S.FdpModelId
		, S.Volume
		, S.PercentageTakeRate
		, S.FdpTakeRateSummaryId
	FROM
	Fdp_TakeRateSummary AS S
	WHERE
	S.FdpVolumeHeaderId = @SourceFdpVolumeHeaderId;
	
	INSERT INTO Fdp_TakeRateFeatureMix
	(
		  CreatedBy
		, FdpVolumeHeaderId
		, MarketId
		, FeatureId
		, FdpFeatureId
		, FeaturePackId
		, Volume
		, PercentageTakeRate
	)
	SELECT
		  @CDSId
		, @FdpVolumeHeaderId
		, F.MarketId
		, F.FeatureId
		, F.FdpFeatureId
		, F.FeaturePackId
		, F.Volume
		, F.PercentageTakeRate
	FROM
	Fdp_TakeRateFeatureMix AS F 
	WHERE
	F.FdpVolumeHeaderId = @SourceFdpVolumeHeaderId;
	
	INSERT INTO Fdp_PowertrainDataItem
	(
		  CreatedBy
		, FdpVolumeHeaderId
		, MarketId
		, BodyId
		, EngineId
		, TransmissionId
		, Volume
		, PercentageTakeRate
	)
	SELECT
		  @CDSId
		, @FdpVolumeHeaderId
		, P.MarketId
		, P.BodyId
		, P.EngineId
		, P.TransmissionId
		, P.Volume
		, P.PercentageTakeRate
	FROM
	Fdp_PowertrainDataItem AS P
	WHERE
	P.FdpVolumeHeaderId = @SourceFdpVolumeHeaderId
	
	-- Copy notes
	
	INSERT INTO Fdp_TakeRateDataItemNote
	(
		  FdpTakeRateDataItemId
		, EnteredOn
		, EnteredBy
		, Note
	)
	SELECT
		  D.FdpVolumeDataItemId
		, N.EnteredOn
		, N.EnteredBy
		, N.Note
	FROM
	Fdp_VolumeDataItem AS D
	JOIN Fdp_TakeRateDataItemNote AS N ON D.OriginalFdpVolumeDataItemId = N.FdpTakeRateDataItemId
	WHERE
	D.FdpVolumeHeaderId = @FdpVolumeHeaderId
	
	INSERT INTO Fdp_TakeRateDataItemNote
	(
		  FdpTakeRateSummaryId
		, EnteredOn
		, EnteredBy
		, Note
	)
	SELECT
		  S.FdpTakeRateSummaryId
		, N.EnteredOn
		, N.EnteredBy
		, N.Note
	FROM
	Fdp_TakeRateSummary AS S
	JOIN Fdp_TakeRateDataItemNote AS N ON S.OriginalTakeRateSummaryId = N.FdpTakeRateSummaryId
	WHERE
	S.FdpVolumeHeaderId = @FdpVolumeHeaderId;