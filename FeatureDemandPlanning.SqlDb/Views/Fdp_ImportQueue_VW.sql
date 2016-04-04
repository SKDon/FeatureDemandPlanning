







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
		, E2.Error
		, E1.ErrorOn
		, I.FdpImportId
		, I.DocumentId
		, I.Uploaded
		
	FROM Fdp_ImportQueue			AS Q
	JOIN Fdp_ImportType				AS T	ON	Q.FdpImportTypeId	= T.FdpImportTypeId
	JOIN Fdp_ImportStatus			AS S	ON	Q.FdpImportStatusId	= S.FdpImportStatusId
	JOIN Fdp_Import					AS I	ON	Q.FdpImportQueueId	= I.FdpImportId
	LEFT JOIN 
	(
		SELECT 
			  FdpImportQueueId
			, MAX(E.FdpImportQueueErrorId) AS FdpImportQueueErrorId
			, MAX(E.ErrorOn) AS ErrorOn
		FROM Fdp_ImportQueueError_VW AS E
		GROUP BY FdpImportQueueId
	)
	AS E1 ON Q.FdpImportQueueId = E1.FdpImportQueueId
	LEFT JOIN Fdp_ImportQueueError_VW AS E2 ON E1.FdpImportQueueErrorId = E2.FdpImportQueueErrorId
	WHERE
	Q.FdpImportStatusId <> 5; -- Don't show cancelled items, as they have been cancelled by the system and should not be visible