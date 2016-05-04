CREATE PROCEDURE [dbo].[Fdp_ImportData_RemoveRedundantData]
	@FdpImportId AS INT,
	@FdpImportQueueId AS INT
AS
	SET NOCOUNT ON;
	
	DECLARE @Message AS NVARCHAR(MAX);
	DECLARE @OxoDocId AS INT;
	DECLARE @NoOfImportsCancelled AS INT = 0;
	
	SELECT TOP 1 @OxoDocId = DocumentId FROM Fdp_Import WHERE FdpImportId = @FdpImportId AND FdpImportQueueId = @FdpImportQueueId;
	
	-- Update all prior queued imports for the same document setting the status to cancelled

	SET @Message = 'Cancelling old imports...'
	RAISERROR(@Message, 0, 1) WITH NOWAIT
	
	-- Determine which import items to remove
	
	DECLARE @ImportItems AS TABLE
	(
		  FdpImportId INT NULL
		, FdpImportQueueId INT
	)
	INSERT INTO @ImportItems
	(
		  FdpImportId
		, FdpImportQueueId
	)
	SELECT
		  I.FdpImportId
		, I.FdpImportQueueId
	FROM Fdp_ImportQueue	AS Q
	JOIN Fdp_Import			AS I ON Q.FdpImportQueueId = I.FdpImportQueueId
	WHERE
	I.DocumentId = @OxoDocId
	AND
	Q.FdpImportQueueId <> @FdpImportQueueId
	AND
	Q.FdpImportStatusId IN (1, 4, 5) -- Queued or error
	
	UNION
	
	SELECT
		  NULL
		, Q.FdpImportQueueId
	FROM Fdp_ImportQueue	AS Q
	LEFT JOIN Fdp_Import			AS I ON Q.FdpImportQueueId = I.FdpImportQueueId
	WHERE
	I.FdpImportId IS NULL
	
	SET @NoOfImportsCancelled = @@ROWCOUNT;
	
	UPDATE Q 
		SET FdpImportStatusId = 5 -- Cancelled
	FROM Fdp_ImportQueue	AS Q
	JOIN @ImportItems		AS I ON Q.FdpImportQueueId = I.FdpImportQueueId
	
	-- Remove any errors associated with the redundant data
	
	DELETE FROM Fdp_ImportError
	WHERE
	FdpImportQueueId IN (
		SELECT FdpImportQueueId FROM @ImportItems
	);
	
	DELETE FROM Fdp_ImportQueueError
	WHERE
	FdpImportQueueId IN (
		SELECT FdpImportQueueId FROM @ImportItems
	);
	
	-- Remove all data from cancelled import queue items
	
	DELETE FROM Fdp_ImportData
	WHERE
	FdpImportId IN 
	(
		SELECT FdpImportId FROM @ImportItems
	)
	
	-- Remove the import header
	
	DELETE FROM Fdp_Import
	WHERE
	FdpImportId IN 
	(
		SELECT FdpImportId FROM @ImportItems
	);
	
	-- Remove from the queue
	
	DELETE FROM Fdp_ImportQueue
	WHERE
	FdpImportQueueId IN 
	(
		SELECT FdpImportQueueId FROM @ImportItems
	);
	
	SET @Message = CAST(@NoOfImportsCancelled AS NVARCHAR(10)) + ' imports cancelled';
	RAISERROR(@Message, 0, 1) WITH NOWAIT;