CREATE PROCEDURE [dbo].[Fdp_Trim_Clone]
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

	INSERT INTO Fdp_Trim
	(
		  CreatedBy
		, ProgrammeId
		, Gateway
		, TrimName
		, TrimAbbreviation
		, TrimLevel
		, BMC
		, DPCK
		, OriginalFdpTrimId
	)
	SELECT
		  @CDSId
		, @DestinationProgrammeId
		, @DestinationGateway
		, TrimName
		, TrimAbbreviation
		, TrimLevel
		, BMC
		, DPCK
		, FdpTrimId
	FROM 
	Fdp_Trim
	WHERE
	ProgrammeId = @SourceProgrammeId
	AND
	Gateway = @SourceGateway
	AND
	IsActive = 1;