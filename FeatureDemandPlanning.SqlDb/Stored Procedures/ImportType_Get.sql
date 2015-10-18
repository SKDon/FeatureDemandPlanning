CREATE PROCEDURE [dbo].[ImportType_Get]
	  @ImportTypeId INT = 1
AS
	SET NOCOUNT ON;
	
	IF NOT EXISTS(SELECT TOP 1 1 FROM ImportType WHERE ImportTypeId = @ImportTypeId)
		RAISERROR (N'Import type does not exist', 16, 1);
		
	SELECT 
		  T.ImportTypeId AS ImportTypeDefinition
		, T.[Type]
		, T.[Description]
		
	FROM ImportType AS T
	WHERE
	T.ImportTypeId = @ImportTypeId;

