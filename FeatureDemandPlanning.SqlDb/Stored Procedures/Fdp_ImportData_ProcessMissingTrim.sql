CREATE PROCEDURE [dbo].[Fdp_ImportData_ProcessMissingTrim]
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
		  @FdpImportQueueId
		, 0
		, GETDATE() AS ErrorOn
		, 4 AS FdpImportErrorTypeId -- Missing Trim
		, 'No import data matching OXO trim ''' + T.DPCK + '''' AS ErrorMessage
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
	T.ProgrammeId = @ProgrammeId
	AND 
	T.Gateway = @Gateway
	AND
	I1.ImportTrim IS NULL
	AND
	CUR.FdpImportErrorId IS NULL

	UNION

	SELECT 
		  @FdpImportQueueId
		, 0
		, GETDATE() AS ErrorOn
		, 4 AS FdpImportErrorTypeId -- Missing Trim
		, 'No OXO trim mapped for ''' + I.ImportTrim + '''' AS ErrorMessage
		, I.ImportTrim AS AdditionalData
	FROM
	(
		SELECT DISTINCT I.ImportTrim FROM Fdp_Import_VW AS I
		LEFT JOIN Fdp_TrimMapping_VW AS T ON I.ProgrammeId = T.ProgrammeId
											AND I.Gateway	= T.Gateway
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
	CUR.FdpImportErrorId IS NULL;
	
	SET @Message = CAST(@@ROWCOUNT AS NVARCHAR(10)) + ' missing trim errors added';
	RAISERROR(@Message, 0, 1) WITH NOWAIT;