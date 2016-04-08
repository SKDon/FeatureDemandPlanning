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
	
	-- Where we have no historic trim data mapped to an OXO trim level
	
	;WITH TrimLevels AS
	(
		SELECT DocumentId, TrimId, Name, Abbreviation, [Level], DisplayOrder
		FROM Fdp_Trim_VW			AS T
		JOIN OXO_Doc				AS D	ON T.DocumentId				= D.Id
											AND ISNULL(D.Archived, 0)	= 0
		-- Ensure that this is for an active model
		JOIN OXO_Programme_Model	AS M	ON	T.ProgrammeId			= M.Programme_Id
											AND	T.BMC					= M.BMC
											AND T.TrimId				= M.Trim_Id
											AND M.Active				= 1
		WHERE
		T.IsActive = 1
		GROUP BY
		T.DocumentId, T.TrimId, T.Name, T.Abbreviation, T.[Level], T.DisplayOrder
		
		UNION
				
		SELECT DocumentId, TrimId, Name, Abbreviation, [Level], DisplayOrder
		FROM Fdp_Trim_VW					AS T
		JOIN OXO_Doc						AS D	ON T.DocumentId				= D.Id
													AND D.Archived				= 1
		-- Ensure that this is for an active model
		JOIN OXO_Archived_Programme_Model	AS M	ON	T.DocumentId			= M.Doc_Id
													AND	T.BMC					= M.BMC
													AND T.TrimId				= M.Trim_Id
													AND M.Active				= 1
		WHERE
		T.IsActive = 1															
		GROUP BY
		T.DocumentId, T.TrimId, T.Name, T.Abbreviation, T.[Level], T.DisplayOrder
	),
	ImportTrimLevels AS
	(
		SELECT @DocumentId AS DocumentId, ImportTrim
		FROM Fdp_Import_VW AS I
		WHERE 
		I.FdpImportId = @FdpImportId
		AND 
		I.FdpImportQueueId = @FdpImportQueueId
		GROUP BY 
		ImportTrim
	)
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
		, 'No historic data mapped to trim level ''' + T.Name + ' - ' + T.[Level] + '''' AS ErrorMessage
		, CAST(T.TrimId AS NVARCHAR(5)) AS AdditionalData
		, 402
	FROM 
	TrimLevels AS T	
	LEFT JOIN Fdp_TrimMapping			AS M	ON T.DocumentId						= M.DocumentId
												AND T.TrimId						= M.TrimId
												AND M.IsActive						= 1
	LEFT JOIN Fdp_ImportError			AS CUR	ON	CUR.FdpImportQueueId			= @FdpImportQueueId
												AND	CAST(T.TrimId AS NVARCHAR(20))	= CUR.AdditionalData
												AND CUR.FdpImportErrorTypeId		= 4
												AND CUR.IsExcluded					= 0
												AND CUR.SubTypeId					= 402
	LEFT JOIN Fdp_ImportErrorExclusion	AS EX	ON	T.DocumentId					= EX.DocumentId
												AND EX.FdpImportErrorTypeId			= 4
												AND EX.SubTypeId					= 402
												AND EX.IsActive						= 1
												AND CAST(T.TrimId AS NVARCHAR(20))	= EX.AdditionalData
	WHERE
	T.DocumentId = @DocumentId
	AND
	M.FdpTrimMappingId IS NULL
	AND
	CUR.FdpImportErrorId IS NULL
	AND
	EX.FdpImportErrorExclusionId IS NULL;
	
	SET @ErrorCount = @ErrorCount + @@ROWCOUNT;
	
	SET @Message = CAST(@ErrorCount AS NVARCHAR(10)) + ' trim errors added';
	RAISERROR(@Message, 0, 1) WITH NOWAIT;