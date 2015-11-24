
CREATE VIEW [dbo].[Fdp_DerivativeMapping_VW] AS

	SELECT 
		  D.CreatedOn
		, D.CreatedBy
		, P.Id				AS ProgrammeId
		, G.Gateway			AS Gateway
		, D.BodyId			
		, D.EngineId		
		, D.TransmissionId 
		, D.BMC				AS ImportDerivativeCode
		, D.BMC				AS MappedDerivativeCode
		, CAST(0 AS BIT)	AS IsMappedDerivative
		, NULL				AS FdpDerivativeMappingId
		, D.UpdatedOn
		, D.UpdatedBy
		
	FROM
	OXO_Programme					AS P
	JOIN Fdp_Gateways_VW			AS G	ON	P.Id				= G.ProgrammeId
	JOIN Fdp_Derivative_VW			AS D	ON	P.Id				= D.ProgrammeId
											AND D.BMC				<> ''
	--LEFT JOIN Fdp_DerivativeMapping	AS M	ON	P.Id				= M.ProgrammeId
	--										AND G.Gateway			= M.Gateway
	--										AND	D.BodyId			= M.BodyId
	--										AND D.EngineId			= M.EngineId
	--										AND D.TransmissionId	= M.TransmissionId
	--										AND M.IsActive			= 1
	--WHERE
	--M.FdpDerivativeMappingId IS NULL
	
	UNION
	
	SELECT 
		  M.CreatedOn
		, M.CreatedBy
		, P.Id						AS ProgrammeId
		, M.Gateway
		, D.BodyId
		, D.EngineId
		, D.TransmissionId
		, M.ImportDerivativeCode	AS ImportDerivativeCode
		, D.BMC						AS MappedDerivativeCode
		, CAST(1 AS BIT)			AS IsMappedDerivative
		, M.FdpDerivativeMappingId
		, M.UpdatedOn
		, M.UpdatedBy
		
	FROM
	OXO_Programme					AS P
	JOIN Fdp_Gateways_VW			AS G	ON  P.Id				= G.ProgrammeId
	JOIN Fdp_Derivative_VW			AS D	ON	P.Id				= D.ProgrammeId
	JOIN Fdp_DerivativeMapping		AS M	ON	D.BMC				= M.DerivativeCode
											AND	D.ProgrammeId		= M.ProgrammeId
											AND G.Gateway			= M.Gateway
											AND	D.BodyId			= M.BodyId
											AND D.EngineId			= M.EngineId
											AND D.TransmissionId	= M.TransmissionId
											AND M.IsActive			= 1