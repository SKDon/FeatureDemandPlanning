CREATE PROCEDURE [Fdp_DerivativeMapping_Save]
	  @ImportDerivativeCode NVARCHAR(20)
	, @ProgrammeId INT
	, @BodyId INT
	, @EngineId INT
	, @TransmissionId INT
AS
	SET NOCOUNT ON;
	
	IF NOT EXISTS(SELECT TOP 1 1 
				  FROM Fdp_DerivativeMapping 
				  WHERE 
				  ImportDerivativeCode = @ImportDerivativeCode
				  AND
				  ProgrammeId = @ProgrammeId
				  AND
				  BodyId = @BodyId
				  AND
				  EngineId = @EngineId
				  AND
				  TransmissionId = @TransmissionId)
				  
		INSERT INTO Fdp_DerivativeMapping
		(
			  ImportDerivativeCode
			, ProgrammeId
			, BodyId
			, EngineId
			, TransmissionId
		)
		VALUES
		(
			  @ImportDerivativeCode
			, @ProgrammeId
			, @BodyId
			, @EngineId
			, @TransmissionId
		);
		
	SELECT 
		  FdpDerivativeMappingId
		, ImportDerivativeCode
		, ProgrammeId
		, BodyId
		, EngineId
		, TransmissionId
		
	  FROM Fdp_DerivativeMapping 
	  WHERE 
	  ImportDerivativeCode = @ImportDerivativeCode
	  AND
	  ProgrammeId = @ProgrammeId
	  AND
	  BodyId = @BodyId
	  AND
	  EngineId = @EngineId
	  AND
	  TransmissionId = @TransmissionId;