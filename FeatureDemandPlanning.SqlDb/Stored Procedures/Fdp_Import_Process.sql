CREATE PROCEDURE [dbo].[Fdp_Import_Process] 
	@FdpImportId INT
AS

	SET NOCOUNT ON;

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
	CUR.FdpVolumeHeaderId IS NULL

	GROUP BY
	  I.FdpImportId
	, I.ProgrammeId
	, I.Gateway;

	-- For every entry in the import, create an entry in FDP_VolumeDataItem
	
	PRINT 'Adding volume data'

	INSERT INTO Fdp_VolumeDataItem
	(
		  FdpVolumeHeaderId
		, IsManuallyEntered
		, MarketId
		, MarketGroupId
		, ModelId
		, TrimId
		, EngineId
		, FeatureId
		, FeaturePackId
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
		, I.FeatureId
		, I.FeaturePackId
		, SUM(CAST(I.ImportVolume AS INT)) AS Volume 
	FROM
	Fdp_Import_VW			AS I
	JOIN Fdp_VolumeHeader			AS H ON I.FdpImportId = H.FdpImportId
	LEFT JOIN Fdp_VolumeDataItem	AS CUR	ON	I.MarketId		= CUR.MarketId
											AND I.MarketGroupId = CUR.MarketGroupId
											AND I.ModelId		= CUR.ModelId
											AND I.TrimId		= CUR.TrimId
											AND I.EngineId		= CUR.EngineId
											AND I.FeatureId		= CUR.FeatureId
											AND I.FeaturePackId = CUR.FeaturePackId
											--AND SUM(CAST(I.ImportVolume AS INT)) = CUR.Volume
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
	
	-- Need to group here, as if there are results from the view where multiple import lines
	-- match the same trim / engine mapping for the programme / market in question
	-- we need to aggregate the take rate
	 
	GROUP BY
		  H.FdpVolumeHeaderId
		, I.MarketId
		, I.MarketGroupId
		, I.ModelId
		, I.TrimId
		, I.EngineId
		, I.FeatureId
		, I.FeaturePackId;

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
	
	-- Create exceptions of varying types based on the data that cannot be processed
	
	PRINT 'Adding exceptions report'
	
	INSERT INTO Fdp_ImportError
	(
		  ImportQueueId
		, LineNumber
		, ErrorOn
		, FdpImportErrorTypeId
		, ErrorMessage
	)
	SELECT 
		  E.ImportQueueId
		, E.ImportLineNumber
		, E.ErrorOn
		, E.FdpImportErrorTypeId
		, E.ErrorMessage
	FROM
	(
		SELECT 
			  I.ImportQueueId
			, I.ImportLineNumber
			, GETDATE() AS ErrorOn
			, 1 AS FdpImportErrorTypeId -- Missing Market
			, 'Missing market ''' + I.ImportCountry + '''' AS ErrorMessage
		FROM
		Fdp_Import_VW				AS I
		LEFT JOIN Fdp_ImportError	AS CUR	ON	I.ImportQueueId				= CUR.ImportQueueId
											AND	I.ImportLineNumber			= CUR.LineNumber
											AND CUR.FdpImportErrorTypeId	= 1
		WHERE
		I.FdpImportId = @FdpImportId
		AND
		I.IsMarketMissing = 1
		AND
		CUR.FdpImportErrorId IS NULL
		
		UNION
		
		SELECT 
			  I.ImportQueueId
			, I.ImportLineNumber
			, GETDATE() AS ErrorOn
			, 3 AS FdpImportErrorTypeId -- Missing Derivative
			, 'Missing derivative ''' + I.ImportDerivativeCode + ' - ' + I.ImportTrim + '''' AS ErrorMessage
		FROM 
		Fdp_Import_VW				AS I
		LEFT JOIN Fdp_ImportError	AS CUR	ON	I.ImportQueueId				= CUR.ImportQueueId
											AND	I.ImportLineNumber			= CUR.LineNumber
											AND CUR.FdpImportErrorTypeId	= 3
		WHERE
		I.FdpImportId = @FdpImportId
		AND
		I.IsDerivativeMissing = 1
		AND
		CUR.FdpImportErrorId IS NULL
		
		UNION
		
		SELECT 
			  I.ImportQueueId
			, I.ImportLineNumber
			, GETDATE() AS ErrorOn
			, 2 AS FdpImportErrorTypeId -- Missing Feature
			, 'Missing feature ''' + I.ImportFeatureCode + ' - ' + I.ImportFeature + '''' AS ErrorMessage
		FROM Fdp_Import_VW			AS I
		LEFT JOIN Fdp_ImportError	AS CUR	ON	I.ImportQueueId				= CUR.ImportQueueId
											AND	I.ImportLineNumber			= CUR.LineNumber
											AND CUR.FdpImportErrorTypeId	= 2
		WHERE
		I.FdpImportId = @FdpImportId
		AND
		I.IsFeatureMissing = 1 
		AND
		CUR.FdpImportErrorId IS NULL
		
		UNION
		
		SELECT 
			  I.ImportQueueId
			, I.ImportLineNumber
			, GETDATE() AS ErrorOn
			, 4 AS FdpImportErrorTypeId -- Missing Trim
			, 'Missing trim ''' + I.ImportTrim + '''' AS ErrorMessage
		FROM Fdp_Import_VW			AS I
		LEFT JOIN Fdp_ImportError	AS CUR	ON	I.ImportQueueId				= CUR.ImportQueueId
											AND	I.ImportLineNumber			= CUR.LineNumber
											AND CUR.FdpImportErrorTypeId	= 4
		WHERE
		I.FdpImportId = @FdpImportId
		AND
		I.IsTrimMissing = 1 
		AND
		CUR.FdpImportErrorId IS NULL
	)
	AS E
	ORDER BY
	ImportLineNumber, FdpImportErrorTypeId;
	