CREATE PROCEDURE [dbo].[Fdp_ImportData_ProcessMissingTrim]
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
	FdpImportErrorTypeId = 4

	SET @Message = 'Adding missing trim...';
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
		, 4 AS FdpImportErrorTypeId -- Missing Trim
		, '2 - No import data matching OXO trim ''' + T.DPCK + '''' AS ErrorMessage
		, T.DPCK AS AdditionalData
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
	LEFT JOIN Fdp_ImportError	AS CUR	ON	CUR.FdpImportQueueId = @FdpImportQueueId
											AND	T.DPCK	= CUR.AdditionalData
											AND CUR.FdpImportErrorTypeId = 4
											AND CUR.IsExcluded = 0
	WHERE 
	T.DocumentId = @DocumentId
	AND
	I1.ImportTrim IS NULL
	AND
	CUR.FdpImportErrorId IS NULL
	AND
	ISNULL(T.DPCK, '') <> ''

	UNION

	SELECT 
		  @FdpImportQueueId AS FdpImportQueueId
		, 0 AS LineNumber
		, GETDATE() AS ErrorOn
		, 4 AS FdpImportErrorTypeId -- Missing Trim
		, '3 - No OXO trim mapped for ''' + I.ImportTrim + '''' AS ErrorMessage
		, I.ImportTrim AS AdditionalData
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
	LEFT JOIN Fdp_ImportError	AS CUR	ON	CUR.FdpImportQueueId = @FdpImportQueueId
											AND	I.ImportTrim	= CUR.AdditionalData
											AND CUR.FdpImportErrorTypeId = 4
											AND CUR.IsExcluded = 0
	WHERE
	CUR.FdpImportErrorId IS NULL

	UNION

	-- Where we have no DPCK code defined for a trim level

	SELECT
		  @FdpImportQueueId AS FdpImportQueueId
		, 0 AS LineNumber
		, GETDATE() AS ErrorOn
		, 4 AS FdpImportErrorTypeId
		, '1 - No DPCK code defined for ''' + T.Name + ' - ' + T.[Level] + '''' AS ErrorMessage
		, T.Name + ' ' + T.[Level] AS AdditionalData

	FROM OXO_Programme_Trim AS T
	LEFT JOIN Fdp_ImportError	AS CUR	ON	CUR.FdpImportQueueId = @FdpImportQueueId
											AND T.Name + ' ' + T.[Level] = CUR.AdditionalData
											AND CUR.FdpImportErrorTypeId = 4
											AND CUR.IsExcluded = 0
	WHERE
	T.Programme_Id = @ProgrammeId
	AND
	ISNULL(T.DPCK, '') = ''
	GROUP BY
	T.Name, T.[Level]

	UNION

	SELECT
		  @FdpImportQueueId AS FdpImportQueueId
		, 0 AS LineNumber
		, GETDATE() AS ErrorOn
		, 4 AS FdpImportErrorTypeId
		, '1 - No DPCK code defined for ''' + T.Name + ' - ' + T.[Level] + '''' AS ErrorMessage
		, T.Name + ' ' + T.[Level] AS AdditionalData

	FROM OXO_Archived_Programme_Trim AS T
	LEFT JOIN Fdp_ImportError	AS CUR	ON	CUR.FdpImportQueueId = @FdpImportQueueId
											AND T.Name + ' ' + T.[Level] = CUR.AdditionalData
											AND CUR.FdpImportErrorTypeId = 4
											AND CUR.IsExcluded = 0
	WHERE
	T.Doc_Id = @DocumentId
	AND
	ISNULL(T.DPCK, '') = ''
	GROUP BY
	T.Name, T.[Level]
	)
	AS I
	ORDER BY I.ErrorMessage
	
	SET @Message = CAST(@@ROWCOUNT AS NVARCHAR(10)) + ' missing trim errors added';
	RAISERROR(@Message, 0, 1) WITH NOWAIT;