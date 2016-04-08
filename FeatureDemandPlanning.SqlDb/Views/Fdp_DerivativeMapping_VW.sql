








CREATE VIEW [dbo].[Fdp_DerivativeMapping_VW] AS

	SELECT 
		  DV.CreatedOn
		, DV.CreatedBy
		, D.Id				AS DocumentId
		, P.Id				AS ProgrammeId
		, DV.Gateway			AS Gateway
		, DV.BodyId			
		, DV.EngineId		
		, DV.TransmissionId 
		, DV.BMC				AS ImportDerivativeCode
		, DV.BMC				AS MappedDerivativeCode
		, CAST(CASE WHEN M.FdpDerivativeMappingId IS NOT NULL THEN 1 ELSE 0 END AS BIT)	AS IsMappedDerivative
		, DV.IsFdpDerivative
		, DV.FdpDerivativeId
		, CAST(NULL AS INT)	AS FdpDerivativeMappingId
		, DV.UpdatedOn
		, DV.UpdatedBy
		, DV.IsArchived
		, DV.Name
		
	FROM
	OXO_Doc								AS D
	JOIN OXO_Programme					AS P	ON	D.Programme_Id		= P.Id
	JOIN Fdp_Derivative_VW				AS DV	ON	D.Id				= DV.DocumentId
	LEFT JOIN Fdp_DerivativeMapping		AS M	ON	D.Id				= M.DocumentId
												AND	DV.BodyId			= M.BodyId
												AND DV.EngineId			= M.EngineId
												AND DV.TransmissionId	= M.TransmissionId
												AND M.IsActive			= 1
	WHERE
	P.Active = 1
	--AND
	--M.FdpDerivativeMappingId IS NULL

	UNION
	
	SELECT 
		  M.CreatedOn
		, M.CreatedBy
		, D.Id									AS DocumentId									
		, P.Id									AS ProgrammeId
		, D.Gateway
		, DV.BodyId
		, DV.EngineId
		, DV.TransmissionId
		, M.ImportDerivativeCode				AS ImportDerivativeCode
		, CASE 
			WHEN ISNULL(DV.BMC, '') <> '' THEN DV.BMC
			ELSE M.ImportDerivativeCode
		  END
		  AS MappedDerivativeCode
		, CAST(1 AS BIT)						AS IsMappedDerivative
		, DV.IsFdpDerivative
		, NULL									AS FdpDerivativeId
		, M.FdpDerivativeMappingId
		, M.UpdatedOn
		, M.UpdatedBy
		, DV.IsArchived
		, DV.Name
		
	FROM
	OXO_Doc							AS D
	JOIN OXO_Programme				AS P	ON	D.Programme_Id		= P.Id
	JOIN Fdp_Derivative_VW			AS DV	ON	D.Id				= DV.DocumentId
	JOIN Fdp_DerivativeMapping		AS M	ON	D.Id				= M.DocumentId
											AND	DV.BodyId			= M.BodyId
											AND DV.EngineId			= M.EngineId
											AND DV.TransmissionId	= M.TransmissionId
											AND M.IsActive			= 1
											--AND ISNULL(M.DerivativeCode, '')	<> ''
	WHERE
	P.Active = 1
	
GO