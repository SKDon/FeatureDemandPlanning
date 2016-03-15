



CREATE VIEW [dbo].[Fdp_DerivativeMapping_VW] AS

	SELECT 
		  D.CreatedOn
		, D.CreatedBy
		, D.DocumentId
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
		, D.IsArchived
		, D.Name
		
	FROM
	OXO_Programme					AS P
	JOIN Fdp_Derivative_VW			AS D	ON	P.Id				= D.ProgrammeId
	WHERE
	P.Active = 1
	AND
	ISNULL(D.BMC, '') <> ''

	UNION
	
	SELECT 
		  M.CreatedOn
		, M.CreatedBy
		, D.DocumentId
		, P.Id									AS ProgrammeId
		, D.Gateway
		, D.BodyId
		, D.EngineId
		, D.TransmissionId
		, M.ImportDerivativeCode				AS ImportDerivativeCode
		, CASE 
			WHEN ISNULL(D.BMC, '') <> '' THEN D.BMC
			ELSE M.ImportDerivativeCode
		  END
		  AS MappedDerivativeCode
		, CAST(1 AS BIT)						AS IsMappedDerivative
		, D.IsFdpDerivative
		, NULL									AS FdpDerivativeId
		, M.FdpDerivativeMappingId
		, M.UpdatedOn
		, M.UpdatedBy
		, D.IsArchived
		, D.Name
		
	FROM
	OXO_Programme					AS P
	JOIN Fdp_Derivative_VW			AS D	ON	P.Id				= D.ProgrammeId
	JOIN Fdp_DerivativeMapping		AS M	ON	D.DocumentId		= M.DocumentId
											AND	D.BodyId			= M.BodyId
											AND D.EngineId			= M.EngineId
											AND D.TransmissionId	= M.TransmissionId
											AND M.IsActive			= 1
											AND ISNULL(M.DerivativeCode, '')	<> ''
	WHERE
	P.Active = 1
	
GO