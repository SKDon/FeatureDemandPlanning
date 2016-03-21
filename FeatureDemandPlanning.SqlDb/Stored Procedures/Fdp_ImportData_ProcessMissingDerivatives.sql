CREATE PROCEDURE [dbo].[Fdp_ImportData_ProcessMissingDerivatives]
	  @FdpImportId		AS INT
	, @FdpImportQueueId AS INT
	, @LineNumber		AS INT = NULL
AS
	SET NOCOUNT ON;

	DECLARE @ErrorCount		AS INT = 0
	DECLARE @Message		AS NVARCHAR(400);
	DECLARE @DocumentId		AS INT;
	DECLARE @FlagOrphanedImportData AS BIT = 0;
	
	SET @Message = 'Removing old errors...'
	RAISERROR(@Message, 0, 1) WITH NOWAIT;

	DELETE FROM Fdp_ImportError 
	WHERE 
	FdpImportQueueId = @FdpImportQueueId
	AND
	FdpImportErrorTypeId = 3
	
	IF EXISTS(
		SELECT TOP 1 1 
		FROM 
		Fdp_ImportError 
		WHERE 
		FdpImportQueueId = @FdpImportQueueId
		AND
		FdpImportErrorTypeId = 1)
	BEGIN
		RETURN;
	END;

	SELECT @DocumentId = DocumentId
	FROM Fdp_Import
	WHERE
	FdpImportQueueId = @FdpImportQueueId
	AND
	FdpImportId = @FdpImportId;

	SELECT TOP 1 @FlagOrphanedImportData = CAST(Value AS BIT) FROM Fdp_Configuration WHERE ConfigurationKey = 'FlagOrphanedImportDataAsError';

	SET @Message = 'Adding missing derivatives...';
	RAISERROR(@Message, 0, 1) WITH NOWAIT;
	
	-- Non-archived
		
	INSERT INTO Fdp_ImportError
	(
		  FdpImportQueueId
		, LineNumber
		, ErrorOn
		, FdpImportErrorTypeId
		, ErrorMessage
		, AdditionalData
		, SubTypeId
	)
	SELECT
		  @FdpImportQueueId AS FdpImportQueueId
		, 0 AS LineNumber
		, GETDATE() AS ErrorOn
		, 3 AS FdpImportErrorTypeId
		, 'No Brochure Model Code defined for ''' + REPLACE(M.ExportRow1, '#', '') + ' - ' + REPLACE(M.ExportRow2, '#', '') + '''' AS ErrorMessage
		, M.ExportRow1 + ' ' + M.ExportRow2 AS AdditionalData
		, 301 AS SubTypeId

	FROM 
	OXO_Doc								AS D
	JOIN OXO_Models_VW					AS M	ON	D.Programme_Id				= M.Programme_Id
	LEFT JOIN Fdp_ImportError			AS CUR	ON	CUR.FdpImportQueueId		= @FdpImportQueueId
												AND M.ExportRow1 + ' ' + M.ExportRow2 
																				= CUR.AdditionalData
												AND CUR.FdpImportErrorTypeId	= 3
												AND CUR.IsExcluded				= 0
	LEFT JOIN Fdp_ImportErrorExclusion	AS EX	ON	EX.DocumentId				= @DocumentId
												AND EX.FdpImportErrorTypeId		= 3
												AND EX.SubTypeId				= 301
												AND EX.IsActive					= 1
												AND M.ExportRow1 + ' ' + M.ExportRow2 
																				= EX.AdditionalData
	WHERE
	D.Id = @DocumentId
	AND
	ISNULL(D.Archived, 0) = 0
	AND
	ISNULL(M.BMC, '') = ''
	AND
	EX.FdpImportErrorExclusionId IS NULL
	GROUP BY
	M.ExportRow1, M.ExportRow2
	ORDER BY 
	ErrorMessage
	
	SET @ErrorCount = @ErrorCount + @@ROWCOUNT;
	
	-- Archived
	
	INSERT INTO Fdp_ImportError
	(
		  FdpImportQueueId
		, LineNumber
		, ErrorOn
		, FdpImportErrorTypeId
		, ErrorMessage
		, AdditionalData
		, SubTypeId
	)
	SELECT
		  @FdpImportQueueId AS FdpImportQueueId
		, 0 AS LineNumber
		, GETDATE() AS ErrorOn
		, 3 AS FdpImportErrorTypeId
		, 'No Brochure Model Code defined for ''' + REPLACE(M.ExportRow1, '#', '') + ' - ' + REPLACE(M.ExportRow2, '#', '') + '''' AS ErrorMessage
		, M.ExportRow1 + ' ' + M.ExportRow2 AS AdditionalData
		, 301 AS SubTypeId

	FROM 
	OXO_Doc								AS D
	JOIN OXO_Archived_Models_VW			AS M	ON	D.Id						= M.Doc_Id
	LEFT JOIN Fdp_ImportError			AS CUR	ON	CUR.FdpImportQueueId		= @FdpImportQueueId
												AND M.ExportRow1 + ' ' + M.ExportRow2 
																				= CUR.AdditionalData
												AND CUR.FdpImportErrorTypeId	= 3
												AND CUR.IsExcluded				= 0
	LEFT JOIN Fdp_ImportErrorExclusion	AS EX	ON	EX.DocumentId				= @DocumentId
												AND EX.FdpImportErrorTypeId		= 3
												AND EX.SubTypeId				= 301
												AND EX.IsActive					= 1
												AND M.ExportRow1 + ' ' + M.ExportRow2 
																				= EX.AdditionalData
	WHERE
	D.Id = @DocumentId
	AND
	D.Archived = 1
	AND
	ISNULL(M.BMC, '') = ''
	AND
	EX.FdpImportErrorExclusionId IS NULL
	GROUP BY
	M.ExportRow1, M.ExportRow2
	ORDER BY 
	ErrorMessage
	
	SET @ErrorCount = @ErrorCount + @@ROWCOUNT;
	
	INSERT INTO Fdp_ImportError
	(
		  FdpImportQueueId
		, LineNumber
		, ErrorOn
		, FdpImportErrorTypeId
		, ErrorMessage
		, AdditionalData
		, SubTypeId
	)
	SELECT
		  @FdpImportQueueId AS FdpImportQueueId
		, 0 AS LineNumber
		, GETDATE() AS ErrorOn
		, 3 AS FdpImportErrorTypeId -- Missing Derivative
		, 'No historic data mapping to OXO BMC ''' + D.MappedDerivativeCode + ' - ' + REPLACE(D.Name, '#', '') + '''' AS ErrorMessage
		, D.MappedDerivativeCode AS AdditionalData
		, 302 AS SubTypeId
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
	-- Don't add if there are any active missing BMC errors
	LEFT JOIN Fdp_ImportError   AS CUR2 ON	CUR2.FdpImportQueueId = @FdpImportQueueId
										AND	CUR2.FdpImportErrorTypeId = 3
										AND CUR2.SubTypeId = 301
										AND CUR2.IsExcluded = 0
	LEFT JOIN Fdp_ImportErrorExclusion	AS EX	ON	EX.DocumentId				= @DocumentId
												AND EX.FdpImportErrorTypeId		= 3
												AND EX.SubTypeId				= 302
												AND EX.IsActive					= 1
												AND D.MappedDerivativeCode		= EX.AdditionalData
	WHERE 
	D.DocumentId = @DocumentId
	AND
	I1.ImportDerivativeCode IS NULL
	AND
	CUR.FdpImportErrorId IS NULL
	AND
	ISNULL(D.MappedDerivativeCode, '') <> ''
	AND
	CUR2.FdpImportErrorId IS NULL 
	AND
	EX.FdpImportErrorExclusionId IS NULL
	ORDER BY 
	ErrorMessage;
	
	SET @ErrorCount = @ErrorCount + @@ROWCOUNT;

	INSERT INTO Fdp_ImportError
	(
		  FdpImportQueueId
		, LineNumber
		, ErrorOn
		, FdpImportErrorTypeId
		, ErrorMessage
		, AdditionalData
		, SubTypeId
	)
	SELECT 
		  @FdpImportQueueId AS FdpImportQueueId
		, 0 AS LineNumber
		, GETDATE() AS ErrorOn
		, 3 AS FdpImportErrorTypeId -- Missing Derivative
		, 'No OXO BMC matching historic BMC ''' + I.ImportDerivativeCode + '''' AS ErrorMessage
		, I.ImportDerivativeCode AS AdditionalData
		, 303 AS SubTypeId
	FROM
	(
		SELECT DISTINCT I.ImportDerivativeCode FROM Fdp_Import_VW AS I
		LEFT JOIN Fdp_DerivativeMapping_VW AS D ON I.DocumentId = D.DocumentId
												AND I.ImportDerivativeCode	= D.ImportDerivativeCode
												AND ISNULL(D.MappedDerivativeCode, '') <> ''
		WHERE FdpImportId  = @FdpImportId AND FdpImportQueueId = @FdpImportQueueId
		AND
		D.MappedDerivativeCode IS NULL
	)
	AS I
	LEFT JOIN Fdp_ImportError	AS CUR	ON	CUR.FdpImportQueueId = @FdpImportQueueId
											AND	I.ImportDerivativeCode	= CUR.AdditionalData
											AND CUR.FdpImportErrorTypeId = 3
											AND CUR.IsExcluded = 0
	-- Don't add if there are any active missing BMC errors
	LEFT JOIN Fdp_ImportError   AS CUR2 ON	CUR2.FdpImportQueueId = @FdpImportQueueId
										AND	CUR2.FdpImportErrorTypeId = 3
										AND CUR2.SubTypeId IN (301, 302)
										AND CUR2.IsExcluded = 0
	LEFT JOIN Fdp_ImportErrorExclusion	AS EX	ON	EX.DocumentId				= @DocumentId
												AND EX.FdpImportErrorTypeId		= 3
												AND EX.SubTypeId				= 303
												AND EX.IsActive					= 1
												AND I.ImportDerivativeCode		= EX.AdditionalData
	WHERE
	CUR.FdpImportErrorId IS NULL
	AND
	@FlagOrphanedImportData = 1
	AND
	CUR2.FdpImportErrorId IS NULL
	AND
	EX.FdpImportErrorExclusionId IS NULL
	ORDER BY
	ErrorMessage;
	
	SET @ErrorCount = @ErrorCount + @@ROWCOUNT;

	SET @Message = CAST(@ErrorCount AS NVARCHAR(10)) + ' derivative errors added';
	RAISERROR(@Message, 0, 1) WITH NOWAIT;