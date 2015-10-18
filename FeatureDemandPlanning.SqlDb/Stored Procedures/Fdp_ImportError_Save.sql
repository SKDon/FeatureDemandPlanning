CREATE PROCEDURE [dbo].[Fdp_ImportError_Save]
	  @ImportQueueId		INT
	, @LineNumber			INT
	, @ErrorOn				DATETIME
	, @FdpImportErrorTypeId INT
	, @Error				NVARCHAR(MAX)
AS
	SET NOCOUNT ON;
	
	IF NOT EXISTS(SELECT TOP 1 1 FROM ImportQueue WHERE ImportQueueId = @ImportQueueId)
		RAISERROR(N'Import item does not exist', 16, 1);
		
	INSERT INTO Fdp_ImportError
	(
		  ImportQueueId
		, LineNumber
		, ErrorOn
		, FdpImportErrorTypeId
		, ErrorMessage
	)
	VALUES
	(
		  @ImportQueueId
		, @LineNumber
		, @ErrorOn
		, @FdpImportErrorTypeId
		, @Error
	)