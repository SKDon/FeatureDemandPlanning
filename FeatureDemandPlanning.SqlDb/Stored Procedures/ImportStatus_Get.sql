CREATE PROCEDURE [dbo].[ImportStatus_Get]
	  @ImportStatusId INT = 1
AS
	SET NOCOUNT ON;
	
	IF NOT EXISTS(SELECT TOP 1 1 FROM ImportStatus WHERE ImportStatusId = @ImportStatusId)
		RAISERROR (N'Import status does not exist', 16, 1);
		
	SELECT 
		  S.ImportStatusId AS ImportStatusCode
		, S.[Status]
		, S.[Description]
		
	FROM ImportStatus AS S
	WHERE
	S.ImportStatusId = @ImportStatusId;

