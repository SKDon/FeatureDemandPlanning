CREATE PROCEDURE [dbo].[Fdp_DerivativeMapping_Get]
	@FdpDerivativeMappingId INT
AS
	SET NOCOUNT ON;
	
	SELECT 
	  MAP.FdpDerivativeMappingId
	, MAP.ImportDerivativeCode
	, MAP.DocumentId
	, MAP.ProgrammeId
	, MAP.Gateway
	, MAP.DerivativeCode
	, MAP.BodyId
	, MAP.EngineId
	, MAP.TransmissionId
	, MAP.CreatedOn
	, MAP.CreatedBy
	, MAP.IsActive
	, MAP.UpdatedOn
	, MAP.UpdatedBy

	FROM Fdp_DerivativeMapping AS MAP
	WHERE 
	MAP.FdpDerivativeMappingId = @FdpDerivativeMappingId;