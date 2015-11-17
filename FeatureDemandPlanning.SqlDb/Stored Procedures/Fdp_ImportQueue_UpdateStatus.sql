CREATE PROCEDURE [dbo].[Fdp_ImportQueue_UpdateStatus]
	  @ImportQueueId INT
	, @ImportStatusId INT = 1
AS

SET NOCOUNT ON

IF NOT EXISTS(SELECT TOP 1 1 FROM Fdp_ImportStatus WHERE FdpImportStatusId = @ImportStatusId)
	RAISERROR(N'Import status does not exist', 16, 1);
	
UPDATE Fdp_ImportQueue SET 
	  FdpImportStatusId = @ImportStatusId
	, UpdatedOn = GETDATE()
WHERE
FdpImportQueueId = @ImportQueueId;