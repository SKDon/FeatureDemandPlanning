CREATE PROCEDURE [dbo].[ImportQueue_UpdateStatus]
	  @ImportQueueId INT
	, @ImportStatusId INT = 1
AS

SET NOCOUNT ON

IF NOT EXISTS(SELECT TOP 1 1 FROM ImportStatus WHERE ImportStatusId = @ImportStatusId)
	RAISERROR(N'Import status does not exist', 16, 1);
	
UPDATE ImportQueue SET 
	  ImportStatusId = @ImportStatusId
	, UpdatedOn = GETDATE() 
WHERE
ImportQueueId = @ImportQueueId;

