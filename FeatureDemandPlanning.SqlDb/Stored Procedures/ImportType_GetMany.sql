CREATE PROCEDURE [dbo].[ImportType_GetMany]
AS
	SET NOCOUNT ON;
	
	SELECT 
		  T.ImportTypeId AS ImportTypeDefinition
		, T.[Type]
		, T.[Description]
		
	FROM ImportType AS T
	ORDER BY
	T.[Type]
	
