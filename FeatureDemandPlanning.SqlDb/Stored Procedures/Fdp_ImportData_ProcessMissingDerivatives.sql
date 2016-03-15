CREATE PROCEDURE [dbo].[Fdp_ImportData_ProcessMissingDerivatives]
	  @FdpImportId		AS INT
	, @FdpImportQueueId AS INT
	, @LineNumber		AS INT = NULL
AS
	SET NOCOUNT ON;

	DECLARE @Message AS NVARCHAR(400);
	DECLARE @ProgrammeId AS INT;
	DECLARE @Gateway AS NVARCHAR(100);

	SELECT @ProgrammeId = ProgrammeId, @Gateway = Gateway
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
	FdpImportErrorTypeId = 3

	SET @Message = 'Adding missing derivatives...';
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
		, 3 AS FdpImportErrorTypeId -- Missing Derivative
		, 'No import data matching OXO derivative ''' + D.MappedDerivativeCode + '''' AS ErrorMessage
		, D.MappedDerivativeCode AS AdditionalData
	FROM Fdp_DerivativeMapping_VW AS D
	LEFT JOIN 
	(
		SELECT FdpImportQueueId, ImportDerivativeCode
		FROM Fdp_Import_VW AS I
		WHERE 
		I.FdpImportId = @FdpImportId
		AND 
		I.FdpImportQueueId = @FdpImportQueueId
		GROUP BY 
		FdpImportQueueId, ImportDerivativeCode
	)
	AS I1 ON D.ImportDerivativeCode = I1.ImportDerivativeCode
	LEFT JOIN Fdp_ImportError	AS CUR	ON	CUR.FdpImportQueueId = @FdpImportQueueId
											AND	D.MappedDerivativeCode	= CUR.AdditionalData
											AND CUR.FdpImportErrorTypeId = 3
											AND CUR.IsExcluded = 0
	WHERE 
	D.ProgrammeId = @ProgrammeId
	AND 
	D.Gateway = @Gateway
	AND
	I1.ImportDerivativeCode IS NULL
	AND
	CUR.FdpImportErrorId IS NULL

	UNION

	SELECT 
		  @FdpImportQueueId
		, 0
		, GETDATE() AS ErrorOn
		, 3 AS FdpImportErrorTypeId -- Missing Derivative
		, 'No OXO derivative mapped for ''' + I.ImportDerivativeCode + '''' AS ErrorMessage
		, I.ImportDerivativeCode AS AdditionalData
	FROM
	(
		SELECT DISTINCT I.ImportDerivativeCode FROM Fdp_Import_VW AS I
		LEFT JOIN Fdp_DerivativeMapping_VW AS D ON I.ProgrammeId = D.ProgrammeId
											AND I.Gateway	= D.Gateway
											AND I.ImportDerivativeCode = D.ImportDerivativeCode
		WHERE FdpImportId  = @FdpImportId AND FdpImportQueueId = @FdpImportQueueId
		AND
		D.MappedDerivativeCode IS NULL
	)
	AS I
	LEFT JOIN Fdp_ImportError	AS CUR	ON	CUR.FdpImportQueueId = @FdpImportQueueId
											AND	I.ImportDerivativeCode	= CUR.AdditionalData
											AND CUR.FdpImportErrorTypeId = 3
											AND CUR.IsExcluded = 0
	WHERE
	CUR.FdpImportErrorId IS NULL;
	
	SET @Message = CAST(@@ROWCOUNT AS NVARCHAR(10)) + ' missing derivative errors added';
	RAISERROR(@Message, 0, 1) WITH NOWAIT;