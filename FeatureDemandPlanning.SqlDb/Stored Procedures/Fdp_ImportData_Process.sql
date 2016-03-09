CREATE PROCEDURE [dbo].[Fdp_ImportData_Process] 
	  @FdpImportId	INT
	, @LineNumber	INT = NULL
AS
	SET NOCOUNT ON;
	
	-- TO DO, this routine needs refactoring into child stored procedures. It's quite linear and procedural, so
	-- is simply a matter of breaking the code up
	
	DECLARE @ProgrammeId		INT;
	DECLARE @Gateway			NVARCHAR(100);
	DECLARE @OxoDocId			INT;
	DECLARE @FdpVolumeHeaderId	INT;
	DECLARE @CDSId				NVARCHAR(16);
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
			  Q.CreatedOn
			, Q.CreatedBy
			, I.DocumentId
			, 1					AS FdpTakeRateStatusId
			, 0					AS IsManuallyCreated
		FROM 
		FDP_Import	AS I
		JOIN Fdp_ImportQueue AS Q ON I.FdpImportQueueId = Q.FdpImportQueueId
		WHERE 
		I.DocumentId = @OxoDocId
		
		SELECT @FdpVolumeHeaderId = SCOPE_IDENTITY();
		SELECT @CDSId = CreatedBy
		FROM Fdp_VolumeHeader
		WHERE
		FdpVolumeHeaderId = @FdpVolumeHeaderId;
		
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

		SELECT @CDSId = CreatedBy
		FROM
		Fdp_VolumeHeader
		WHERE
		FdpVolumeHeaderId = @FdpVolumeHeaderId;
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
		, IsMarketMissing
		, IsDerivativeMissing
		, IsTrimMissing
		, IsFeatureMissing
		, IsSpecialFeatureCode
	)
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

	-- We may have a situation where we have multiple data rows for the same model / trim / feature
	-- This is due to any mappings to the same feature from the import data. We need to aggregate these together and remove any duplicates

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
		, 0
		, MarketId
		, MarketGroupId
		, ModelId
		, FdpModelId
		, TrimId
		, FdpTrimId
		, FeatureId
		, FdpFeatureId
		, FeaturePackId
		, SUM(Volume) 
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
	IsSpecialFeatureCode = 0
	GROUP BY
	  FdpVolumeHeaderId
	, MarketId
	, MarketGroupId
	, ModelId
	, FdpModelId
	, TrimId
	, FdpTrimId
	, FeatureId
	, FdpFeatureId
	, FeaturePackId

	SET @Message = CAST(@@ROWCOUNT AS NVARCHAR(10)) + ' data items added';
	RAISERROR(@Message, 0, 1) WITH NOWAIT;

	-- Delete any duplicates that may have been added. Whilst we check for existing data, if that existing data is part of an aggregate, it will
	-- not have been picked up

	DELETE FROM Fdp_VolumeDataItem
	WHERE
	FdpVolumeDataItemId NOT IN
	(
		SELECT MAX(FdpVolumeDataItemId) AS FdpVolumeDataItemId
		FROM Fdp_VolumeDataItem
		WHERE
		FdpVolumeHeaderId = @FdpVolumeHeaderId
		GROUP BY
		  FdpVolumeHeaderId
		, MarketId
		, MarketGroupId
		, ModelId
		, FdpModelId
		, TrimId
		, FdpTrimId
		, FeatureId
		, FdpFeatureId
		, FeaturePackId
	)

	SET @Message = CAST(@@ROWCOUNT AS NVARCHAR(10)) + ' duplicate data items removed';
	RAISERROR(@Message, 0, 1) WITH NOWAIT;
	
	-- Increment the revision version if any new rows have been added
	-- This will either end up as 1 if there is no prior data, or up the minor version
	IF @@ROWCOUNT > 0
	BEGIN
		EXEC Fdp_TakeRateHeader_IncrementRevision @FdpVolumeHeaderId = @FdpVolumeHeaderId
	END
	
	DROP TABLE #NewData;

	-- Add the summary volume information for each market / derivative / trim level
	-- Only add information if it differs from the previous volume data
	-- Add zero-valued data is a model exists but we have no take rate information for it
	
	SET @Message = 'Adding summary information...';
	RAISERROR(@Message, 0, 1) WITH NOWAIT

	;WITH Markets AS 
	(
		SELECT FdpVolumeHeaderId, MarketId
		FROM
		Fdp_Import_VW AS I
		WHERE
		FdpVolumeHeaderId = @FdpVolumeHeaderId
		AND
		FdpImportId = @FdpImportId
		GROUP BY
		FdpVolumeHeaderId, MarketId
	)
	, Summary AS
	(
		SELECT
			  H.FdpVolumeHeaderId
			, MAX(ISNULL(I.CreatedBy, H.CreatedBy))								AS CreatedBy
			, MAX(I.FdpSpecialFeatureMappingId)				AS FdpSpecialFeatureMappingId
			, MK.MarketId
			, M.Id											AS ModelId 
			, CAST(NULL AS INT)								AS FdpModelId
			, SUM(ISNULL(CAST(I.ImportVolume AS INT), 0))	AS ImportVolume
			, 0 AS PercentageTakeRate
		FROM
		Fdp_VolumeHeader_VW		AS H
		JOIN Markets			AS MK ON H.FdpVolumeHeaderId = MK.FdpVolumeHeaderId
		CROSS APPLY dbo.fn_Fdp_AvailableModelByMarket_GetMany(H.FdpVolumeHeaderId, MK.MarketId) 
								AS M
		LEFT JOIN Fdp_Import_VW AS I	ON	H.FdpVolumeHeaderId		= I.FdpVolumeHeaderId
										AND I.FdpImportId			= @FdpImportId
										AND I.ModelId				= M.Id
										AND MK.MarketId				= I.MarketId
										AND I.IsSpecialFeatureCode	= 1
										AND I.IsMarketMissing		= 0
										AND I.IsDerivativeMissing	= 0
										AND I.IsTrimMissing			= 0
		WHERE
		H.FdpVolumeHeaderId = @FdpVolumeHeaderId
		AND
		M.Available = 1
		AND
		M.Id IS NOT NULL
		GROUP BY
		  H.FdpVolumeHeaderId
		, MK.MarketId
		, M.Id

		UNION

		SELECT
			  H.FdpVolumeHeaderId
			, MAX(ISNULL(I.CreatedBy, H.CreatedBy))			AS CreatedBy
			, MAX(I.FdpSpecialFeatureMappingId)				AS FdpSpecialFeatureMappingId
			, MK.MarketId
			, CAST(NULL AS INT)								AS ModelId 
			, M.FdpModelId
			, SUM(ISNULL(CAST(I.ImportVolume AS INT), 0))	AS ImportVolume
			, 0 AS PercentageTakeRate
		FROM
		Fdp_VolumeHeader_VW		AS H
		JOIN Markets			AS MK ON H.FdpVolumeHeaderId = MK.FdpVolumeHeaderId
		CROSS APPLY dbo.fn_Fdp_AvailableModelByMarket_GetMany(H.FdpVolumeHeaderId, MK.MarketId) 
								AS M
		LEFT JOIN Fdp_Import_VW AS I	ON	H.FdpVolumeHeaderId		= I.FdpVolumeHeaderId
										AND I.FdpImportId			= @FdpImportId
										AND M.FdpModelId			= I.FdpModelId
										AND MK.MarketId				= I.MarketId
										AND I.IsSpecialFeatureCode	= 1
										AND I.IsMarketMissing		= 0
										AND I.IsDerivativeMissing	= 0
										AND I.IsTrimMissing			= 0
		WHERE
		H.FdpVolumeHeaderId = @FdpVolumeHeaderId
		AND
		M.Available = 1
		AND
		M.FdpModelId IS NOT NULL
		GROUP BY
		  H.FdpVolumeHeaderId
		, MK.MarketId
		, M.FdpModelId
		
	)
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
		  S.FdpVolumeHeaderId
		, S.CreatedBy
		, S.FdpSpecialFeatureMappingId
		, S.MarketId
		, S.ModelId 
		, S.FdpModelId
		, S.ImportVolume
		, 0 AS PercentageTakeRate
	FROM
	Summary AS S
	LEFT JOIN 
	(
		SELECT 
			  S.FdpVolumeHeaderId
			, S.FdpSpecialFeatureMappingId
			, S.MarketId
			, S.ModelId
			, CAST(NULL AS INT) AS FdpModelId
			, SUM(S.Volume) AS Volume
		FROM
		Fdp_TakeRateSummary AS S
		GROUP BY
		  S.FdpVolumeHeaderId
		, S.FdpSpecialFeatureMappingId
		, S.MarketId
		, S.ModelId
		
		UNION
		
		SELECT 
			  S.FdpVolumeHeaderId
			, S.FdpSpecialFeatureMappingId
			, S.MarketId
			, CAST(NULL AS INT) AS ModelId
			, S.FdpModelId
			, SUM(S.Volume) AS Volume
		FROM
		Fdp_TakeRateSummary AS S
		GROUP BY
		  S.FdpVolumeHeaderId
		, S.FdpSpecialFeatureMappingId
		, S.MarketId
		, S.FdpModelId
	)
	AS CUR	ON	S.FdpVolumeHeaderId				= CUR.FdpVolumeHeaderId
			AND ISNULL(S.FdpSpecialFeatureMappingId, 0)	= ISNULL(CUR.FdpSpecialFeatureMappingId, 0)
			AND S.MarketId						= CUR.MarketId
			AND (S.ModelId		IS NULL	OR S.ModelId	= CUR.ModelId)
			AND (S.FdpModelId	IS NULL OR S.FdpModelId = CUR.FdpModelId)
			AND CAST(S.ImportVolume AS INT)		= CUR.Volume
	WHERE
	CUR.Volume IS NULL
	
	SET @Message = CAST(@@ROWCOUNT AS NVARCHAR(10)) + ' summary items added';
	RAISERROR(@Message, 0, 1) WITH NOWAIT

	-- Add summary rows for the volume and % take at market level, ignoring the model mix

	INSERT INTO @MarketMix
	(
		  FdpVolumeHeaderId
		, CreatedBy
		, MarketId
		, Volume
		, PercentageTakeRate
	)
	SELECT
		  S.FdpVolumeHeaderId
		, MAX(S.CreatedBy)
		, S.MarketId
		, SUM(S.Volume)
		, 0
	FROM
	Fdp_TakeRateSummary				AS S
	WHERE
	S.FdpVolumeHeaderId = @FdpVolumeHeaderId
	GROUP BY
	  S.FdpVolumeHeaderId
	, S.MarketId

	-- Update existing summary entries at market level

	UPDATE S SET 
		Volume = M.Volume
		, PercentageTakeRate = M.PercentageTakeRate
	FROM @MarketMix AS M
	JOIN Fdp_TakeRateSummary AS S ON M.FdpVolumeHeaderId = S.FdpVolumeHeaderId
											AND M.MarketId = S.MarketId
											AND S.ModelId IS NULL
											AND S.FdpModelId IS NULL

	-- Add new summary entries at market level

	INSERT INTO Fdp_TakeRateSummary
	(
		  CreatedBy
		, FdpVolumeHeaderId
		, MarketId
		, Volume
		, PercentageTakeRate
	)
	SELECT
		  M.CreatedBy  
		, M.FdpVolumeHeaderId
		, M.MarketId
		, M.Volume
		, M.PercentageTakeRate 

	FROM @MarketMix AS M
	LEFT JOIN Fdp_TakeRateSummary AS S ON M.FdpVolumeHeaderId	= S.FdpVolumeHeaderId
											AND M.MarketId		= S.MarketId
											AND S.ModelId		IS NULL
											AND S.FdpModelId	IS NULL
	WHERE
	S.FdpTakeRateSummaryId IS NULL;
	
	SET @Message = CAST(@@ROWCOUNT AS NVARCHAR(10)) + ' market level summary items added';
	RAISERROR(@Message, 0, 1) WITH NOWAIT

	-- Update the percentage take rates for each market
	-- We need to do this afterwards as the import may only contain partial data
	-- any % take needs to be computed on the whole dataset

	-- Total volume for all markets
	
	SELECT @TotalVolume = SUM(VOL.Volume)
	FROM
	Fdp_VolumeHeader AS H
	CROSS APPLY dbo.fn_Fdp_VolumeByMarket_GetMany(H.FdpVolumeHeaderId, NULL) AS VOL
	WHERE
	H.FdpVolumeHeaderId = @FdpVolumeHeaderId;
	
	UPDATE Fdp_VolumeHeader SET TotalVolume = @TotalVolume
	WHERE
	FdpVolumeHeaderId = @FdpVolumeHeaderId
	AND
	TotalVolume <> @TotalVolume;
	
	SET @Message = 'Total volume for all markets updated: ' + CAST(@TotalVolume AS NVARCHAR(10));
	RAISERROR(@Message, 0, 1) WITH NOWAIT

	-- % Take at market level	
	
	UPDATE S SET PercentageTakeRate = 
		CASE
			WHEN @TotalVolume = 0 THEN 0
			WHEN ISNULL(@TotalVolume, 0) <> 0 THEN Volume / CAST(@TotalVolume AS DECIMAL(10, 4))
			ELSE 0
		END
	FROM
	Fdp_TakeRateSummary AS S
	WHERE
	S.FdpVolumeHeaderId = @FdpVolumeHeaderId
	AND
	S.ModelId IS NULL
	AND
	S.FdpModelId IS NULL;
	
	SET @Message = 'Take rate for each market updated';
	RAISERROR(@Message, 0, 1) WITH NOWAIT

	-- % Take at model level
	
	UPDATE M SET PercentageTakeRate = 
		CASE
			WHEN MK.Volume = 0 THEN 0 
			WHEN ISNULL(MK.Volume, 0) <> 0 THEN M.Volume / CAST(MK.Volume AS DECIMAL(10,4))
			ELSE 0
		END
	FROM
	Fdp_TakeRateSummary			AS M
	JOIN Fdp_TakeRateSummary	AS MK	ON	M.MarketId			= MK.MarketId
										AND MK.ModelId			IS NULL
										AND MK.FdpModelId		IS NULL
										AND M.FdpVolumeHeaderId = MK.FdpVolumeHeaderId
	WHERE
	M.FdpVolumeHeaderId = @FdpVolumeHeaderId
	AND
	(
		M.ModelId IS NOT NULL
		OR
		M.FdpModelId IS NOT NULL
	)
	
	-- % Take at feature level
	
	UPDATE F SET PercentageTakeRate = 
		CASE 
			WHEN M.Volume = 0 THEN 0
			WHEN ISNULL(M.Volume, 0) <> 0 THEN F.Volume / CAST(M.Volume AS DECIMAL(10,4))
			ELSE 0
		END
	FROM
	Fdp_VolumeDataItem			AS F
	JOIN Fdp_TakeRateSummary	AS M	ON	F.MarketId			= M.MarketId
										AND F.ModelId			= M.ModelId
										AND M.FdpModelId		IS NULL
										AND F.FdpVolumeHeaderId = M.FdpVolumeHeaderId
	WHERE
	F.FdpVolumeHeaderId = @FdpVolumeHeaderId;
	
	SET @Message = 'Take rate for features updated';
	RAISERROR(@Message, 0, 1) WITH NOWAIT
	
	-- Calculate and persist the feature mix for each feature / for each market

	SET @Message = 'Calculating feature mix...';
	RAISERROR(@Message, 0, 1) WITH NOWAIT

	EXEC Fdp_TakeRateFeatureMix_CalculateFeatureMixForAllFeatures @FdpVolumeHeaderId = @FdpVolumeHeaderId, @CDSID = @CDSId;

	SET @Message = 'Calculating derivative mix...';
	RAISERROR(@Message, 0, 1) WITH NOWAIT

	EXEC Fdp_PowertrainDataItem_CalculateMixForAllDerivatives @FdpVolumeHeaderId = @FdpVolumeHeaderId, @CDSID = @CDSId;
	
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

	EXEC Fdp_TakeRateHeader_Get @FdpVolumeHeaderId = @FdpVolumeHeaderId;