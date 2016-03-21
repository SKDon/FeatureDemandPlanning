
CREATE PROCEDURE [dbo].[Fdp_ImportData_ProcessMissingFeatures]
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
	FdpImportErrorTypeId = 2
	
	IF EXISTS(
		SELECT TOP 1 1 
		FROM 
		Fdp_ImportError 
		WHERE 
		FdpImportQueueId = @FdpImportQueueId
		AND
		FdpImportErrorTypeId IN (1, 3, 4))
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

	SET @Message = 'Adding feature errors...';
	RAISERROR(@Message, 0, 1) WITH NOWAIT;
	
	-- Uncoded features
		
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
		, 2 AS FdpImportErrorTypeId -- Feature
		, 'No feature code for ''' + ISNULL(F.BrandDescription, F.[Description]) + '''' AS ErrorMessage
		, ISNULL(F.BrandDescription, F.[Description]) AS AdditionalData
		, 201 -- No feature coded
	FROM
	OXO_Doc								AS D
	JOIN Fdp_FeatureMapping_VW			AS F	ON D.Id											= F.DocumentId
	LEFT JOIN Fdp_ImportError			AS CUR	ON	CUR.FdpImportQueueId						= @FdpImportQueueId
												AND ISNULL(F.BrandDescription, F.Description)	= CUR.AdditionalData
												AND CUR.FdpImportErrorTypeId	= 2
												AND CUR.IsExcluded				= 0
	LEFT JOIN Fdp_ImportErrorExclusion	AS EX	ON	EX.DocumentId				= @DocumentId
												AND EX.FdpImportErrorTypeId		= 2
												AND EX.SubTypeId				= 201
												AND EX.IsActive					= 1
												AND ISNULL(F.BrandDescription, F.Description)	= EX.AdditionalData
	WHERE
	D.Id = @DocumentId
	AND
	F.MappedFeatureCode IS NULL
	AND
	EX.FdpImportErrorExclusionId IS NULL
	GROUP BY
	F.BrandDescription, F.[Description]
	ORDER BY
	ErrorMessage
	
	SET @ErrorCount = @ErrorCount + @@ROWCOUNT;
	
	-- OXO Feature Code that does not map onto historic data
	
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
		, 2 AS FdpImportErrorTypeId -- Missing Feature
		, 'No historic Feature Code matching OXO feature ''' + F.MappedFeatureCode + ' - ' + ISNULL(F.BrandDescription, F.[Description]) + '''' AS ErrorMessage
		, F.MappedFeatureCode AS AdditionalData
		, 202
	FROM 
	OXO_Doc						AS D
	JOIN Fdp_FeatureMapping_VW	AS F	ON D.Id = F.DocumentId
	LEFT JOIN 
	(
		SELECT FdpImportQueueId, ImportFeatureCode
		FROM Fdp_Import_VW AS I
		WHERE 
		I.FdpImportId = @FdpImportId
		AND 
		I.FdpImportQueueId = @FdpImportQueueId
		GROUP BY 
		FdpImportQueueId, ImportFeatureCode
	)
	AS I1 ON F.ImportFeatureCode = I1.ImportFeatureCode
	LEFT JOIN Fdp_ImportError			AS CUR	ON	CUR.FdpImportQueueId		= @FdpImportQueueId
												AND F.MappedFeatureCode			= CUR.AdditionalData
												AND CUR.FdpImportErrorTypeId	= 2
												AND CUR.IsExcluded				= 0
	-- Don't add if there are any active missing Feature Code errors
	LEFT JOIN Fdp_ImportError			AS CUR2 ON	CUR2.FdpImportQueueId = @FdpImportQueueId
												AND	CUR2.FdpImportErrorTypeId	= 2
												AND CUR2.SubTypeId				= 201
												AND CUR2.IsExcluded				= 0
	LEFT JOIN Fdp_ImportErrorExclusion	AS EX	ON	EX.DocumentId				= @DocumentId
												AND EX.FdpImportErrorTypeId		= 2
												AND EX.SubTypeId				= 202
												AND EX.IsActive					= 1
												AND ISNULL(F.BrandDescription, F.Description)	= EX.AdditionalData
	WHERE 
	D.Id = @DocumentId
	AND
	I1.ImportFeatureCode IS NULL
	AND
	CUR.FdpImportErrorId IS NULL
	AND
	CUR2.FdpImportErrorId IS NULL
	AND
	F.MappedFeatureCode IS NOT NULL
	
	SET @ErrorCount = @ErrorCount + @@ROWCOUNT;
	
	-- Historic data that does not map onto an OXO feature code

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
		, 2 AS FdpImportErrorTypeId
		, 'No OXO Feature Code matching historic feature ''' + I.ImportFeatureCode + ' - ' + I.ImportFeature + '''' AS ErrorMessage
		, I.ImportFeatureCode AS AdditionalData
		, 203
	FROM
	OXO_Doc AS D
	JOIN 
	(
		SELECT
			  I.DocumentId 
			, I.ImportFeatureCode
			, I.ImportFeature 
		FROM Fdp_Import_VW AS I
		LEFT JOIN Fdp_FeatureMapping_VW AS F ON I.DocumentId		= F.DocumentId
											AND I.ImportFeatureCode = F.ImportFeatureCode
		WHERE 
		FdpImportId = @FdpImportId 
		AND 
		FdpImportQueueId = @FdpImportQueueId
		AND
		F.MappedFeatureCode IS NULL
		GROUP BY
		  I.DocumentId
		, I.ImportFeatureCode
		, I.ImportFeature
	)
	AS I ON D.Id = I.DocumentId
	LEFT JOIN Fdp_ImportError			AS CUR	ON	CUR.FdpImportQueueId		= @FdpImportQueueId
												AND	I.ImportFeatureCode			= CUR.AdditionalData
												AND CUR.FdpImportErrorTypeId	= 2
												AND CUR.IsExcluded				= 0
	-- Don't add if there are any active missing Feature Code or OXO Feature errors
	LEFT JOIN Fdp_ImportError			AS CUR2 ON	CUR2.FdpImportQueueId = @FdpImportQueueId
												AND	CUR2.FdpImportErrorTypeId	= 2
												AND CUR2.SubTypeId				IN (201, 202)
												AND CUR2.IsExcluded				= 0
	LEFT JOIN Fdp_ImportErrorExclusion	AS EX	ON	EX.DocumentId				= @DocumentId
												AND EX.FdpImportErrorTypeId		= 2
												AND EX.SubTypeId				= 203
												AND EX.IsActive					= 1
												AND I.ImportFeatureCode			= EX.AdditionalData
	WHERE
	CUR.FdpImportErrorId IS NULL
	AND
	CUR2.FdpImportErrorId IS NULL
	AND
	@FlagOrphanedImportData = 1
	GROUP BY
	I.ImportFeatureCode, I.ImportFeature
	ORDER BY
	ErrorMessage
	
	SET @ErrorCount = @ErrorCount + @@ROWCOUNT;

	SET @Message = CAST(@ErrorCount AS NVARCHAR(10)) + ' feature errors added';
	RAISERROR(@Message, 0, 1) WITH NOWAIT;