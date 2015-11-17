CREATE PROCEDURE [dbo].[Fdp_ImportQueueError_Save]
	  @FdpImportQueueId INT
	, @Error NVARCHAR(MAX)
AS
	SET NOCOUNT ON;
	
	IF NOT EXISTS(SELECT TOP 1 1 FROM Fdp_ImportQueue WHERE FdpImportQueueId = @FdpImportQueueId)
		RAISERROR(N'Import item does not exist', 16, 1);
		
	INSERT INTO Fdp_ImportQueueError
	(
		  FdpImportQueueId
		, Error
	)
	VALUES
	(
		  @FdpImportQueueId
		, @Error
	)