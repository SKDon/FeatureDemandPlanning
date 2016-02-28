CREATE PROCEDURE dbo.Fdp_Model_Clone
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

	INSERT INTO Fdp_Model
	(
		  CreatedBy
		, ProgrammeId
		, Gateway
		, DerivativeCode
		, FdpDerivativeId
		, TrimId
		, FdpTrimId
		, OriginalFdpModelId
	)
	SELECT
		  @CDSId
		, @DestinationProgrammeId
		, @DestinationGateway
		, M.DerivativeCode
		, ISNULL(ND.FdpDerivativeId, M.FdpDerivativeId)
		, TrimId
		, ISNULL(NT.FdpTrimId, M.FdpTrimId)
		, FdpModelId
	FROM 
	Fdp_Model					AS M
	LEFT JOIN Fdp_Derivative	AS ND	ON	M.FdpDerivativeId	= ND.OriginalFdpDerivativeId
	LEFT JOIN Fdp_Trim			AS NT	ON	M.FdpTrimId			= NT.OriginalFdpTrimId
	WHERE
	M.ProgrammeId = @SourceProgrammeId
	AND
	M.Gateway = @SourceGateway;