CREATE PROCEDURE dbo.Fdp_ImportData_ProcessMissingFeatures
	  @FdpImportId		AS INT
	, @FdpImportQueueId AS INT
	, @LineNumber		AS INT = NULL
AS
	SET NOCOUNT ON;

	DECLARE @Message AS NVARCHAR(400);

	SET @Message = 'Adding features...';
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
		, 2 AS FdpImportErrorTypeId -- Missing Feature
		, 'Missing feature ''' + I.ImportFeatureCode + ' - ' + I.ImportFeature + '''' AS ErrorMessage
	FROM Fdp_Import_VW			AS I
	LEFT JOIN Fdp_ImportError	AS CUR	ON	I.FdpImportQueueId	= CUR.FdpImportQueueId
										AND	I.ImportLineNumber	= CUR.LineNumber
										AND CUR.IsExcluded		= 0
	WHERE
	I.FdpImportId = @FdpImportId
	AND
	I.FdpImportQueueId = @FdpImportQueueId
	AND
	I.IsFeatureMissing = 1
	AND
	(@LineNumber IS NULL OR I.ImportLineNumber = @LineNumber)
	AND
	CUR.FdpImportErrorId IS NULL
	
	SET @Message = CAST(@@ROWCOUNT AS NVARCHAR(10)) + ' missing feature errors added';
	RAISERROR(@Message, 0, 1) WITH NOWAIT;