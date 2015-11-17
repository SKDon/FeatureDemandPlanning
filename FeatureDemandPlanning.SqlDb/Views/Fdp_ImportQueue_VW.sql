




CREATE VIEW [dbo].[Fdp_ImportQueue_VW] AS

	SELECT 
		  Q.FdpImportQueueId
		, Q.CreatedOn
		, Q.CreatedBy
		, T.FdpImportTypeId
		, T.[Type]
		, S.FdpImportStatusId
		, S.[Status]
		, Q.OriginalFileName
		, Q.FilePath
		, Q.UpdatedOn
		, NULL AS Error
		, E1.ErrorOn
		
	FROM Fdp_ImportQueue			AS Q
	JOIN Fdp_ImportType				AS T	ON	Q.FdpImportTypeId	= T.FdpImportTypeId
	JOIN Fdp_ImportStatus			AS S	ON	Q.FdpImportStatusId	= S.FdpImportStatusId
	LEFT JOIN 
	(
		SELECT 
			  FdpImportQueueId
			, MAX(E.ErrorOn) AS ErrorOn
		FROM Fdp_ImportQueueError_VW AS E
		GROUP BY FdpImportQueueId
	)
	AS E1 ON Q.FdpImportQueueId = E1.FdpImportQueueId
	WHERE
	Q.FdpImportStatusId <> 5; -- Don't show cancelled items, as they have been cancelled by the system and should not be visible