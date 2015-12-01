
CREATE VIEW [dbo].[Fdp_Derivative_VW] AS
	
	SELECT
		  D.Programme_Id			AS ProgrammeId
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
		
	FROM
	OXO_Programme_Model				AS D
	JOIN Fdp_Gateways_VW			AS G	ON D.Programme_Id		= G.ProgrammeId
	JOIN OXO_Programme_Body			AS B	ON D.Body_Id			= B.Id
	JOIN OXO_Programme_Engine		AS E	ON D.Engine_Id			= E.Id
	JOIN OXO_Programme_Transmission AS T	ON D.Transmission_Id	= T.Id
	GROUP BY
	  D.Programme_Id
	, G.Gateway
	, D.Body_Id
	, D.Engine_Id
	, D.Transmission_Id
	
	UNION
	
	SELECT 
		  D.ProgrammeId
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
		
	FROM Fdp_Derivative				AS D
	JOIN OXO_Programme_Body			AS B	ON D.BodyId			= B.Id
	JOIN OXO_Programme_Engine		AS E	ON D.EngineId		= E.Id
	JOIN OXO_Programme_Transmission AS T	ON D.TransmissionId	= T.Id
	WHERE
	D.IsActive = 1