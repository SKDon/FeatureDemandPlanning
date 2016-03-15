CREATE PROCEDURE dbo.Fdp_ImportData_ProcessMissingMarkets
	  @FdpImportId		AS INT
	, @FdpImportQueueId AS INT
	, @LineNumber		AS INT = NULL
AS
	SET NOCOUNT ON;

	DECLARE @Message AS NVARCHAR(400);

	SET @Message = 'Adding missing markets...';
	RAISERROR(@Message, 0, 1) WITH NOWAIT;
	
	INSERT INTO Fdp_ImportError
	(
		  FdpImportQueueId
		, LineNumber
		, ErrorOn
		, FdpImportErrorTypeId
		, ErrorMessage
	)
	SELECT 
		  I.FdpImportQueueId
		, I.ImportLineNumber
		, GETDATE() AS ErrorOn
		, 1 AS FdpImportErrorTypeId -- Missing Market
		, 'Missing market ''' + I.ImportCountry + '''' AS ErrorMessage
	FROM
	Fdp_Import_VW				AS I
	LEFT JOIN Fdp_ImportError	AS CUR	ON	I.FdpImportQueueId	= CUR.FdpImportQueueId
										AND	I.ImportLineNumber	= CUR.LineNumber
										AND CUR.IsExcluded		= 0
	WHERE
	I.FdpImportId = @FdpImportId
	AND
	I.FdpImportQueueId = @FdpImportQueueId
	AND
	I.IsMarketMissing = 1
	AND
	(@LineNumber IS NULL OR I.ImportLineNumber = @LineNumber)
	AND
	CUR.FdpImportErrorId IS NULL
	
	SET @Message = CAST(@@ROWCOUNT AS NVARCHAR(10)) + ' missing market errors added';
	RAISERROR(@Message, 0, 1) WITH NOWAIT;