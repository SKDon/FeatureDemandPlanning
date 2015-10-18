
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
		, E.Error
		, E.ErrorOn
		
	FROM ImportQueue			AS Q
	JOIN ImportType				AS T	ON	Q.ImportTypeId		= T.ImportTypeId
	JOIN ImportStatus			AS S	ON	Q.ImportStatusId	= S.ImportStatusId
	LEFT JOIN ImportError_VW	AS E	ON	Q.ImportQueueId		= E.ImportQueueId;


