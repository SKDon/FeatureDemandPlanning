CREATE PROCEDURE Fdp_OxoDerivative_Get
	@FdpOxoDerivativeId	AS INT
AS

	SET NOCOUNT ON;

	SELECT
		  FdpOxoDerivativeId
		, DocumentId
		, ProgrammeId
		, Gateway
		, DerivativeCode
		, BodyId
		, EngineId
		, TransmissionId
		, IsArchived
	FROM
	Fdp_OxoDerivative
	WHERE
	FdpOxoDerivativeId = @FdpOxoDerivativeId