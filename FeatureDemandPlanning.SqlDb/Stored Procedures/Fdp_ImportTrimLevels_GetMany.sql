CREATE PROCEDURE [dbo].[Fdp_ImportTrimLevels_GetMany]
	@FdpImportQueueId INT
AS
	SET NOCOUNT ON;
	
	DECLARE @FdpImportId AS INT;
	SELECT TOP 1 @FdpImportId = FdpImportId FROM Fdp_Import WHERE FdpImportQueueId = @FdpImportQueueId
	
	SELECT
		  I.CreatedOn
		, I.CreatedBy
		, I.DocumentId 
		, I.ImportTrim AS Name
		, I.ProgrammeId
		, I.Gateway
		, CAST(0 AS BIT) AS IsMappedTrim
		, CAST(NULL AS DATETIME) AS UpdatedOn
		, CAST(NULL AS NVARCHAR(16)) AS UpdatedBy
		, CAST(NULL AS INT) AS FdpTrimMappingId
		, I.BMC
		, I.DPCK
	FROM
	Fdp_Import_VW AS I 
	WHERE
	I.FdpImportQueueId = @FdpImportQueueId
	AND
	I.FdpImportId = @FdpImportId
	AND
	ISNULL(I.BMC, '') <> '' 
	GROUP BY
	I.DocumentId, I.CreatedOn, I.CreatedBy, I.DocumentId, I.ProgrammeId, I.Gateway, I.ImportTrim, I.BMC, I.DPCK
	ORDER BY
	Name