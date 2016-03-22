CREATE PROCEDURE [dbo].[Fdp_ImportData_ProcessMissingTrim]
	  @FdpImportId		AS INT
	, @FdpImportQueueId AS INT
	, @LineNumber		AS INT = NULL
AS
	SET NOCOUNT ON;

	DECLARE @ErrorCount				AS INT = 0
	DECLARE @Message				AS NVARCHAR(400);
	DECLARE @DocumentId				AS INT;
	DECLARE @FlagOrphanedImportData AS BIT = 0;
	
	SET @Message = 'Removing old errors...'
	RAISERROR(@Message, 0, 1) WITH NOWAIT;

	DELETE FROM Fdp_ImportError 
	WHERE 
	FdpImportQueueId = @FdpImportQueueId
	AND
	FdpImportErrorTypeId = 4
	
	IF EXISTS(
		SELECT TOP 1 1 
		FROM 
		Fdp_ImportError 
		WHERE 
		FdpImportQueueId = @FdpImportQueueId
		AND
		FdpImportErrorTypeId IN (1,3))
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

	SET @Message = 'Adding missing trim...';
	RAISERROR(@Message, 0, 1) WITH NOWAIT;
	
	-- Where we have no DPCK code defined for a trim level

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
		, 4 AS FdpImportErrorTypeId
		, 'No DPCK code defined for ''' + T.Name + ' - ' + T.[Level] + '''' AS ErrorMessage
		, T.Name + ' ' + T.[Level] AS AdditionalData
		, 401

	FROM 
	OXO_Doc								AS D
	JOIN OXO_Programme_Trim				AS T	ON	D.Programme_Id				= T.Programme_Id
	LEFT JOIN Fdp_ImportError			AS CUR	ON	CUR.FdpImportQueueId		= @FdpImportQueueId
												AND T.Name + ' ' + T.[Level]	= CUR.AdditionalData
												AND CUR.FdpImportErrorTypeId	= 4
												AND CUR.IsExcluded				= 0
	LEFT JOIN Fdp_ImportErrorExclusion	AS EX	ON	EX.DocumentId				= D.Id
												AND EX.FdpImportErrorTypeId		= 4
												AND EX.SubTypeId				= 401
												AND EX.IsActive					= 1
												AND T.Name + ' ' + T.[Level]	= EX.AdditionalData
	WHERE
	D.Id = @DocumentId
	AND
	ISNULL(D.Archived, 0) = 0
	AND
	ISNULL(T.DPCK, '') = ''
	AND
	EX.FdpImportErrorExclusionId IS NULL
	GROUP BY
	T.Name, T.[Level]
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
		, 4 AS FdpImportErrorTypeId
		, 'No DPCK code defined for ''' + T.Name + ' - ' + T.[Level] + '''' AS ErrorMessage
		, T.Name + ' ' + T.[Level] AS AdditionalData
		, 401
	FROM 
	OXO_Doc								AS D
	JOIN OXO_Archived_Programme_Trim	AS T	ON	D.Id						= T.Doc_Id
	LEFT JOIN Fdp_ImportError			AS CUR	ON	CUR.FdpImportQueueId		= @FdpImportQueueId
												AND T.Name + ' ' + T.[Level]	= CUR.AdditionalData
												AND CUR.FdpImportErrorTypeId	= 4
												AND CUR.SubTypeId				= 401
												AND CUR.IsExcluded				= 0
	LEFT JOIN Fdp_ImportErrorExclusion	AS EX	ON	EX.DocumentId				= D.Id
												AND EX.FdpImportErrorTypeId		= 4
												AND EX.SubTypeId				= 401
												AND EX.IsActive					= 1
												AND T.Name + ' ' + T.[Level]	= EX.AdditionalData
	WHERE
	T.Doc_Id = @DocumentId
	AND
	D.Archived = 1
	AND
	ISNULL(T.DPCK, '') = ''
	AND
	EX.FdpImportErrorExclusionId IS NULL
	GROUP BY
	T.Name, T.[Level]
	ORDER BY ErrorMessage
	
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
		, 4 AS FdpImportErrorTypeId -- Missing Trim
		, 'No historic data mapping to OXO DPCK ''' + T.DPCK + '''' AS ErrorMessage
		, T.DPCK AS AdditionalData
		, 402
	FROM Fdp_TrimMapping_VW AS T
	LEFT JOIN 
	(
		SELECT FdpImportQueueId, ImportTrim
		FROM Fdp_Import_VW AS I
		WHERE 
		I.FdpImportId = @FdpImportId
		AND 
		I.FdpImportQueueId = @FdpImportQueueId
		GROUP BY 
		FdpImportQueueId, ImportTrim
	)
	AS I1 ON T.ImportTrim = I1.ImportTrim
	LEFT JOIN Fdp_ImportError			AS CUR	ON	CUR.FdpImportQueueId		= @FdpImportQueueId
												AND	T.DPCK						= CUR.AdditionalData
												AND CUR.FdpImportErrorTypeId	= 4
												AND CUR.IsExcluded				= 0
												AND CUR.SubTypeId				= 402
	-- Don't add if there are any active missing DPCK errors
	LEFT JOIN Fdp_ImportError			AS CUR2 ON	CUR2.FdpImportQueueId		= @FdpImportQueueId
												AND	CUR2.FdpImportErrorTypeId	= 4
												AND CUR2.SubTypeId				= 401
												AND CUR2.IsExcluded				= 0
	LEFT JOIN Fdp_ImportErrorExclusion	AS EX	ON	EX.DocumentId				= @DocumentId
												AND EX.FdpImportErrorTypeId		= 4
												AND EX.SubTypeId				= 402
												AND EX.IsActive					= 1
												AND T.DPCK						= EX.AdditionalData
	WHERE 
	T.DocumentId = @DocumentId
	AND
	I1.ImportTrim IS NULL
	AND
	CUR.FdpImportErrorId IS NULL
	AND
	CUR2.FdpImportErrorId IS NULL
	AND
	ISNULL(T.DPCK, '') <> ''
	AND
	EX.FdpImportErrorExclusionId IS NULL
	GROUP BY
	T.DPCK
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
		, 4 AS FdpImportErrorTypeId -- Missing Trim
		, 'No OXO DPCK matching historic trim ''' + I.ImportTrim + '''' AS ErrorMessage
		, I.ImportTrim AS AdditionalData
		, 403
	FROM
	(
		SELECT DISTINCT I.ImportTrim FROM Fdp_Import_VW AS I
		LEFT JOIN Fdp_TrimMapping_VW AS T ON I.DocumentId = T.DocumentId
											AND I.ImportTrim = T.ImportTrim
		WHERE 
		FdpImportId  = @FdpImportId 
		AND 
		FdpImportQueueId = @FdpImportQueueId
		AND
		T.DPCK IS NULL
	)
	AS I
	LEFT JOIN Fdp_ImportError			AS CUR	ON	CUR.FdpImportQueueId		= @FdpImportQueueId
												AND	I.ImportTrim				= CUR.AdditionalData
												AND CUR.FdpImportErrorTypeId	= 4
												AND CUR.IsExcluded				= 0
												AND CUR.SubTypeId				= 403
	-- Don't add if there are any active missing DPCK or OXO errors
	LEFT JOIN Fdp_ImportError			AS CUR2 ON	CUR2.FdpImportQueueId		= @FdpImportQueueId
												AND	CUR2.FdpImportErrorTypeId	= 4
												AND CUR2.SubTypeId				IN (401, 402)
												AND CUR2.IsExcluded				= 0
	LEFT JOIN Fdp_ImportErrorExclusion	AS EX	ON	EX.DocumentId				= @DocumentId
												AND EX.FdpImportErrorTypeId		= 4
												AND EX.SubTypeId				= 403
												AND EX.IsActive					= 1
												AND I.ImportTrim				= EX.AdditionalData
	WHERE
	CUR.FdpImportErrorId IS NULL
	AND
	CUR2.FdpImportErrorId IS NULL
	AND
	@FlagOrphanedImportData = 1
	AND
	EX.FdpImportErrorExclusionId IS NULL
	GROUP BY
	I.ImportTrim
	ORDER BY
	ErrorMessage

	SET @ErrorCount = @ErrorCount + @@ROWCOUNT;
	
	SET @Message = CAST(@ErrorCount AS NVARCHAR(10)) + ' trim errors added';
	RAISERROR(@Message, 0, 1) WITH NOWAIT;