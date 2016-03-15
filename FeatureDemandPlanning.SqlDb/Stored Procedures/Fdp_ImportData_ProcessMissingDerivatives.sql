CREATE PROCEDURE [dbo].[Fdp_ImportData_ProcessMissingDerivatives]
	  @FdpImportId		AS INT
	, @FdpImportQueueId AS INT
	, @LineNumber		AS INT = NULL
AS
	SET NOCOUNT ON;

	DECLARE @Message AS NVARCHAR(400);
	DECLARE @ProgrammeId AS INT;
	DECLARE @Gateway AS NVARCHAR(100);
	DECLARE @FlagOrphanedImportData AS BIT = 0;

	SELECT @ProgrammeId = ProgrammeId, @Gateway = Gateway
	FROM Fdp_Import
	WHERE
	FdpImportQueueId = @FdpImportQueueId
	AND
	FdpImportId = @FdpImportId;

	SELECT TOP 1 @FlagOrphanedImportData = CAST(Value AS BIT) FROM Fdp_Configuration WHERE ConfigurationKey = 'FlagOrphanedImportDataAsError';

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
		  I.FdpImportQueueId
		, I.LineNumber
		, I.ErrorOn
		, I.FdpImportErrorTypeId
		, I.ErrorMessage
		, I.AdditionalData
	FROM
	(
	SELECT
		  @FdpImportQueueId AS FdpImportQueueId
		, 0 AS LineNumber
		, GETDATE() AS ErrorOn
		, 3 AS FdpImportErrorTypeId -- Missing Derivative
		, 'No import data matching OXO derivative ''' + D.MappedDerivativeCode + ' - ' + REPLACE(D.Name, '#', '') + '''' AS ErrorMessage
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
		  @FdpImportQueueId AS FdpImportQueueId
		, 0 AS LineNumber
		, GETDATE() AS ErrorOn
		, 3 AS FdpImportErrorTypeId -- Missing Derivative
		, 'No OXO derivative matching import derivative ''' + I.ImportDerivativeCode + '''' AS ErrorMessage
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
	CUR.FdpImportErrorId IS NULL
	AND
	@FlagOrphanedImportData = 1

	UNION

	-- Where we have no brochure model code defined for a derivative

	SELECT
		  @FdpImportQueueId AS FdpImportQueueId
		, 0 AS LineNumber
		, GETDATE() AS ErrorOn
		, 3 AS FdpImportErrorTypeId
		, 'No brochure model code defined for ''' + REPLACE(M.ExportRow1, '#', '') + ' - ' + REPLACE(M.ExportRow2, '#', '') + '''' AS ErrorMessage
		, M.ExportRow1 + ' ' + M.ExportRow2 AS AdditionalData

	FROM OXO_Models_VW AS M
	LEFT JOIN Fdp_ImportError	AS CUR	ON	CUR.FdpImportQueueId = @FdpImportQueueId
											AND M.ExportRow1 + ' ' + M.ExportRow2 = CUR.AdditionalData
											AND CUR.FdpImportErrorTypeId = 3
											AND CUR.IsExcluded = 0
	WHERE
	M.Programme_Id = @ProgrammeId
	AND
	ISNULL(M.BMC, '') = ''
	GROUP BY
	M.ExportRow1, M.ExportRow2
	)
	AS I
	ORDER BY I.ErrorMessage

	SET @Message = CAST(@@ROWCOUNT AS NVARCHAR(10)) + ' missing derivative errors added';
	RAISERROR(@Message, 0, 1) WITH NOWAIT;