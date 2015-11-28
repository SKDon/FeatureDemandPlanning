CREATE PROCEDURE [dbo].[Fdp_ImportData_Process] 
	  @FdpImportId	INT
	, @LineNumber	INT = NULL
AS

	SET NOCOUNT ON;
	
	DECLARE @ProgrammeId INT;
	DECLARE @Gateway NVARCHAR(100);
	DECLARE @FdpImportQueueId INT;
	
	-- Update the status of our import to be processing
	
	PRINT 'Setting import to processing...'

	UPDATE Q SET FdpImportStatusId = 2
	FROM
	Fdp_Import AS I
	JOIN Fdp_ImportQueue AS Q ON I.FdpImportQueueId = Q.FdpImportQueueId
	WHERE
	I.FdpImportId = @FdpImportId
	AND
	Q.FdpImportStatusId IN (1, 4)
	
	-- Update all prior queued imports for the same programme and gateway setting the status to cancelled
	
	PRINT 'Cancelling old imports...'
	
	SELECT 
		  @ProgrammeId = ProgrammeId
		, @Gateway = Gateway
		, @FdpImportQueueId = FdpImportQueueId
	FROM Fdp_Import
	WHERE
	FdpImportId = @FdpImportId;
	
	UPDATE Q 
		SET FdpImportStatusId = 5 -- Cancelled
	FROM Fdp_ImportQueue	AS Q
	JOIN Fdp_Import			AS I ON Q.FdpImportQueueId = I.FdpImportQueueId
	WHERE
	I.ProgrammeId = @ProgrammeId
	AND
	I.Gateway = @Gateway
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
	
	PRINT 'Adding exceptions report'
	
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
	I.IsMarketMissing = 1
	AND
	(@LineNumber IS NULL OR I.ImportLineNumber = @LineNumber)
	AND
	CUR.FdpImportErrorId IS NULL
		
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
	I.IsDerivativeMissing = 1
	AND
	(@LineNumber IS NULL OR I.ImportLineNumber = @LineNumber)
	AND
	CUR.FdpImportErrorId IS NULL
	
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
	I.IsTrimMissing = 1 
	AND
	(@LineNumber IS NULL OR I.ImportLineNumber = @LineNumber)
	AND
	CUR.FdpImportErrorId IS NULL
		
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
	I.IsFeatureMissing = 1
	AND
	(@LineNumber IS NULL OR I.ImportLineNumber = @LineNumber)
	AND
	CUR.FdpImportErrorId IS NULL
	
	-- Update the status of the report to error if we have any
	
	UPDATE Q SET FdpImportStatusId = 4
	FROM Fdp_Import AS I
	JOIN Fdp_ImportQueue AS Q ON I.FdpImportQueueId = Q.FdpImportQueueId
	JOIN Fdp_ImportError AS E ON Q.FdpImportQueueId = E.FdpImportQueueId
							  AND E.IsExcluded		= 0
	WHERE
	I.FdpImportId = @FdpImportId;
	
	-- From the import data, create an FDP_VolumeHeader entry for each distinct programme 
	-- in the import
	
	PRINT 'Adding header information'

	INSERT INTO Fdp_VolumeHeader
	(
		  CreatedOn
		, CreatedBy
		, ProgrammeId
		, Gateway
		, FdpImportId
		, IsManuallyEntered
	)
	SELECT
		  MAX(I.CreatedOn)	AS CreatedOn
		, MAX(I.CreatedBy)	AS CreatedBy
		, I.ProgrammeId
		, I.Gateway
		, I.FdpImportId
		, 0					AS IsManuallyCreated
	FROM 
	FDP_Import_VW				AS I
	LEFT JOIN Fdp_VolumeHeader	AS CUR ON I.FdpImportId = CUR.FdpImportId
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
	, I.ProgrammeId
	, I.Gateway;

	-- If there are no active errors for the import...
	-- For every entry in the import, create an entry in FDP_VolumeDataItem
	
	PRINT 'Adding volume data'

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
		, NULL
		, I.FeaturePackId
		, CAST(I.ImportVolume AS INT) 
	FROM
	Fdp_Import_VW					AS I
	JOIN Fdp_VolumeHeader			AS H	ON	I.FdpImportId		= H.FdpImportId
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
	(@LineNumber IS NULL OR I.ImportLineNumber = @LineNumber)
	AND
	CUR.FdpVolumeDataItemId IS NULL
	--AND
	--I.FdpImportStatusId <> 4
	
	-- Need to group here, as if there are results from the view where multiple import lines
	-- match the same trim / engine mapping for the programme / market in question
	-- we need to aggregate the take rate
	 
	--GROUP BY
	--	  H.FdpVolumeHeaderId
	--	, I.MarketId
	--	, I.MarketGroupId
	--	, I.ModelId
	--	, I.TrimId
	--	, I.FeatureId
	--	, I.FeaturePackId;

	-- Add the summary volume information for each market / derivative / trim level
	-- Only add information if it differs from the previous volume data
	
	PRINT 'Adding summary information'

	INSERT INTO Fdp_Volume
	(
		  FdpVolumeHeaderId
		, IsManuallyEntered
		, MarketId
		, MarketGroupId
		, ModelId
		, TrimId
		, EngineId
		, Volume
	)
	SELECT
		  H.FdpVolumeHeaderId
		, 0
		, I.MarketId
		, I.MarketGroupId
		, I.ModelId
		, I.TrimId
		, I.EngineId
		, I.TotalVolume
	FROM
	Fdp_ImportVolume_VW		AS I
	JOIN Fdp_VolumeHeader	AS H	ON I.FdpImportId	= H.FdpImportId
	LEFT JOIN Fdp_Volume	AS CUR	ON I.MarketId		= CUR.MarketId
									AND	I.MarketGroupId	= CUR.MarketGroupId
									AND I.ModelId		= CUR.ModelId
									AND I.TotalVolume	= CUR.Volume
									AND I.TrimId		= CUR.TrimId 
	WHERE
	I.FdpImportId = @FdpImportId
	AND
	CUR.FdpVolumeId IS NULL;
	
	-- Update the total volume mix based on the sum of the total volumes for each market and derivative
	
	DECLARE @TotalVolume INT
	SELECT @TotalVolume = SUM(I.TotalVolume)
	FROM Fdp_ImportVolume_VW	AS I
	WHERE
	I.FdpImportId = @FdpImportId;
	
	UPDATE Fdp_VolumeHeader SET TotalVolume = @TotalVolume
	WHERE
	FdpImportId = @FdpImportId
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