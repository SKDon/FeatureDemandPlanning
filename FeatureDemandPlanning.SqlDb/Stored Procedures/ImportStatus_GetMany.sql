CREATE PROCEDURE [dbo].[ImportStatus_GetMany]
AS
	SET NOCOUNT ON;
	
	SELECT
		  S.ImportStatusId
		, S.[Status]
		, S.[Description]
		
	FROM ImportStatus AS S
	
