

CREATE VIEW [dbo].[ImportError_VW] AS

	SELECT 
		  E.ImportQueueId
		, E.ImportErrorId
		, E.Error
		, E.ErrorOn
		
	FROM ImportError	AS E
	JOIN 
	(
		SELECT 
			  ImportQueueId
			, MAX(ImportErrorId) AS ImportErrorId
		FROM
		ImportError
		GROUP BY
		ImportQueueId
	)
	AS E1	ON E.ImportErrorId = E1.ImportErrorId 


