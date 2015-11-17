CREATE PROCEDURE [dbo].[Fdp_ImportStatus_Get]
	  @FdpImportStatusId INT = 1
AS
	SET NOCOUNT ON;
	
	IF NOT EXISTS(SELECT TOP 1 1 FROM Fdp_ImportStatus WHERE FdpImportStatusId = @FdpImportStatusId)
		RAISERROR (N'Import status does not exist', 16, 1);
		
	SELECT 
		  S.FdpImportStatusId AS ImportStatusCode
		, S.[Status]
		, S.[Description]
		
	FROM Fdp_ImportStatus AS S
	WHERE
	S.FdpImportStatusId = @FdpImportStatusId;