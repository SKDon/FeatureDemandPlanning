CREATE PROCEDURE Fdp_TakeRateData_CalculateSummary
	  @FdpVolumeHeaderId AS INT
	, @CDSId AS NVARCHAR(16)
AS
	SET NOCOUNT ON;

	DECLARE @FdpImportId AS INT;
	DECLARE @TotalVolume AS INT = 0;
	DECLARE @Message AS NVARCHAR(MAX);

	SELECT TOP 1 @FdpImportId = FdpImportId FROM Fdp_Import_VW WHERE FdpVolumeHeaderId = @FdpVolumeHeaderId;

	-- Need to remove all the old summary items, as they could potentially be invalid

	DELETE FROM Fdp_TakeRateSummaryAudit WHERE FdpTakeRateSummaryId IN (SELECT FdpTakeRateSummaryId FROM Fdp_TakeRateSummary WHERE FdpVolumeHeaderId = @FdpVolumeHeaderId);
	DELETE FROM Fdp_TakeRateSummary WHERE FdpVolumeHeaderId = @FdpVolumeHeaderId;
			
	;WITH Summary AS
	(
		SELECT
			  H.FdpVolumeHeaderId
			, MAX(ISNULL(I.CreatedBy, H.CreatedBy))			AS CreatedBy
			, MAX(I.FdpSpecialFeatureMappingId)				AS FdpSpecialFeatureMappingId
			, MK.Market_Id									AS MarketId
			, M.Id											AS ModelId 
			, CAST(NULL AS INT)								AS FdpModelId
			, SUM(ISNULL(CAST(I.ImportVolume AS INT), 0))	AS ImportVolume
			, 0 AS PercentageTakeRate
		FROM
		Fdp_VolumeHeader_VW		AS H
		JOIN OXO_Programme_MarketGroupMarket_VW			AS MK ON H.ProgrammeId = MK.Programme_Id
		CROSS APPLY dbo.fn_Fdp_AvailableModelByMarketWithPaging_GetMany(H.FdpVolumeHeaderId, MK.Market_Id, NULL, NULL) 
								AS M
		LEFT JOIN Fdp_Import_VW AS I	ON	H.FdpVolumeHeaderId		= I.FdpVolumeHeaderId
										AND I.FdpImportId			= @FdpImportId
										AND I.ModelId				= M.Id
										AND MK.Market_Id				= I.MarketId
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
		, MK.Market_Id
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
	RAISERROR(@Message, 0, 1) WITH NOWAIT;

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