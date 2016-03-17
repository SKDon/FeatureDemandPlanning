CREATE PROCEDURE [dbo].[Fdp_ImportData_ProcessMissingMarkets]
	  @FdpImportId		AS INT
	, @FdpImportQueueId AS INT
	, @LineNumber		AS INT = NULL
AS
	SET NOCOUNT ON;

	DECLARE @Message AS NVARCHAR(400);
	DECLARE @ProgrammeId AS INT;
	DECLARE @Gateway AS NVARCHAR(100);
	DECLARE @DocumentId AS INT;

	SELECT @ProgrammeId = ProgrammeId, @Gateway = Gateway, @DocumentId = DocumentId
	FROM Fdp_Import
	WHERE
	FdpImportQueueId = @FdpImportQueueId
	AND
	FdpImportId = @FdpImportId;

	SET @Message = 'Removing old errors...'
	RAISERROR(@Message, 0, 1) WITH NOWAIT;

	DELETE FROM Fdp_ImportError 
	WHERE 
	FdpImportQueueId = @FdpImportQueueId
	AND
	FdpImportErrorTypeId = 1;

	SET @Message = 'Adding market errors...';
	RAISERROR(@Message, 0, 1) WITH NOWAIT;
	
	INSERT INTO Fdp_ImportError
	(
		  FdpImportQueueId
		, LineNumber
		, ErrorOn
		, FdpImportErrorTypeId
		, ErrorMessage
		, AdditionalData
	)
	SELECT 
		  @FdpImportQueueId
		, 0 
		, GETDATE() AS ErrorOn
		, 1 AS FdpImportErrorTypeId -- Missing Market
		, 'Missing market ''' + I.ImportCountry + '''' AS ErrorMessage
		, I.ImportCountry AS AdditionalData
	FROM
	Fdp_Import_VW						AS I
	LEFT JOIN Fdp_ImportError			AS CUR	ON	I.FdpImportQueueId		= CUR.FdpImportQueueId
												AND I.ImportCountry			= CUR.AdditionalData
												AND CUR.IsExcluded			= 0
	LEFT JOIN Fdp_ImportErrorExclusion	AS EX	ON	I.DocumentId			= EX.DocumentId
												AND EX.FdpImportErrorTypeId = 1
												AND EX.IsActive				= 1
												AND I.ImportCountry			= EX.AdditionalData
	WHERE
	I.FdpImportId = @FdpImportId
	AND
	I.FdpImportQueueId = @FdpImportQueueId
	AND
	I.IsMarketMissing = 1
	AND
	CUR.FdpImportErrorId IS NULL
	AND
	EX.FdpImportErrorExclusionId IS NULL
	GROUP BY
	I.ImportCountry
	
	SET @Message = CAST(@@ROWCOUNT AS NVARCHAR(10)) + ' market errors added';
	RAISERROR(@Message, 0, 1) WITH NOWAIT;