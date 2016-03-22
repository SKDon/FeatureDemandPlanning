CREATE PROCEDURE [dbo].[Fdp_ImportFeatures_GetMany]
	@FdpImportQueueId INT
AS
	SET NOCOUNT ON;
	
	DECLARE @FdpImportId AS INT;
	SELECT TOP 1 @FdpImportId = FdpImportId FROM Fdp_Import WHERE FdpImportQueueId = @FdpImportQueueId
	
	SELECT
		  I.CreatedOn
		, I.CreatedBy
		, I.DocumentId 
		, I.ImportFeature AS SystemDescription
		, I.ImportFeatureCode AS FeatureCode
		, I.Gateway
		, CAST(0 AS BIT) AS IsMappedFeature
		, CAST(NULL AS DATETIME) AS UpdatedOn
		, CAST(NULL AS NVARCHAR(16)) AS UpdatedBy
		, CAST(NULL AS INT) AS FdpFeatureMappingId
	FROM
	Fdp_Import_VW AS I 
	WHERE
	I.FdpImportQueueId = @FdpImportQueueId
	AND
	I.FdpImportId = @FdpImportId
	GROUP BY
	I.DocumentId, I.CreatedOn, I.CreatedBy, I.DocumentId, I.ProgrammeId, I.Gateway, I.ImportFeatureCode, I.ImportFeature
	ORDER BY
	SystemDescription