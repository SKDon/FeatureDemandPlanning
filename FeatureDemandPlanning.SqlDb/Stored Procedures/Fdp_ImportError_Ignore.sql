CREATE PROCEDURE [dbo].[Fdp_ImportError_Ignore]
	  @ExceptionId INT
	, @IsExcluded  BIT = 1
AS
	SET NOCOUNT ON;
	
	DECLARE @ImportQueueId INT;
	DECLARE @Message NVARCHAR(MAX);
	SELECT 
		  @ImportQueueId = ImportQueueId
		, @Message = ErrorMessage
	FROM Fdp_ImportError 
	WHERE FdpImportErrorId = @ExceptionId;
	
	-- Update all errors with the same message for that import
	UPDATE E SET IsExcluded = @IsExcluded
	FROM Fdp_ImportError AS E
	WHERE
	E.ImportQueueId = @ImportQueueId
	AND
	E.ErrorMessage = @Message;
	
	EXEC Fdp_ImportError_Get @ExceptionId;