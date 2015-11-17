CREATE PROCEDURE [dbo].[Fdp_ImportStatus_GetMany]
AS
	SET NOCOUNT ON;
	
	SELECT
		  S.FdpImportStatusId
		, S.[Status]
		, S.[Description]
		
	FROM Fdp_ImportStatus AS S