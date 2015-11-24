CREATE PROCEDURE Fdp_ImportQueueSummary_Get
	@FdpImportQueueId INT
AS
	SET NOCOUNT ON;

	DECLARE @TotalLines INT;
	DECLARE @FailedLines INT;
	DECLARE @SuccessLines INT;
	DECLARE @ImportFileName NVARCHAR(255);

	SELECT @TotalLines = COUNT(LineNumber) 
	FROM
	Fdp_ImportData	AS D
	JOIN Fdp_Import	AS I	ON	D.FdpImportId	= I.FdpImportId
							AND I.FdpImportQueueId = @FdpImportQueueId;

	SELECT @FailedLines = 
		COUNT(DISTINCT LineNumber) 
		FROM
		Fdp_ImportError 
		WHERE
		FdpImportQueueId = @FdpImportQueueId
		AND
		IsExcluded = 0;

	SELECT @SuccessLines = 
		COUNT(DISTINCT D.LineNumber) 
		FROM
		Fdp_ImportData				AS D
		JOIN Fdp_Import				AS I	ON	D.FdpImportId		= I.FdpImportId
		LEFT JOIN Fdp_ImportError	AS E	ON	I.FdpImportQueueId	= E.FdpImportQueueId
											AND D.LineNumber		= E.LineNumber
											AND E.IsExcluded		= 0
		WHERE
		I.FdpImportQueueId = @FdpImportQueueId
		AND
		E.FdpImportErrorId IS NULL;

	SELECT @ImportFileName = OriginalFileName FROM Fdp_ImportQueue WHERE FdpImportQueueId = @FdpImportQueueId;

	SELECT 
		  @TotalLines	AS TotalLines
		, @FailedLines	AS FailedLines
		, @SuccessLines AS SuccessLines
		, @ImportFileName AS ImportFileName;