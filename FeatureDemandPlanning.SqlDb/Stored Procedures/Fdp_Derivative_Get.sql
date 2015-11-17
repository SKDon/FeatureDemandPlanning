CREATE PROCEDURE [dbo].[Fdp_Derivative_Get] 
	@FdpDerivativeId INT
AS
	SET NOCOUNT ON;

	SELECT 
		  FdpDerivativeId
		, ProgrammeId
		, Gateway
		, DerivativeCode
		, BodyId
		, EngineId
		, TransmissionId
		, CreatedOn
		, CreatedBy
		, UpdatedOn
		, UpdatedBy
		, IsActive

	FROM Fdp_Derivative
	WHERE 
	FdpDerivativeId = @FdpDerivativeId;