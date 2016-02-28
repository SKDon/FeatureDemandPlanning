CREATE PROCEDURE dbo.Fdp_Derivatives_Clone
	  @SourceFdpVolumeHeaderId		AS INT
	, @DestinationFdpVolumeHeaderId AS INT
	, @CDSId						AS NVARCHAR(16)
AS

	SET NOCOUNT ON;

	DECLARE @SourceProgrammeId AS INT;
	DECLARE @SourceGateway AS NVARCHAR(200);
	DECLARE @DestinationProgrammeId AS INT;
	DECLARE @DestinationGateway AS NVARCHAR(200);

	SELECT TOP 1 @SourceProgrammeId = ProgrammeId, @SourceGateway = Gateway
	FROM 
	Fdp_VolumeHeader_VW
	WHERE
	FdpVolumeHeaderId = @SourceFdpVolumeHeaderId;

	SELECT TOP 1 @DestinationProgrammeId = ProgrammeId, @DestinationGateway = Gateway
	FROM 
	Fdp_VolumeHeader_VW
	WHERE
	FdpVolumeHeaderId = @DestinationFdpVolumeHeaderId;

	-- We don't need to copy anything if it exists for the same programme

	IF @SourceProgrammeId = @DestinationProgrammeId AND @SourceGateway = @DestinationGateway
		RETURN;

	INSERT INTO Fdp_Derivative
	(
		  CreatedBy
		, ProgrammeId
		, Gateway
		, DerivativeCode
		, BodyId
		, EngineId
		, TransmissionId
		, OriginalFdpDerivativeId
	)
	SELECT
		  @CDSId
		, @DestinationProgrammeId
		, @DestinationGateway
		, DerivativeCode
		, BodyId
		, EngineId
		, TransmissionId
		, FdpDerivativeId
	FROM 
	Fdp_Derivative
	WHERE
	ProgrammeId = @SourceProgrammeId
	AND
	Gateway = @SourceGateway;