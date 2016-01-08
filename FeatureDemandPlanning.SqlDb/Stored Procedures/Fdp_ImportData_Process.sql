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
	DECLARE @MarketMix AS TABLE
	(
		  FdpVolumeHeaderId INT
		, CreatedBy NVARCHAR(16)
		, FdpSpecialFeatureMappingId INT
		, MarketId INT
		, Volume INT
		, PercentageTakeRate DECIMAL(5, 4)
	)
	DECLARE @TotalVolume AS INT;
	
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
	-- in the import. Note that if a volume header (take rate file) already exists
	-- data will be added to that
	-- If the last take rate file has been published, a new file will be created if necessary
	
	IF NOT EXISTS
	(
		SELECT TOP 1 1 
		FROM Fdp_VolumeHeader
		WHERE
		DocumentId = @OxoDocId
		AND
		FdpTakeRateStatusId <> 3
	)
	BEGIN
		SET @Message = 'Adding take rate file...';
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
			  I.CreatedOn
			, I.CreatedBy
			, I.DocumentId
			, 1					AS FdpTakeRateStatusId
			, 0					AS IsManuallyCreated
		FROM 
		FDP_Import	AS I
		WHERE 
		I.DocumentId = @OxoDocId
		
		SELECT @FdpVolumeHeaderId = SCOPE_IDENTITY();
		
		SET @Message = CAST(@@ROWCOUNT AS NVARCHAR(10)) + ' take rate file added';
		RAISERROR(@Message, 0, 1) WITH NOWAIT;
		
	END
	ELSE
	BEGIN
		SELECT @FdpVolumeHeaderId = MAX(FdpVolumeHeaderId)
		FROM
		Fdp_VolumeHeader
		WHERE
		DocumentId = @OxoDocId
		AND
		FdpTakeRateStatusId <> 3;
	END

	-- If there are no active errors for the import...
	-- For every entry in the import, create an entry in FDP_VolumeDataItem
	
	SET @Message = 'Adding volume data...';
	RAISERROR(@Message, 0, 1) WITH NOWAIT;
	
	CREATE TABLE #NewData
	(
		  FdpVolumeHeaderId INT
		, IsManuallyEntered BIT
		, MarketId INT
		, MarketGroupId INT
		, ModelId INT NULL
		, FdpModelId INT NULL
		, TrimId INT NULL
		, FdpTrimId INT NULL
		, FeatureId INT NULL
		, FdpFeatureId INT NULL
		, FeaturePackId INT NULL
		, Volume INT
		, IsMarketMissing BIT
		, IsDerivativeMissing BIT
		, IsTrimMissing BIT
		, IsFeatureMissing BIT
		, IsSpecialFeatureCode BIT
	)
	INSERT INTO #NewData
	SELECT
		  @FdpVolumeHeaderId AS FdpVolumeHeaderId
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
		, I.IsMarketMissing
		, I.IsDerivativeMissing
		, I.IsTrimMissing
		, I.IsFeatureMissing
		, I.IsSpecialFeatureCode
	FROM
	Fdp_Import_VW					AS I
	WHERE 
	I.IsExistingData = 0
	AND
	I.FdpImportId = @FdpImportId
	AND
	I.FdpImportQueueId = @FdpImportQueueId;
	
	CREATE NONCLUSTERED INDEX Tmp_Ix_NewData ON #NewData
	(
		  IsMarketMissing
		, IsDerivativeMissing
		, IsTrimMissing
		, IsFeatureMissing
		, IsSpecialFeatureCode
	);

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
	FROM #NewData
	WHERE
	IsMarketMissing = 0
	AND
	IsDerivativeMissing = 0
	AND
	IsTrimMissing = 0
	AND
	IsFeatureMissing = 0
	AND
	IsSpecialFeatureCode = 0;
	
	-- Increment the revision version if any new rows have been added
	-- This will either end up as 1 if there is no prior data, or up the minor version
	IF @@ROWCOUNT > 0
	BEGIN
		EXEC Fdp_TakeRateHeader_IncrementRevision @FdpVolumeHeaderId = @FdpVolumeHeaderId
	END
	
	DROP TABLE #NewData;
	
	SET @Message = CAST(@@ROWCOUNT AS NVARCHAR(10)) + ' data items added';
	RAISERROR(@Message, 0, 1) WITH NOWAIT

	-- Add the summary volume information for each market / derivative / trim level
	-- Only add information if it differs from the previous volume data
	
	SET @Message = 'Adding summary information...';
	RAISERROR(@Message, 0, 1) WITH NOWAIT

	SELECT DISTINCT FdpImportId FROM Fdp_Import_VW
	
	INSERT INTO Fdp_TakeRateSummary
	(
		  FdpVolumeHeaderId
		, CreatedBy
		, FdpSpecialFeatureMappingId
		, MarketId
		, ModelId
		, FdpModelId
		, Volume
		, PercentageTakeRate
	)
	SELECT
		  H.FdpVolumeHeaderId
		, I.CreatedBy
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

	-- Add summary rows for the volume and % take at market level, ignoring the model mix

	INSERT INTO @MarketMix
	(
		  FdpVolumeHeaderId
		, CreatedBy
		, FdpSpecialFeatureMappingId
		, MarketId
		, Volume
		, PercentageTakeRate
	)
	SELECT
		  H.FdpVolumeHeaderId
		, H.CreatedBy
		, I.FdpSpecialFeatureMappingId
		, I.MarketId
		, SUM(CAST(I.ImportVolume AS INT))
		, 0
	FROM
	Fdp_Import_VW					AS I
	JOIN Fdp_VolumeHeader			AS H	ON	I.DocumentId					= H.DocumentId
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
	GROUP BY
	  H.FdpVolumeHeaderId
	, H.CreatedBy
	, I.FdpSpecialFeatureMappingId
	, I.MarketId

	-- Update existing summary entries at market level

	--SELECT M.* FROM @MarketMix AS M
	--JOIN Fdp_TakeRateSummary AS S ON M.FdpVolumeHeaderId = S.FdpVolumeHeaderId
	--										AND M.MarketId = S.MarketId
	--										AND S.ModelId IS NULL
	--										AND S.FdpModelId IS NULL
	--										AND M.FdpSpecialFeatureMappingId = S.FdpSpecialFeatureMappingId;

	UPDATE S SET 
		Volume = M.Volume
		, PercentageTakeRate = M.PercentageTakeRate
	FROM @MarketMix AS M
	JOIN Fdp_TakeRateSummary AS S ON M.FdpVolumeHeaderId = S.FdpVolumeHeaderId
											AND M.MarketId = S.MarketId
											AND S.ModelId IS NULL
											AND S.FdpModelId IS NULL
											AND M.FdpSpecialFeatureMappingId = S.FdpSpecialFeatureMappingId;

	-- Add new summary entries at market level

	--SELECT M.* 
	--FROM @MarketMix AS M
	--LEFT JOIN Fdp_TakeRateSummary AS S ON M.FdpVolumeHeaderId = S.FdpVolumeHeaderId
	--										AND M.MarketId = S.MarketId
	--										AND S.ModelId IS NULL
	--										AND S.FdpModelId IS NULL
	--										AND M.FdpSpecialFeatureMappingId = S.FdpSpecialFeatureMappingId
	--WHERE
	--S.FdpTakeRateSummaryId IS NULL;

	INSERT INTO Fdp_TakeRateSummary
	(
		  CreatedBy
		, FdpVolumeHeaderId
		, FdpSpecialFeatureMappingId
		, MarketId
		, Volume
		, PercentageTakeRate
	)
	SELECT
		  M.CreatedBy  
		, M.FdpVolumeHeaderId
		, M.FdpSpecialFeatureMappingId
		, M.MarketId
		, M.Volume
		, M.PercentageTakeRate 

	FROM @MarketMix AS M
	LEFT JOIN Fdp_TakeRateSummary AS S ON M.FdpVolumeHeaderId = S.FdpVolumeHeaderId
											AND M.MarketId = S.MarketId
											AND S.ModelId IS NULL
											AND S.FdpModelId IS NULL
											AND M.FdpSpecialFeatureMappingId = S.FdpSpecialFeatureMappingId
	WHERE
	S.FdpTakeRateSummaryId IS NULL;

	-- Update the percentage take rates for each market
	-- We need to do this afterwards as the import may only contain partial data
	-- any % take needs to be computed on the whole dataset

	SELECT @TotalVolume = SUM(VOL.Volume)
	FROM
	Fdp_VolumeHeader AS H
	CROSS APPLY dbo.fn_Fdp_VolumeByMarket_GetMany(H.FdpVolumeHeaderId, NULL) AS VOL
	WHERE
	H.FdpVolumeHeaderId = @FdpVolumeHeaderId;

	--SELECT @TotalVolume AS TotalVolume;

	UPDATE S SET PercentageTakeRate = Volume / CAST(@TotalVolume AS DECIMAL)
	FROM
	Fdp_TakeRateSummary AS S
	WHERE
	S.FdpVolumeHeaderId = @FdpVolumeHeaderId
	AND
	S.ModelId IS NULL
	AND
	S.FdpModelId IS NULL;

	-- Update the total volume based on the sum of the total volumes for each market
	
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