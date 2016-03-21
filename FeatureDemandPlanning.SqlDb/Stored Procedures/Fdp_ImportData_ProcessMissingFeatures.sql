
CREATE PROCEDURE [dbo].[Fdp_ImportData_ProcessMissingFeatures]
	  @FdpImportId		AS INT
	, @FdpImportQueueId AS INT
	, @LineNumber		AS INT = NULL
AS
	SET NOCOUNT ON;

	DECLARE @Message AS NVARCHAR(400);
	DECLARE @ProgrammeId AS INT;
	DECLARE @Gateway AS NVARCHAR(100);
	DECLARE @DocumentId AS INT;
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

	SELECT @ProgrammeId = ProgrammeId, @Gateway = Gateway
	FROM Fdp_Import
	WHERE
	FdpImportQueueId = @FdpImportQueueId
	AND
	FdpImportId = @FdpImportId;

	SELECT TOP 1 @FlagOrphanedImportData = CAST(Value AS BIT) FROM Fdp_Configuration WHERE ConfigurationKey = 'FlagOrphanedImportDataAsError';

	SET @Message = 'Adding feature errors...';
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
		  @FdpImportQueueId AS FdpImportQueueId
		, 0 AS LineNumber
		, GETDATE() AS ErrorOn
		, 2 AS FdpImportErrorTypeId -- Feature
		, 'No feature code for ''' + ISNULL(F.BrandDescription, F.[Description]) + '''' AS ErrorMessage
		, ISNULL(F.BrandDescription, F.[Description]) AS AdditionalData
	FROM
	Fdp_FeatureMapping_VW AS F
	WHERE
	F.DocumentId = @DocumentId
	AND
	F.MappedFeatureCode IS NULL
	ORDER BY
	ErrorMessage
	
	--SELECT
	--	  I.FdpImportQueueId
	--	, I.LineNumber
	--	, I.ErrorOn
	--	, I.FdpImportErrorTypeId
	--	, I.ErrorMessage
	--	, I.AdditionalData
	--FROM
	--(
	--SELECT
	--	  @FdpImportQueueId AS FdpImportQueueId
	--	, 0 AS LineNumber
	--	, GETDATE() AS ErrorOn
	--	, 2 AS FdpImportErrorTypeId -- Missing Feature
	--	, 'No historic Feature Code matching OXO feature ''' + F.MappedFeatureCode + ' - ' + ISNULL(F.BrandDescription, F.[Description]) + '''' AS ErrorMessage
	--	, F.MappedFeatureCode AS AdditionalData
	--FROM Fdp_FeatureMapping_VW AS F
	--LEFT JOIN 
	--(
	--	SELECT FdpImportQueueId, ImportFeatureCode
	--	FROM Fdp_Import_VW AS I
	--	WHERE 
	--	I.FdpImportId = @FdpImportId
	--	AND 
	--	I.FdpImportQueueId = @FdpImportQueueId
	--	GROUP BY 
	--	FdpImportQueueId, ImportFeatureCode
	--)
	--AS I1 ON F.ImportFeatureCode = I1.ImportFeatureCode
	--LEFT JOIN Fdp_ImportError	AS CUR	ON	CUR.FdpImportQueueId = @FdpImportQueueId
	--										AND	F.MappedFeatureCode	= CUR.AdditionalData
	--										AND CUR.FdpImportErrorTypeId = 2
	--										AND CUR.IsExcluded = 0
	--WHERE 
	--F.DocumentId = @DocumentId
	--AND
	--I1.ImportFeatureCode IS NULL
	--AND
	--CUR.FdpImportErrorId IS NULL
	--AND
	--F.MappedFeatureCode IS NOT NULL

	--UNION

	--SELECT 
	--	  @FdpImportQueueId AS FdpImportQueueId
	--	, 0 AS LineNumber
	--	, GETDATE() AS ErrorOn
	--	, 2 AS FdpImportErrorTypeId -- Missing Derivative
	--	, 'No OXO Feature Code matching historic Feature ''' + I.ImportFeatureCode + ' - ' + I.ImportFeature + '''' AS ErrorMessage
	--	, I.ImportFeatureCode AS AdditionalData
	--FROM
	--(
	--	SELECT DISTINCT I.ImportFeatureCode, I.ImportFeature FROM Fdp_Import_VW AS I
	--	LEFT JOIN Fdp_FeatureMapping_VW AS F ON I.DocumentId = F.DocumentId
	--										AND I.ImportFeatureCode = F.ImportFeatureCode
	--	WHERE FdpImportId  = @FdpImportId AND FdpImportQueueId = @FdpImportQueueId
	--	AND
	--	F.MappedFeatureCode IS NULL
	--)
	--AS I
	--LEFT JOIN Fdp_ImportError	AS CUR	ON	CUR.FdpImportQueueId = @FdpImportQueueId
	--										AND	I.ImportFeatureCode	= CUR.AdditionalData
	--										AND CUR.FdpImportErrorTypeId = 2
	--										AND CUR.IsExcluded = 0
	--WHERE
	--CUR.FdpImportErrorId IS NULL
	--AND
	--@FlagOrphanedImportData = 1

	--UNION
	
	--SELECT 
	--	  @FdpImportQueueId AS FdpImportQueueId
	--	, 0 AS LineNumber
	--	, GETDATE() AS ErrorOn
	--	, 2 AS FdpImportErrorTypeId -- Feature
	--	, 'No feature code for ''' + ISNULL(F.BrandDescription, F.[Description]) + '''' AS ErrorMessage
	--	, ISNULL(F.BrandDescription, F.[Description]) AS AdditionalData
	--FROM
	--Fdp_FeatureMapping_VW AS F
	--WHERE
	--F.DocumentId = @DocumentId
	--AND
	--F.MappedFeatureCode IS NULL
	--)
	--AS I
	--ORDER BY I.ErrorMessage

	SET @Message = CAST(@@ROWCOUNT AS NVARCHAR(10)) + ' feature errors added';
	RAISERROR(@Message, 0, 1) WITH NOWAIT;