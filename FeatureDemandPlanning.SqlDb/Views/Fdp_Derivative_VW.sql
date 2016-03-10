


CREATE VIEW [dbo].[Fdp_Derivative_VW] AS
	
	SELECT
		  O.Id						AS DocumentId
		, O.Programme_Id			AS ProgrammeId
		, G.Gateway
		, MAX(D.Created_On)			AS CreatedOn
		, MAX(D.Created_By)			AS CreatedBy
		, D.Body_Id					AS BodyId
		, D.Engine_Id				AS EngineId
		, D.Transmission_Id			AS TransmissionId
		, MAX(ISNULL(D.BMC, ''))	AS BMC
		, MAX(D.Last_Updated)		AS UpdatedOn
		, MAX(D.Updated_By)			AS UpdatedBy
		, CAST(0 AS BIT)			AS IsFdpDerivative
		, NULL						AS FdpDerivativeId
		, CAST(0 AS BIT)			AS IsArchived
		
	FROM
	OXO_Doc							AS O
	JOIN OXO_Programme_Model		AS D	ON O.Programme_Id		= D.Programme_Id
											AND D.Active			= 1
	JOIN Fdp_Gateways_VW			AS G	ON D.Programme_Id		= G.ProgrammeId
											AND G.IsArchived		= 0
	JOIN OXO_Programme_Body			AS B	ON D.Body_Id			= B.Id
											AND B.Active			= 1
	JOIN OXO_Programme_Engine		AS E	ON D.Engine_Id			= E.Id
											AND E.Active			= 1
	JOIN OXO_Programme_Transmission AS T	ON D.Transmission_Id	= T.Id
											AND T.Active			= 1
	WHERE
	D.Active = 1
	AND
	ISNULL(O.Archived, 0) = 0
	GROUP BY
	  O.Id
	, O.Programme_Id
	, G.Gateway
	, D.Body_Id
	, D.Engine_Id
	, D.Transmission_Id
	
	UNION

	SELECT
		  O.Id						AS DocumentId
		, O.Programme_Id			AS ProgrammeId
		, G.Gateway
		, MAX(D.Created_On)			AS CreatedOn
		, MAX(D.Created_By)			AS CreatedBy
		, D.Body_Id					AS BodyId
		, D.Engine_Id				AS EngineId
		, D.Transmission_Id			AS TransmissionId
		, MAX(ISNULL(D.BMC, ''))	AS BMC
		, MAX(D.Last_Updated)		AS UpdatedOn
		, MAX(D.Updated_By)			AS UpdatedBy
		, CAST(0 AS BIT)			AS IsFdpDerivative
		, NULL						AS FdpDerivativeId
		, CAST(1 AS BIT)			AS IsArchived
	FROM
	OXO_Doc										AS O
	JOIN OXO_Archived_Programme_Model			AS D	ON	O.Id				= D.Doc_Id
														AND D.Active			= 1
	JOIN Fdp_Gateways_VW						AS G	ON	D.Programme_Id		= G.ProgrammeId
														AND G.IsArchived		= 1
	JOIN OXO_Archived_Programme_Body			AS B	ON	D.Body_Id			= B.Id
														AND B.Active			= 1
	JOIN OXO_Archived_Programme_Engine			AS E	ON	D.Engine_Id			= E.Id
														AND E.Active			= 1
	JOIN OXO_Archived_Programme_Transmission	AS T	ON	D.Transmission_Id	= T.Id
														AND T.Active			= 1
	WHERE
	O.Archived = 1
	GROUP BY
	  O.Id
	, O.Programme_Id
	, G.Gateway
	, D.Body_Id
	, D.Engine_Id
	, D.Transmission_Id

	UNION
	
	SELECT
		  O.Id AS DocumentId 
		, D.ProgrammeId
		, D.Gateway
		, D.CreatedOn
		, D.CreatedBy
		, D.BodyId
		, D.EngineId
		, D.TransmissionId
		, D.DerivativeCode	AS BMC
		, D.UpdatedOn
		, D.UpdatedBy
		, CAST(1 AS BIT) AS IsFdpDerivative
		, D.FdpDerivativeId
		, CAST(0 AS BIT) AS IsArchived
	FROM 
	OXO_Doc							AS O
	JOIN Fdp_Derivative				AS D	ON O.Programme_Id	= D.ProgrammeId
											AND O.Gateway		= D.Gateway
											AND D.IsActive		= 1
	JOIN OXO_Programme_Body			AS B	ON D.BodyId			= B.Id
											AND B.Active		= 1
	JOIN OXO_Programme_Engine		AS E	ON D.EngineId		= E.Id
											AND E.Active		= 1
	JOIN OXO_Programme_Transmission AS T	ON D.TransmissionId	= T.Id
											AND T.Active		= 1
	WHERE
	D.IsActive = 1