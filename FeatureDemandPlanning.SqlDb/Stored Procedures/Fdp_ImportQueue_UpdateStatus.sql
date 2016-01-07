CREATE PROCEDURE [dbo].[Fdp_ImportQueue_UpdateStatus]
	  @ImportQueueId INT
	, @ImportStatusId INT = 1
	, @ErrorMessage NVARCHAR(MAX) = NULL
AS

SET NOCOUNT ON

IF NOT EXISTS(SELECT TOP 1 1 FROM Fdp_ImportStatus WHERE FdpImportStatusId = @ImportStatusId)
	RAISERROR(N'Import status does not exist', 16, 1);
	
UPDATE Fdp_ImportQueue SET 
	  FdpImportStatusId = @ImportStatusId
	, UpdatedOn = GETDATE()
WHERE
FdpImportQueueId = @ImportQueueId
AND
FdpImportStatusId <> @ImportStatusId;

IF @ErrorMessage IS NOT NULL
BEGIN
	INSERT INTO Fdp_ImportQueueError
	(
		  ErrorOn
		, ErrorBy
		, FdpImportQueueId
		, Error
	)
	SELECT
		  GETDATE()
		, I.CreatedBy
		, I.FdpImportQueueId
		, @ErrorMessage
	FROM
	Fdp_Import AS I
	WHERE
	I.FdpImportQueueId = @ImportQueueId;
END

EXEC Fdp_ImportQueue_Get @FdpImportQueueId = @ImportQueueId;