CREATE PROCEDURE [dbo].[Fdp_ImportType_GetMany]
AS
	SET NOCOUNT ON;
	
	SELECT 
		  T.FdpImportTypeId AS ImportTypeDefinition
		, T.[Type]
		, T.[Description]
		
	FROM Fdp_ImportType AS T
	ORDER BY
	T.[Type]