


CREATE VIEW [dbo].[Fdp_DerivativeMapping_VW] AS

	SELECT 
		  D.CreatedOn
		, D.CreatedBy
		, P.Id				AS ProgrammeId
		, D.Gateway			AS Gateway
		, D.BodyId			
		, D.EngineId		
		, D.TransmissionId 
		, D.BMC				AS ImportDerivativeCode
		, D.BMC				AS MappedDerivativeCode
		, CAST(0 AS BIT)	AS IsMappedDerivative
		, D.IsFdpDerivative
		, D.FdpDerivativeId
		, CAST(NULL AS INT)	AS FdpDerivativeMappingId
		, D.UpdatedOn
		, D.UpdatedBy
		
	FROM
	OXO_Programme					AS P
	JOIN Fdp_Derivative_VW			AS D	ON	P.Id				= D.ProgrammeId
											AND D.BMC				<> ''
	UNION
	
	SELECT 
		  M.CreatedOn
		, M.CreatedBy
		, P.Id						AS ProgrammeId
		, D.Gateway
		, D.BodyId
		, D.EngineId
		, D.TransmissionId
		, M.ImportDerivativeCode	AS ImportDerivativeCode
		, D.BMC						AS MappedDerivativeCode
		, CAST(1 AS BIT)			AS IsMappedDerivative
		, D.IsFdpDerivative
		, NULL						AS FdpDerivativeId
		, M.FdpDerivativeMappingId
		, M.UpdatedOn
		, M.UpdatedBy
		
	FROM
	OXO_Programme					AS P
	JOIN Fdp_Derivative_VW			AS D	ON	P.Id				= D.ProgrammeId
	JOIN Fdp_DerivativeMapping		AS M	ON	D.BMC				= M.DerivativeCode
											AND	D.ProgrammeId		= M.ProgrammeId
											AND D.Gateway			= M.Gateway
											AND	D.BodyId			= M.BodyId
											AND D.EngineId			= M.EngineId
											AND D.TransmissionId	= M.TransmissionId
											AND M.IsActive			= 1