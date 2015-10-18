CREATE PROCEDURE [dbo].[ImportQueue_Save]
	  @ImportQueueId	INT = NULL OUTPUT
	, @SystemUser		NVARCHAR(16)
	, @FilePath			NVARCHAR(MAX)
	, @ImportTypeId		INT
	, @ImportStatusId	INT
AS
	SET NOCOUNT ON;
	
	IF @ImportQueueId IS NOT NULL 
		AND NOT EXISTS(SELECT TOP 1 1 FROM ImportQueue WHERE ImportQueueId = @ImportQueueId)
		RAISERROR (N'Import item does not exist', 16, 1);
		
	IF NOT EXISTS(SELECT TOP 1 1 FROM ImportStatus WHERE ImportStatusId = @ImportStatusId)
		RAISERROR (N'Status not found', 16, 1);
		
	IF NOT EXISTS(SELECT TOP 1 1 FROM ImportType WHERE ImportTypeId = @ImportTypeId)
		RAISERROR (N'Type not found', 16, 1);
	
	PRINT 'Import qid: ' + CAST(ISNULL(@ImportQueueId, -1) AS VARCHAR(10))
	
	IF @ImportQueueId IS NULL
	BEGIN
		INSERT INTO ImportQueue
		(
			  CreatedBy
			, FilePath
			, ImportTypeId
			, ImportStatusId
		)
		VALUES
		(
			  @SystemUser
			, @FilePath
			, @ImportTypeId
			, @ImportStatusId
		)
	
		SET @ImportQueueId = SCOPE_IDENTITY();
	END
	ELSE
	BEGIN
		UPDATE ImportQueue SET 
			  FilePath = @FilePath
			, ImportStatusId = @ImportStatusId
			, UpdatedOn = GETDATE()
			--, UpdateBy = @SystemUser 
		WHERE
		ImportQueueId = @ImportQueueId
	END;

