CREATE PROCEDURE [dbo].[Fdp_ImportData_Process] 
	  @FdpImportId	INT
	, @LineNumber	INT = NULL -- No longer used
AS
	SET NOCOUNT ON;
	
	DECLARE @ProgrammeId		INT;
	DECLARE @Gateway			NVARCHAR(100);
	DECLARE @OxoDocId			INT;
	DECLARE @FdpVolumeHeaderId	INT;
	DECLARE @CDSId				NVARCHAR(16);
	DECLARE @FdpImportQueueId	INT;
	DECLARE @Message			NVARCHAR(400);
	DECLARE @ErrorCount AS INT;
	
	SELECT 
		  @ProgrammeId = ProgrammeId
		, @Gateway = Gateway
		, @OxoDocId = DocumentId
		, @FdpImportQueueId = FdpImportQueueId
	FROM Fdp_Import
	WHERE
	FdpImportId = @FdpImportId;
	
	-- Update the status of our import to be processing
	
	SET @Message = 'Setting import to processing...'
	RAISERROR(@Message, 0, 1) WITH NOWAIT;
	
	UPDATE Fdp_ImportQueue SET FdpImportStatusId = 2
	WHERE
	FdpImportQueueId = @FdpImportQueueId
	AND
	FdpImportStatusId IN (1, 4);
	
	UPDATE Fdp_Import SET Uploaded = 1 WHERE FdpImportQueueId = @FdpImportQueueId;
	
	-- Create exceptions of varying types based on the data that cannot be processed
	
	EXEC Fdp_ImportData_ProcessMissingMarkets @FdpImportId = @FdpImportId, @FdpImportQueueId = @FdpImportQueueId;
	
	EXEC Fdp_ImportData_ProcessMissingDerivatives @FdpImportId = @FdpImportId, @FdpImportQueueId = @FdpImportQueueId;
	
	EXEC Fdp_ImportData_ProcessMissingTrim @FdpImportId = @FdpImportId, @FdpImportQueueId = @FdpImportQueueId;
	
	EXEC Fdp_ImportData_ProcessMissingFeatures @FdpImportId = @FdpImportId, @FdpImportQueueId = @FdpImportQueueId;

	SELECT 
		@ErrorCount = COUNT(1) 
	FROM 
	Fdp_ImportError 
	WHERE 
	FdpImportQueueId = @FdpImportQueueId
	AND
	IsExcluded = 0;

	IF @ErrorCount > 0
	BEGIN
		EXEC Fdp_ImportQueue_UpdateStatus @ImportQueueId = @FdpImportQueueId, @ImportStatusId = 4
	END