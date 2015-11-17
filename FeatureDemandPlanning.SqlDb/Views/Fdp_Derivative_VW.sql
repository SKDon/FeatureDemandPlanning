CREATE VIEW Fdp_Derivative_VW AS
	
	SELECT
		  D.Programme_Id			AS ProgrammeId
		, MAX(D.Created_On)			AS CreatedOn
		, MAX(D.Created_By)			AS CreatedBy
		, D.Body_Id					AS BodyId
		, D.Engine_Id				AS EngineId
		, D.Transmission_Id			AS TransmissionId
		, MAX(ISNULL(D.BMC, ''))	AS BMC
		, MAX(D.Last_Updated)		AS UpdatedOn
		, MAX(D.Updated_By)			AS UpdatedBy
	FROM
	OXO_Programme_Model				AS D
	JOIN OXO_Programme_Body			AS B ON D.Body_Id			= B.Id
	JOIN OXO_Programme_Engine		AS E ON D.Engine_Id			= E.Id
	JOIN OXO_Programme_Transmission AS T ON D.Transmission_Id	= T.Id
	GROUP BY
	  D.Programme_Id
	, D.Body_Id
	, D.Engine_Id
	, D.Transmission_Id