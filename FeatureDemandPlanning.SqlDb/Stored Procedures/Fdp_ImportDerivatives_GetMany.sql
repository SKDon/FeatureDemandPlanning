CREATE PROCEDURE [dbo].[Fdp_ImportDerivatives_GetMany]
	@FdpImportQueueId INT
AS
	SET NOCOUNT ON;
	
	DECLARE @FdpImportId AS INT;
	SELECT TOP 1 @FdpImportId = FdpImportId FROM Fdp_Import WHERE FdpImportQueueId = @FdpImportQueueId
	
	SELECT
		  I.CreatedOn
		, I.CreatedBy
		, I.DocumentId 
		, I.ImportDerivativeCode AS DerivativeCode
		, I.ProgrammeId
		, I.Gateway
		, CAST(NULL AS INT) AS BodyId
		, CAST(NULL AS INT) AS EngineId
		, CAST(NULL AS INT) AS TransmissionId
		, CAST(0 AS BIT) AS IsMappedDerivative
		, CAST(NULL AS DATETIME) AS UpdatedOn
		, CAST(NULL AS NVARCHAR(16)) AS UpdatedBy
		, CAST(NULL AS INT) AS FdpDerivativeMappingId
	FROM
	Fdp_Import_VW AS I 
	WHERE
	I.FdpImportQueueId = @FdpImportQueueId
	AND
	I.FdpImportId = @FdpImportId
	GROUP BY
	I.DocumentId, I.CreatedOn, I.CreatedBy, I.DocumentId, I.ProgrammeId, I.Gateway, I.ImportDerivativeCode
	ORDER BY
	DerivativeCode