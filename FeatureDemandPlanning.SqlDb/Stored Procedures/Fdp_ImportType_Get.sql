CREATE PROCEDURE [dbo].[Fdp_ImportType_Get]
	  @FdpImportTypeId INT = 1
AS
	SET NOCOUNT ON;
	
	IF NOT EXISTS(SELECT TOP 1 1 FROM Fdp_ImportType WHERE FdpImportTypeId = @FdpImportTypeId)
		RAISERROR (N'Import type does not exist', 16, 1);
		
	SELECT 
		  T.FdpImportTypeId AS ImportTypeDefinition
		, T.[Type]
		, T.[Description]
		
	FROM Fdp_ImportType AS T
	WHERE
	T.FdpImportTypeId = @FdpImportTypeId;