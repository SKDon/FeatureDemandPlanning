CREATE PROCEDURE [dbo].[Fdp_Derivative_GetMappedBMC] 
	  @ProgrammeId	INT
	, @Gateway		NVARCHAR(100)
	, @ImportBMC	NVARCHAR(10)
AS
	SET NOCOUNT ON;
	
	SELECT TOP 1
		  ProgrammeId
		, Gateway 
	 	, ImportDerivativeCode AS ImportBmc
		, MappedDerivativeCode AS Bmc
		
	FROM Fdp_DerivativeMapping_VW
	WHERE
	ProgrammeId = @ProgrammeId
	AND
	Gateway = @Gateway
	AND
	ImportDerivativeCode = @ImportBMC;