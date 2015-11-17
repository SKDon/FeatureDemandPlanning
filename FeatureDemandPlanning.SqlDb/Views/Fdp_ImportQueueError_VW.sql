



CREATE VIEW [dbo].[Fdp_ImportQueueError_VW] AS

	SELECT 
		  E.FdpImportQueueId
		, E.FdpImportQueueErrorId
		, E.Error
		, E.ErrorOn
		
	FROM Fdp_ImportQueueError	AS E
	JOIN 
	(
		SELECT 
			  FdpImportQueueId
			, MAX(FdpImportQueueErrorId) AS FdpImportQueueErrorId
		FROM
		Fdp_ImportQueueError
		GROUP BY
		FdpImportQueueId
	)
	AS E1	ON E.FdpImportQueueErrorId = E1.FdpImportQueueErrorId