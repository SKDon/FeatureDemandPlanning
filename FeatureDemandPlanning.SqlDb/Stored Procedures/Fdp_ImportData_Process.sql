CREATE PROCEDURE [dbo].[Fdp_ImportData_Process] 
	  @FdpImportId	INT
	, @LineNumber	INT = NULL
AS
	SET NOCOUNT ON;
	
	DECLARE @ProgrammeId		INT;
	DECLARE @Gateway			NVARCHAR(100);
	DECLARE @OxoDocId			INT;
	DECLARE @FdpVolumeHeaderId	INT;
	DECLARE @FdpImportQueueId	INT;
	DECLARE @Message			NVARCHAR(400);
	
	SELECT 
		  @ProgrammeId = ProgrammeId
		, @Gateway = Gateway
		, @OxoDocId = DocumentId
		, @FdpImportQueueId = FdpImportQueueId
	FROM Fdp_Import
	WHERE
	FdpImportId = @FdpImportId;
	
	-- Update the status of our import to be processing
	
	SET @Message = 'Setting import to processing...'
	RAISERROR(@Message, 0, 1) WITH NOWAIT;
	
	UPDATE Fdp_ImportQueue SET FdpImportStatusId = 2
	WHERE
	FdpImportQueueId = @FdpImportQueueId
	AND
	FdpImportStatusId IN (1, 4);
	
	-- Update all prior queued imports for the same programme and gateway setting the status to cancelled

	SET @Message = 'Cancelling old imports...'
	RAISERROR(@Message, 0, 1) WITH NOWAIT
	
	UPDATE Q 
		SET FdpImportStatusId = 5 -- Cancelled
	FROM Fdp_ImportQueue	AS Q
	JOIN Fdp_Import			AS I ON Q.FdpImportQueueId = I.FdpImportQueueId
	WHERE
	I.DocumentId = @OxoDocId
	AND
	I.FdpImportId <> @FdpImportId
	AND
	Q.FdpImportStatusId = 1; -- Queued
	
	-- Remove all data from cancelled import queue items
	
	DELETE FROM Fdp_ImportData
	WHERE
	FdpImportId IN 
	(
		SELECT FdpImportId
		FROM Fdp_ImportQueue	AS Q
		JOIN Fdp_Import			AS I ON Q.FdpImportQueueId = I.FdpImportQueueId 
		WHERE
		Q.FdpImportStatusId = 5 -- Cancelled
	)
	
	-- Create exceptions of varying types based on the data that cannot be processed
	
	SET @Message = 'Adding missing markets...';
	RAISERROR(@Message, 0, 1) WITH NOWAIT;
	
	INSERT INTO Fdp_ImportError
	(
		  FdpImportQueueId
		, LineNumber
		, ErrorOn
		, FdpImportErrorTypeId
		, ErrorMessage
	)
	SELECT 
		  I.FdpImportQueueId
		, I.ImportLineNumber
		, GETDATE() AS ErrorOn
		, 1 AS FdpImportErrorTypeId -- Missing Market
		, 'Missing market ''' + I.ImportCountry + '''' AS ErrorMessage
	FROM
	Fdp_Import_VW				AS I
	LEFT JOIN Fdp_ImportError	AS CUR	ON	I.FdpImportQueueId	= CUR.FdpImportQueueId
										AND	I.ImportLineNumber	= CUR.LineNumber
										AND CUR.IsExcluded		= 0
	WHERE
	I.FdpImportId = @FdpImportId
	AND
	I.FdpImportQueueId = @FdpImportQueueId
	AND
	I.IsMarketMissing = 1
	AND
	(@LineNumber IS NULL OR I.ImportLineNumber = @LineNumber)
	AND
	CUR.FdpImportErrorId IS NULL
	
	SET @Message = CAST(@@ROWCOUNT AS NVARCHAR(10)) + ' missing market errors added';
	RAISERROR(@Message, 0, 1) WITH NOWAIT;
	
	SET @Message = 'Adding missing derivatives...';
	RAISERROR(@Message, 0, 1) WITH NOWAIT;
		
	INSERT INTO Fdp_ImportError
	(
		  FdpImportQueueId
		, LineNumber
		, ErrorOn
		, FdpImportErrorTypeId
		, ErrorMessage
	)
	SELECT 
		  I.FdpImportQueueId
		, I.ImportLineNumber
		, GETDATE() AS ErrorOn
		, 3 AS FdpImportErrorTypeId -- Missing Derivative
		, 'Missing derivative ''' + I.ImportDerivativeCode + ' - ' + I.ImportTrim + '''' AS ErrorMessage
	FROM 
	Fdp_Import_VW				AS I
	LEFT JOIN Fdp_ImportError	AS CUR	ON	I.FdpImportQueueId	= CUR.FdpImportQueueId
										AND	I.ImportLineNumber	= CUR.LineNumber
										AND CUR.IsExcluded		= 0
	WHERE
	I.FdpImportId = @FdpImportId
	AND
	I.FdpImportQueueId = @FdpImportQueueId
	AND
	I.IsDerivativeMissing = 1
	AND
	(@LineNumber IS NULL OR I.ImportLineNumber = @LineNumber)
	AND
	CUR.FdpImportErrorId IS NULL;
	
	SET @Message = CAST(@@ROWCOUNT AS NVARCHAR(10)) + ' missing derivative errors added';
	RAISERROR(@Message, 0, 1) WITH NOWAIT;
	
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
		, I.ImportLineNumber
		, GETDATE() AS ErrorOn
		, 4 AS FdpImportErrorTypeId -- Missing Trim
		, 'Missing trim ''' + I.ImportTrim + ''' for derivative ''' + I.BMC + '''' AS ErrorMessage
		, I.BMC
	FROM Fdp_Import_VW			AS I
	LEFT JOIN Fdp_ImportError	AS CUR	ON	I.FdpImportQueueId			= CUR.FdpImportQueueId
										AND	I.ImportLineNumber			= CUR.LineNumber
										AND CUR.IsExcluded		= 0
	WHERE
	I.FdpImportId = @FdpImportId
	AND
	I.FdpImportQueueId = @FdpImportQueueId
	AND
	I.IsTrimMissing = 1 
	AND
	(@LineNumber IS NULL OR I.ImportLineNumber = @LineNumber)
	AND
	CUR.FdpImportErrorId IS NULL;
	
	SET @Message = CAST(@@ROWCOUNT AS NVARCHAR(10)) + ' missing trim errors added';
	RAISERROR(@Message, 0, 1) WITH NOWAIT;
	
	SET @Message = 'Adding features...';
	RAISERROR(@Message, 0, 1) WITH NOWAIT;
		
	INSERT INTO Fdp_ImportError
	(
		  FdpImportQueueId
		, LineNumber
		, ErrorOn
		, FdpImportErrorTypeId
		, ErrorMessage
	)
	SELECT 
		  I.FdpImportQueueId
		, I.ImportLineNumber
		, GETDATE() AS ErrorOn
		, 2 AS FdpImportErrorTypeId -- Missing Feature
		, 'Missing feature ''' + I.ImportFeatureCode + ' - ' + I.ImportFeature + '''' AS ErrorMessage
	FROM Fdp_Import_VW			AS I
	LEFT JOIN Fdp_ImportError	AS CUR	ON	I.FdpImportQueueId	= CUR.FdpImportQueueId
										AND	I.ImportLineNumber	= CUR.LineNumber
										AND CUR.IsExcluded		= 0
	WHERE
	I.FdpImportId = @FdpImportId
	AND
	I.FdpImportQueueId = @FdpImportQueueId
	AND
	I.IsFeatureMissing = 1
	AND
	(@LineNumber IS NULL OR I.ImportLineNumber = @LineNumber)
	AND
	CUR.FdpImportErrorId IS NULL
	
	SET @Message = CAST(@@ROWCOUNT AS NVARCHAR(10)) + ' missing feature errors added';
	RAISERROR(@Message, 0, 1) WITH NOWAIT;
	
	-- From the import data, create an FDP_VolumeHeader entry for each distinct programme 
	-- in the import
	
	SET @Message = 'Adding header information...';
	RAISERROR(@Message, 0, 1) WITH NOWAIT;
	
	INSERT INTO Fdp_VolumeHeader
	(
		  CreatedOn
		, CreatedBy
		, DocumentId
		, FdpTakeRateStatusId
		, IsManuallyEntered
	)
	SELECT
		  MAX(I.CreatedOn)	AS CreatedOn
		, MAX(I.CreatedBy)	AS CreatedBy
		, I.DocumentId
		, 1					AS FdpTakeRateStatusId
		, 0					AS IsManuallyCreated
	FROM 
	FDP_Import_VW				AS I
	LEFT JOIN Fdp_VolumeHeader	AS CUR ON I.DocumentId = CUR.DocumentId
	WHERE 
	I.IsExistingData = 0
	AND
	I.IsMarketMissing = 0
	AND 
	I.IsDerivativeMissing = 0
	AND
	I.IsTrimMissing = 0
	AND 
	I.IsFeatureMissing = 0
	AND
	I.IsSpecialFeatureCode = 0
	AND
	I.FdpImportId = @FdpImportId
	AND
	I.FdpImportQueueId = @FdpImportQueueId
	AND
	(@LineNumber IS NULL OR I.ImportLineNumber = @LineNumber)
	AND
	CUR.FdpVolumeHeaderId IS NULL

	GROUP BY
	  I.FdpImportId
	, I.DocumentId
	
	SELECT @FdpVolumeHeaderId = FdpVolumeHeaderId
	FROM
	Fdp_VolumeHeader
	WHERE
	DocumentId = @OxoDocId;

	-- If there are no active errors for the import...
	-- For every entry in the import, create an entry in FDP_VolumeDataItem
	
	SET @Message = 'Adding volume data...';
	RAISERROR(@Message, 0, 1) WITH NOWAIT;

	INSERT INTO Fdp_VolumeDataItem
	(
		  FdpVolumeHeaderId
		, IsManuallyEntered
		, MarketId
		, MarketGroupId
		, ModelId
		, FdpModelId
		, TrimId
		, FdpTrimId
		, FeatureId
		, FdpFeatureId
		, FeaturePackId
		, Volume
	)
	SELECT
		  H.FdpVolumeHeaderId
		, 0
		, I.MarketId
		, I.MarketGroupId
		, I.ModelId
		, I.FdpModelId
		, I.TrimId
		, I.FdpTrimId
		, I.FeatureId
		, I.FdpFeatureId
		, I.FeaturePackId
		, CAST(I.ImportVolume AS INT) 
	FROM
	Fdp_Import_VW					AS I
	JOIN Fdp_VolumeHeader			AS H	ON	I.DocumentId		= H.DocumentId
	LEFT JOIN Fdp_VolumeDataItem	AS CUR	ON	H.FdpVolumeHeaderId = CUR.FdpVolumeHeaderId
											AND I.MarketId			= CUR.MarketId
											AND 
											(
												I.ModelId = CUR.ModelId
												OR
												I.FdpModelId = CUR.FdpModelId
											)
											AND 
											(
												I.FeatureId = CUR.FeatureId
												OR
												I.FdpFeatureId = CUR.FdpFeatureId
											)
											AND I.FeaturePackId				= CUR.FeaturePackId
											AND CAST(I.ImportVolume AS INT) = CUR.Volume
											AND CUR.IsManuallyEntered = 1
	WHERE 
	I.IsExistingData = 0
	AND
	I.IsMarketMissing = 0
	AND
	I.IsDerivativeMissing = 0
	AND 
	I.IsTrimMissing = 0
	AND
	I.IsFeatureMissing = 0
	AND
	I.IsSpecialFeatureCode = 0
	AND
	I.FdpImportId = @FdpImportId
	AND
	CUR.FdpVolumeDataItemId IS NULL
	
	SET @Message = CAST(@@ROWCOUNT AS NVARCHAR(10)) + ' data items added';
	RAISERROR(@Message, 0, 1) WITH NOWAIT

	-- Add the summary volume information for each market / derivative / trim level
	-- Only add information if it differs from the previous volume data
	
	SET @Message = 'Adding summary information...';
	RAISERROR(@Message, 0, 1) WITH NOWAIT
	
	INSERT INTO Fdp_TakeRateSummary
	(
		  FdpVolumeHeaderId
		, FdpSpecialFeatureMappingId
		, MarketId
		, ModelId
		, FdpModelId
		, Volume
		, PercentageTakeRate
	)
	SELECT
		  H.FdpVolumeHeaderId
		, I.FdpSpecialFeatureMappingId
		, I.MarketId
		, I.ModelId 
		, I.FdpModelId
		, I.ImportVolume
		, 0
	FROM
	Fdp_Import_VW					AS I
	JOIN Fdp_VolumeHeader			AS H	ON	I.DocumentId					= H.DocumentId
	LEFT JOIN Fdp_TakeRateSummary	AS CUR	ON	H.FdpVolumeHeaderId				= CUR.FdpVolumeHeaderId
											AND I.FdpSpecialFeatureMappingId	= CUR.FdpSpecialFeatureMappingId
											AND I.MarketId						= CUR.MarketId
											AND
											(
												I.ModelId = CUR.ModelId
												OR
												I.FdpModelId = CUR.FdpModelId
											)
											AND I.ImportVolume					<> CUR.Volume
	WHERE
	I.FdpImportId = @FdpImportId
	AND
	I.IsSpecialFeatureCode = 1
	AND
	I.IsMarketMissing = 0
	AND
	I.IsDerivativeMissing = 0
	AND
	I.IsTrimMissing = 0
	AND
	CUR.FdpTakeRateSummaryId IS NULL
	
	SET @Message = CAST(@@ROWCOUNT AS NVARCHAR(10)) + ' summary items added';
	RAISERROR(@Message, 0, 1) WITH NOWAIT
	
	-- Update the total volume mix based on the sum of the total volumes for each market and derivative
	
	DECLARE @TotalVolume INT
	SELECT @TotalVolume = SUM(S.Volume)
	FROM Fdp_VolumeHeader		AS H
	JOIN Fdp_TakeRateSummary	AS S	ON H.FdpVolumeHeaderId			= S.FdpVolumeHeaderId
	JOIN Fdp_SpecialFeature		AS SF	ON S.FdpSpecialFeatureMappingId = SF.FdpSpecialFeatureId
	WHERE
	H.DocumentId = @OxoDocId
	AND
	SF.FdpSpecialFeatureTypeId = 1 -- Volume by derivative (full year)
	
	UPDATE Fdp_VolumeHeader SET TotalVolume = @TotalVolume
	WHERE
	DocumentId = @OxoDocId
	AND
	TotalVolume <> @TotalVolume;
	
	-- Update the status of the import queue item
	
	UPDATE Q 
		SET FdpImportStatusId = 
			CASE 
				WHEN E.FdpImportErrorId IS NOT NULL THEN 4 -- Error
				ELSE 3 -- Processed
			END
	FROM Fdp_ImportQueue		AS Q
	JOIN Fdp_Import				AS I ON Q.FdpImportQueueId	= I.FdpImportQueueId
	LEFT JOIN Fdp_ImportError	AS E ON Q.FdpImportQueueId	= E.FdpImportQueueId
									 AND E.IsExcluded		= 0
	WHERE
	I.FdpImportId = @FdpImportId;