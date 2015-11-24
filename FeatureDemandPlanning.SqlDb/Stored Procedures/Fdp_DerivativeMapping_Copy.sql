CREATE PROCEDURE [dbo].[Fdp_DerivativeMapping_Copy] 
	  @FdpDerivativeMappingId INT
	, @Gateways NVARCHAR(MAX)
	, @CDSId NVARCHAR(16)
AS
	SET NOCOUNT ON;
	
	DECLARE @GatewayList AS TABLE
	(
		Gateway NVARCHAR(100)
	)
	INSERT INTO @GatewayList
	SELECT * FROM dbo.FN_SPLIT_MODEL_IDS(@Gateways) -- Use model-ids as the function does what we need
	
	INSERT INTO Fdp_DerivativeMapping
	(
		  CreatedBy
		, ProgrammeId
		, Gateway
		, ImportDerivativeCode
		, DerivativeCode
		, BodyId
		, EngineId
		, TransmissionId
	)
	SELECT 
		  @CDSId
		, M.ProgrammeId
		, G.Gateway
		, M.ImportDerivativeCode
		, M.DerivativeCode
		, M.BodyId
		, M.EngineId
		, M.TransmissionId
	FROM
	Fdp_DerivativeMapping			AS M 
	CROSS APPLY @GatewayList		AS G
	LEFT JOIN Fdp_DerivativeMapping	AS EXISTING ON	M.ImportDerivativeCode	= EXISTING.ImportDerivativeCode
												AND M.DerivativeCode			= EXISTING.DerivativeCode
												AND M.ProgrammeId		= EXISTING.ProgrammeId
												AND G.Gateway			= EXISTING.Gateway
	WHERE
	M.FdpDerivativeMappingId = @FdpDerivativeMappingId
	AND 
	EXISTING.FdpDerivativeMappingId IS NULL