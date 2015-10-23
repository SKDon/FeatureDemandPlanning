CREATE PROCEDURE Fdp_DerivativeMapping_GetMany
	@ProgrammeId INT
AS
	SET NOCOUNT ON;
		
	SELECT 
		  FdpDerivativeMappingId
		, ImportDerivativeCode
		, ProgrammeId
		, BodyId
		, EngineId
		, TransmissionId
		
	  FROM Fdp_DerivativeMapping 
	  WHERE 
	  ProgrammeId = @ProgrammeId
	  ORDER BY
	  ImportDerivativeCode