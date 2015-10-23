CREATE PROCEDURE [dbo].[Fdp_ImportQueue_Get]
	  @ImportQueueId	INT
AS
	SET NOCOUNT ON;
	
	IF @ImportQueueId IS NOT NULL 
		AND NOT EXISTS(SELECT TOP 1 1 FROM ImportQueue WHERE ImportQueueId = @ImportQueueId)
		RAISERROR (N'Import item does not exist', 16, 1);
		
	SELECT 
		  Q.ImportQueueId
		, Q.CreatedOn
		, Q.CreatedBy
		, Q.ImportTypeId
		, Q.[Type]
		, Q.ImportStatusId
		, Q.[Status]
		, Q.FilePath
		, Q.UpdatedOn
		, Q.Error
		, Q.ErrorOn
		, I.ProgrammeId
		, I.Gateway
		
	FROM ImportQueue_VW AS Q
	JOIN Fdp_Import AS I ON Q.ImportQueueId = I.ImportQueueId
	WHERE
	(@ImportQueueId IS NULL OR Q.ImportQueueId = @ImportQueueId);