CREATE PROCEDURE [dbo].[Fdp_ImportData_ProcessTakeRateData]
	@FdpImportId AS INT
AS
	SET NOCOUNT ON;
	
	DECLARE @FdpImportQueueId	INT;
	DECLARE @Message			NVARCHAR(400);
	DECLARE @OxoDocId			INT;
	DECLARE @FdpVolumeHeaderId	INT;
	DECLARE @CDSId				NVARCHAR(16);
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
		  @OxoDocId = DocumentId
		, @FdpImportQueueId = FdpImportQueueId
	FROM Fdp_Import
	WHERE
	FdpImportId = @FdpImportId;
	
	-- Remove redundant data if for example we are re-importing data for a previous import that errored
	
	EXEC Fdp_ImportData_RemoveRedundantData @FdpImportId = @FdpImportId, @FdpImportQueueId = @FdpImportQueueId;
	
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
		
		INSERT INTO Fdp_TakeRateVersion
		(
			  FdpTakeRateHeaderId
			, MajorVersion
			, MinorVersion
			, Revision
		)
		VALUES
		(
			  @FdpVolumeHeaderId
			, 1
			, 0
			, 0
		);
		
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
	
	-- Remove any validation
	
	DELETE FROM Fdp_Validation WHERE FdpVolumeHeaderId = @FdpVolumeHeaderId;
	
	-- Remove any changeset information (including saved changesets as the information they contain will be invalid if import data has changed)
	
	DELETE FROM Fdp_ChangesetDataItem WHERE FdpChangesetId IN (SELECT FdpChangesetId FROM Fdp_Changeset WHERE FdpVolumeHeaderId = @FdpVolumeHeaderId);
	DELETE FROM Fdp_Changeset WHERE FdpVolumeHeaderId = @FdpVolumeHeaderId;
	
	-- Add feature applicability information for the OXO document, we can flatten this information to improve performance, as it is only ever 
	-- considered to be read only
	
	SET @Message = 'Calculating feature applicability...';
	RAISERROR(@Message, 0, 1) WITH NOWAIT;
	
	EXEC Fdp_FeatureApplicability_Calculate @FdpVolumeHeaderId = @FdpVolumeHeaderId;

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

	-- Add any missing feature data if none has been provided by the import
	-- This ensures that the changeset functionality works properly and we have baseline data to work with
	
	SET @Message = 'Adding missing data items...';
	RAISERROR(@Message, 0, 1) WITH NOWAIT;

	EXEC Fdp_TakeRateData_AddMissingData @FdpVolumeHeaderId = @FdpVolumeHeaderId
	
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

	-- Need to remove all the old summary items, as they could potentially be invalid

	DELETE FROM Fdp_TakeRateSummaryAudit WHERE FdpTakeRateSummaryId IN (SELECT FdpTakeRateSummaryId FROM Fdp_TakeRateSummary WHERE FdpVolumeHeaderId = @FdpVolumeHeaderId);
	DELETE FROM Fdp_TakeRateSummary WHERE FdpVolumeHeaderId = @FdpVolumeHeaderId;
			
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
			, MAX(ISNULL(I.CreatedBy, H.CreatedBy))			AS CreatedBy
			, MAX(I.FdpSpecialFeatureMappingId)				AS FdpSpecialFeatureMappingId
			, MK.MarketId
			, M.Id											AS ModelId 
			, CAST(NULL AS INT)								AS FdpModelId
			, SUM(ISNULL(CAST(I.ImportVolume AS INT), 0))	AS ImportVolume
			, 0 AS PercentageTakeRate
		FROM
		Fdp_VolumeHeader_VW		AS H
		JOIN Markets			AS MK ON H.FdpVolumeHeaderId = MK.FdpVolumeHeaderId
		CROSS APPLY dbo.fn_Fdp_AvailableModelByMarketWithPaging_GetMany(H.FdpVolumeHeaderId, MK.MarketId, NULL, NULL) 
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
		GROUP BY
		  H.FdpVolumeHeaderId
		, MK.MarketId
		, M.Id
	)
	INSERT INTO Fdp_TakeRateSummary
	(
		  FdpVolumeHeaderId
		, CreatedBy
		, FdpSpecialFeatureMappingId
		, MarketId
		, ModelId
		, Volume
		, PercentageTakeRate
	)
	SELECT
		  S.FdpVolumeHeaderId
		, S.CreatedBy
		, S.FdpSpecialFeatureMappingId
		, S.MarketId
		, S.ModelId
		, S.ImportVolume
		, 0 AS PercentageTakeRate
	FROM
	Summary AS S
	
	SET @Message = CAST(@@ROWCOUNT AS NVARCHAR(10)) + ' summary items added';
	RAISERROR(@Message, 0, 1) WITH NOWAIT

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
		  MAX(S.CreatedBy)
		, S.FdpVolumeHeaderId
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

	-- % Take at market level	
	
	UPDATE S SET PercentageTakeRate = CASE WHEN @TotalVolume = 0 THEN 0 ELSE Volume / CAST(@TotalVolume AS DECIMAL(10, 4)) END
	FROM
	Fdp_TakeRateSummary AS S
	WHERE
	S.FdpVolumeHeaderId = @FdpVolumeHeaderId
	AND
	S.ModelId IS NULL;

	-- % Take at model level
	
	UPDATE M SET PercentageTakeRate = 
		CASE 
			WHEN ISNULL(MK.Volume, 0) <> 0 THEN M.Volume / CAST(MK.Volume AS DECIMAL(10,4))
			ELSE 0
		END
	FROM
	Fdp_TakeRateSummary			AS M
	JOIN Fdp_TakeRateSummary	AS MK	ON	M.MarketId			= MK.MarketId
										AND MK.ModelId			IS NULL
										AND M.FdpVolumeHeaderId = MK.FdpVolumeHeaderId
	WHERE
	M.FdpVolumeHeaderId = @FdpVolumeHeaderId
	AND
	M.ModelId IS NOT NULL
	
	-- % Take at feature level
	
	UPDATE F SET PercentageTakeRate = 
		CASE 
			WHEN ISNULL(M.Volume, 0) <> 0 THEN F.Volume / CAST(M.Volume AS DECIMAL(10,4))
			ELSE 0
		END
	FROM
	Fdp_VolumeDataItem			AS F
	JOIN Fdp_TakeRateSummary	AS M	ON	F.MarketId			= M.MarketId
										AND F.ModelId			= M.ModelId
										AND F.FdpVolumeHeaderId = M.FdpVolumeHeaderId
	WHERE
	F.FdpVolumeHeaderId = @FdpVolumeHeaderId;
	
	-- Non-applicable features should be 0% - Override any take rate information where this is not the case
	
	SET @Message = 'Resetting non-applicable features'
	RAISERROR(@Message, 0, 1) WITH NOWAIT
	
	EXEC Fdp_TakeRateData_ResetNonApplicableFeatures @FdpVolumeHeaderId = @FdpVolumeHeaderId, @CDSId = @CDSId
	
	-- Standard features should be 100% - Override any take rate information where this is not the case
	
	SET @Message = 'Setting standard features'
	RAISERROR(@Message, 0, 1) WITH NOWAIT
	
	EXEC Fdp_TakeRateData_SetStandardFeatures @FdpVolumeHeaderId = @FdpVolumeHeaderId, @CDSId = @CDSId
	
	-- Calculate and persist the feature mix for each feature / for each market

	SET @Message = 'Calculating feature mix...';
	RAISERROR(@Message, 0, 1) WITH NOWAIT

	EXEC Fdp_TakeRateFeatureMix_CalculateFeatureMixForAllFeatures @FdpVolumeHeaderId = @FdpVolumeHeaderId, @CDSID = @CDSId;

	SET @Message = 'Calculating derivative mix...';
	RAISERROR(@Message, 0, 1) WITH NOWAIT

	EXEC Fdp_PowertrainDataItem_CalculateMixForAllDerivatives @FdpVolumeHeaderId = @FdpVolumeHeaderId, @CDSID = @CDSId;
	
	EXEC Fdp_TakeRateHeader_Get @FdpVolumeHeaderId = @FdpVolumeHeaderId;
	
	-- Update the status of the import queue item

	EXEC Fdp_ImportQueue_UpdateStatus @ImportQueueId = @FdpImportQueueId, @ImportStatusId = 3