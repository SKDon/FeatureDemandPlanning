

CREATE VIEW [dbo].[ImportQueue_VW] AS

	SELECT 
		  Q.ImportQueueId
		, Q.CreatedOn
		, Q.CreatedBy
		, T.ImportTypeId
		, T.[Type]
		, S.ImportStatusId
		, S.[Status]
		, Q.FilePath
		, Q.UpdatedOn
		, NULL AS Error
		, E1.ErrorOn
		
	FROM ImportQueue			AS Q
	JOIN ImportType				AS T	ON	Q.ImportTypeId		= T.ImportTypeId
	JOIN ImportStatus			AS S	ON	Q.ImportStatusId	= S.ImportStatusId
	LEFT JOIN 
	(
		SELECT ImportQueueId, MAX(E.ErrorOn) AS ErrorOn
		FROM Fdp_ImportError_VW AS E
		GROUP BY ImportQueueId
	)
	AS E1 ON Q.ImportQueueId = E1.ImportQueueId;


