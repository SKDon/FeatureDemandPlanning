CREATE PROCEDURE [dbo].[Fdp_ImportQueueError_GetMany]
	@FdpImportQueueId INT = NULL
AS
	SET NOCOUNT ON;
	
	SELECT
		  E.FdpImportQueueId
		, E.FdpImportQueueErrorId
		, E.Error
		, E.ErrorOn
		
	FROM Fdp_ImportQueueError_VW AS E
	WHERE
	(@FdpImportQueueId IS NULL OR E.FdpImportQueueId = @FdpImportQueueId)
	ORDER BY
	E.FdpImportQueueErrorId DESC;