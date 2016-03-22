CREATE PROCEDURE [dbo].[Fdp_ImportQueueSummary_Get]
	@FdpImportQueueId INT
AS
	SET NOCOUNT ON;

	DECLARE @TotalLines INT;
	DECLARE @TotalErrors INT = 0;
	DECLARE @SuccessLines INT = 0;
	DECLARE @ImportFileName NVARCHAR(255);
	DECLARE @FdpImportId INT;

	SELECT @FdpImportId = FdpImportId FROM Fdp_Import WHERE FdpImportQueueId = @FdpImportQueueId;

	SELECT @TotalLines = COUNT(LineNumber) 
	FROM
	Fdp_ImportData	AS D
	JOIN Fdp_Import	AS I	ON	D.FdpImportId	= I.FdpImportId
							AND I.FdpImportQueueId = @FdpImportQueueId;
	
	SELECT @TotalErrors = COUNT(1) FROM Fdp_ImportError_VW WHERE FdpImportId = @FdpImportId AND FdpImportQueueId = @FdpImportQueueId
	
	SELECT @ImportFileName = OriginalFileName FROM Fdp_ImportQueue WHERE FdpImportQueueId = @FdpImportQueueId;

	SELECT 
		  @TotalLines	AS TotalLines
		, 0	AS FailedLines
		, 0 AS SuccessLines
		, @TotalErrors	AS TotalErrors
		, @ImportFileName AS ImportFileName;