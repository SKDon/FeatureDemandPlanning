CREATE VIEW Fdp_Gateways_VW AS
	
	SELECT 
	  Programme_Id AS ProgrammeId
	, Gateway 
	FROM OXO_Doc 
	WHERE 
	[Status] = 'PUBLISHED'
	GROUP BY 
	  Programme_Id
	, Gateway