

CREATE VIEW [dbo].[Fdp_Gateways_VW] AS
	
	SELECT 
	  Programme_Id AS ProgrammeId
	, Gateway
	, ISNULL(Archived, 0) AS IsArchived 
	FROM OXO_Doc
	CROSS APPLY
	(
		SELECT CAST(Value AS BIT) AS ShowAllOxoDocuments
		FROM Fdp_Configuration
		WHERE
		ConfigurationKey = 'SHOWALLOXODOCUMENTS'
	)
	AS C
	WHERE
	(
		C.ShowAllOxoDocuments = 1
		OR
		(C.ShowAllOxoDocuments = 0 AND [Status] = 'PUBLISHED')
	)
	GROUP BY 
	  Programme_Id
	, Gateway
	, Archived