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
	
	DECLARE @TrimError AS TABLE
	(
		  FdpImportQueueId INT
		, DocumentId INT
		, ModelId INT
	)
	INSERT INTO @TrimError
	SELECT
		  @FdpImportQueueId AS FdpImportQueueId
		  , T.DocumentId
		  , T.ModelId
		
	FROM Fdp_TrimMapping_VW AS T				
	LEFT JOIN 
	(
		SELECT FdpImportQueueId, BMC, DPCK, ImportTrim
		FROM Fdp_Import_VW AS I
		WHERE 
		I.FdpImportId = @FdpImportId
		AND 
		I.FdpImportQueueId = @FdpImportQueueId
		GROUP BY 
		FdpImportQueueId, BMC, DPCK, ImportTrim
	)
	AS I1 ON	T.ImportTrim	= I1.ImportTrim
		  AND	T.BMC			= I1.BMC
		  AND	T.DPCK			= I1.DPCK
	
	LEFT JOIN Fdp_ImportError			AS CUR	ON	CUR.FdpImportQueueId		= @FdpImportQueueId
												AND	T.BMC + '|' + T.DPCK		= CUR.AdditionalData
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
												AND T.BMC + '|' + T.DPCK		= EX.AdditionalData
	-- If the BMC is set to be ignored, don't raise any trim errors associated with it
	LEFT JOIN Fdp_ImportErrorExclusion	AS EX2	ON	EX2.DocumentId				= @DocumentId
												AND EX2.FdpImportErrorTypeId	= 3
												AND EX2.SubTypeId				= 302
												AND EX2.IsActive				= 1
												AND T.BMC						= EX2.AdditionalData
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
	ISNULL(T.BMC, '') <> ''
	AND
	EX.FdpImportErrorExclusionId IS NULL
	AND
	EX2.FdpImportErrorExclusionId IS NULL
	GROUP BY
	T.DocumentId, T.ModelId
	
	;WITH ModelDetails AS 
	(
		SELECT
			  D.Id AS DocumentId
			, V.Display_Format
			, M.Id AS ModelId
			, M.BMC
			, TR.DPCK
			, TR.[Level]
			, dbo.OXO_GetVariantName(
				  V.Display_Format
				, B.Shape
				, B.Doors
				, B.Wheelbase
				, E.Size
				, E.Fuel_Type
				, E.Cylinder
				, E.Turbo
				, E.[Power]
				, T.Drivetrain
				, T.[Type]
				, TR.Name
				, TR.[Level]
				, M.KD
				, 0
			) AS ModelDescription
		FROM
		OXO_Doc AS D
		JOIN OXO_Programme_VW			AS P	ON	D.Programme_Id		= P.Id
		JOIN OXO_Vehicle				AS V	ON	P.VehicleId			= V.Id
		JOIN OXO_Programme_Model		AS M	ON	D.Programme_Id		= M.Programme_Id
		JOIN OXO_Programme_Body			AS B	ON	M.Body_Id			= B.Id
		JOIN OXO_Programme_Engine		AS E	ON	M.Engine_Id			= E.Id
		JOIN OXO_Programme_Transmission AS T	ON	M.Transmission_Id	= T.Id
		JOIN OXO_Programme_Trim			AS TR	ON	M.Trim_Id			= TR.Id
		WHERE
		ISNULL(D.Archived, 0) = 0
		
		UNION
		
		SELECT
			  D.Id AS DocumentId
			, V.Display_Format
			, M.Id AS ModelId
			, M.BMC
			, TR.DPCK
			, TR.[Level]
			, dbo.OXO_GetVariantName(
				  V.Display_Format
				, B.Shape
				, B.Doors
				, B.Wheelbase
				, E.Size
				, E.Fuel_Type
				, E.Cylinder
				, E.Turbo
				, E.[Power]
				, T.Drivetrain
				, T.[Type]
				, TR.Name
				, TR.[Level]
				, M.KD
				, 0
			) AS ModelDescription
		FROM
		OXO_Doc AS D
		JOIN OXO_Programme_VW						AS P	ON	D.Programme_Id		= P.Id
		JOIN OXO_Vehicle							AS V	ON	P.VehicleId			= V.Id
		JOIN OXO_Archived_Programme_Model			AS M	ON	D.Programme_Id		= M.Programme_Id
															AND D.Id				= M.Doc_Id
		JOIN OXO_Archived_Programme_Body			AS B	ON	M.Body_Id			= B.Id
															AND D.Id				= B.Doc_Id
		JOIN OXO_Archived_Programme_Engine			AS E	ON	M.Engine_Id			= E.Id
															AND D.Id				= E.Doc_Id
		JOIN OXO_Archived_Programme_Transmission	AS T	ON	M.Transmission_Id	= T.Id
															AND D.Id				= T.Doc_Id
		JOIN OXO_Archived_Programme_Trim			AS TR	ON	M.Trim_Id			= TR.Id
															AND D.Id				= TR.Doc_Id
		WHERE
		ISNULL(D.Archived, 0) = 1
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
		  E.FdpImportQueueId
		, 0 AS LineNumber
		, GETDATE() AS ErrorOn
		, 4 AS FdpImportErrorTypeId -- Missing Trim
		, 'No historic data mapping to OXO model ''' + D.ModelDescription + '''' AS ErrorMessage
		, D.BMC + '|' + D.DPCK AS AdditionalData
		, 402 AS SubTypeId
	FROM @TrimError AS E
	JOIN ModelDetails AS D ON E.DocumentId = D.DocumentId
							AND E.ModelId = D.ModelId
	ORDER BY
	D.BMC, D.[Level]

	SET @ErrorCount = @ErrorCount + @@ROWCOUNT;
	
	--INSERT INTO Fdp_ImportError
	--(
	--	  FdpImportQueueId
	--	, LineNumber
	--	, ErrorOn
	--	, FdpImportErrorTypeId
	--	, ErrorMessage
	--	, AdditionalData
	--	, SubTypeId
	--)
	--SELECT 
	--	  @FdpImportQueueId AS FdpImportQueueId
	--	, 0 AS LineNumber
	--	, GETDATE() AS ErrorOn
	--	, 4 AS FdpImportErrorTypeId -- Missing Trim
	--	, 'No OXO DPCK matching historic trim ''' + I.ImportTrim + '''' AS ErrorMessage
	--	, I.ImportTrim AS AdditionalData
	--	, 403
	--FROM
	--(
	--	SELECT DISTINCT I.ImportTrim FROM Fdp_Import_VW AS I
	--	LEFT JOIN Fdp_TrimMapping_VW AS T ON I.DocumentId = T.DocumentId
	--										AND I.ImportTrim = T.ImportTrim
	--	WHERE 
	--	FdpImportId  = @FdpImportId 
	--	AND 
	--	FdpImportQueueId = @FdpImportQueueId
	--	AND
	--	T.DPCK IS NULL
	--)
	--AS I
	--LEFT JOIN Fdp_ImportError			AS CUR	ON	CUR.FdpImportQueueId		= @FdpImportQueueId
	--											AND	I.ImportTrim				= CUR.AdditionalData
	--											AND CUR.FdpImportErrorTypeId	= 4
	--											AND CUR.IsExcluded				= 0
	--											AND CUR.SubTypeId				= 403
	---- Don't add if there are any active missing DPCK or OXO errors
	--LEFT JOIN Fdp_ImportError			AS CUR2 ON	CUR2.FdpImportQueueId		= @FdpImportQueueId
	--											AND	CUR2.FdpImportErrorTypeId	= 4
	--											AND CUR2.SubTypeId				IN (401, 402)
	--											AND CUR2.IsExcluded				= 0
	--LEFT JOIN Fdp_ImportErrorExclusion	AS EX	ON	EX.DocumentId				= @DocumentId
	--											AND EX.FdpImportErrorTypeId		= 4
	--											AND EX.SubTypeId				= 403
	--											AND EX.IsActive					= 1
	--											AND I.ImportTrim				= EX.AdditionalData
	--WHERE
	--CUR.FdpImportErrorId IS NULL
	--AND
	--CUR2.FdpImportErrorId IS NULL
	--AND
	--@FlagOrphanedImportData = 1
	--AND
	--EX.FdpImportErrorExclusionId IS NULL
	--GROUP BY
	--I.ImportTrim
	--ORDER BY
	--ErrorMessage

	--SET @ErrorCount = @ErrorCount + @@ROWCOUNT;
	
	SET @Message = CAST(@ErrorCount AS NVARCHAR(10)) + ' trim errors added';
	RAISERROR(@Message, 0, 1) WITH NOWAIT;