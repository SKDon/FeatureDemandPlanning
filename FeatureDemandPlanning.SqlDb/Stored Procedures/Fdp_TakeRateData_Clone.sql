CREATE PROCEDURE [dbo].[Fdp_TakeRateData_Clone]
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
	
	-- Copy and FDP specific models, derivatives, trim levels and features
	-- We will then replace the data items with the new identifiers as necessary
	
	EXEC Fdp_Derivative_Clone 
		@SourceFdpVolumeHeaderId		= @SourceFdpVolumeHeaderId, 
		@DestinationFdpVolumeHeaderId	= @FdpVolumeHeaderId, 
		@CDSId							= @CDSId;
		
	EXEC Fdp_Trim_Clone
		@SourceFdpVolumeHeaderId		= @SourceFdpVolumeHeaderId, 
		@DestinationFdpVolumeHeaderId	= @FdpVolumeHeaderId, 
		@CDSId							= @CDSId;
	
	EXEC Fdp_Model_Clone
		@SourceFdpVolumeHeaderId		= @SourceFdpVolumeHeaderId, 
		@DestinationFdpVolumeHeaderId	= @FdpVolumeHeaderId, 
		@CDSId							= @CDSId;
	
	EXEC Fdp_Feature_Clone
		@SourceFdpVolumeHeaderId		= @SourceFdpVolumeHeaderId, 
		@DestinationFdpVolumeHeaderId	= @FdpVolumeHeaderId, 
		@CDSId							= @CDSId;
	
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
		, ISNULL(M.FdpModelId, D.FdpModelId)
		, D.TrimId
		, ISNULL(T.FdpTrimId, D.FdpTrimId)
		, D.FeatureId
		, ISNULL(F.FdpFeatureId, D.FdpFeatureId)
		, D.FeaturePackId
		, D.Volume
		, D.PercentageTakeRate
		, D.FdpVolumeDataItemId
	FROM
	Fdp_VolumeHeader_VW		AS H
	JOIN Fdp_VolumeDataItem	AS D	ON	H.FdpVolumeHeaderId = D.FdpVolumeHeaderId
	LEFT JOIN Fdp_Model		AS M	ON	D.FdpModelId		= M.OriginalFdpModelId
									AND H.ProgrammeId		= M.ProgrammeId
									AND H.Gateway			= M.Gateway
									AND D.FdpModelId		IS NOT NULL
	LEFT JOIN Fdp_Trim		AS T	ON	D.FdpTrimId			= T.OriginalFdpTrimId
									AND H.ProgrammeId		= M.ProgrammeId
									AND H.Gateway			= M.Gateway
									AND D.FdpTrimId			IS NOT NULL
	LEFT JOIN Fdp_Feature	AS F	ON	D.FdpFeatureId		= F.OriginalFdpFeatureId
									AND H.ProgrammeId		= M.ProgrammeId
									AND H.Gateway			= M.Gateway
									AND F.FdpFeatureId		IS NOT NULL
	WHERE
	H.FdpVolumeHeaderId = @SourceFdpVolumeHeaderId;
	
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
		, ISNULL(M.FdpModelId, S.FdpModelId)
		, S.Volume
		, S.PercentageTakeRate
		, S.FdpTakeRateSummaryId
	FROM
	Fdp_VolumeHeader_VW			AS H
	JOIN Fdp_TakeRateSummary	AS S	ON	H.FdpVolumeHeaderId  = S.FdpVolumeHeaderId
	LEFT JOIN Fdp_Model			AS M	ON	S.FdpModelId		= M.OriginalFdpModelId
										AND H.ProgrammeId		= M.ProgrammeId
										AND H.Gateway			= M.Gateway
										AND S.FdpModelId		IS NOT NULL
	WHERE
	H.FdpVolumeHeaderId = @SourceFdpVolumeHeaderId;
	
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
		, ISNULL(F1.FdpFeatureId, F.FdpFeatureId)
		, F.FeaturePackId
		, F.Volume
		, F.PercentageTakeRate
	FROM
	Fdp_VolumeHeader_VW			AS H
	JOIN Fdp_TakeRateFeatureMix AS F	ON	H.FdpVolumeHeaderId = F.FdpVolumeHeaderId
	LEFT JOIN Fdp_Feature		AS F1	ON	F.FdpFeatureId		= F1.OriginalFdpFeatureId
										AND H.ProgrammeId		= F1.ProgrammeId
										AND H.Gateway			= F1.Gateway
										AND F.FdpFeatureId		IS NOT NULL
	WHERE
	H.FdpVolumeHeaderId = @SourceFdpVolumeHeaderId;
	
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