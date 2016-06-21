CREATE PROCEDURE [dbo].[Fdp_TakeRateData_CalculateAllMarkets]
	  @FdpVolumeHeaderId	INT
	, @CDSId				NVARCHAR(16)
AS
BEGIN
	SET NOCOUNT ON;

	-- Remove any pivot data for all markets as it is now invalid

	DELETE FROM Fdp_PivotData WHERE FdpPivotHeaderId IN 
	(
		SELECT FdpPivotHeaderId 
		FROM Fdp_PivotHeader 
		WHERE 
		FdpVolumeHeaderId = @FdpVolumeHeaderId
		AND
		MarketId IS NULL
	)
	DELETE FROM Fdp_PivotHeader WHERE FdpPivotHeaderId IN
	(
		SELECT FdpPivotHeaderId 
		FROM Fdp_PivotHeader 
		WHERE 
		FdpVolumeHeaderId = @FdpVolumeHeaderId
		AND
		MarketId IS NULL
	)

    -- 1. Total market volume across all markets
	-- Sum up all the market summary records from any published take rate markets
	-- to establish the new raw volume

	DECLARE @TotalVolume AS INT;

	SELECT @TotalVolume = SUM(V.Volume)
	FROM
	dbo.fn_Fdp_VolumeByMarket_GetMany(@FdpVolumeHeaderId, NULL) AS V
	JOIN Fdp_Publish AS P ON V.MarketId = P.MarketId
	WHERE
	P.FdpVolumeHeaderId = @FdpVolumeHeaderId
	AND
	P.IsPublished = 1;

	IF @TotalVolume IS NULL
	BEGIN
		SET @TotalVolume = 0;
	END

	UPDATE Fdp_VolumeHeader SET TotalVolume = @TotalVolume, UpdatedBy = @CDSId, UpdatedOn = GETDATE()
	WHERE
	FdpVolumeHeaderId = @FdpVolumeHeaderId;

	-- 2. Derivative mix from
	-- Sum up all volumes for each derivative (across all markets) to get the raw volume
	-- Divide the raw volume by the total market volume from 1. above
	-- Update the derivative mix entries for all markets, adding if they don't exist

	DECLARE @DerivativeMix AS TABLE
	(
		  FdpVolumeHeaderId		INT
		, DerivativeCode		NVARCHAR(40)
		, FdpOxoDerivativeId	INT
		, Volume				INT
		, PercentageTakeRate	DECIMAL(5,4)
	)
	INSERT INTO @DerivativeMix
	(
		  FdpVolumeHeaderId
		, DerivativeCode
		, FdpOxoDerivativeId
		, Volume
		, PercentageTakeRate
	)
	SELECT
		  D.FdpVolumeHeaderId 
		, D.DerivativeCode
		, D.FdoOxoDerivativeId
		, SUM(D.Volume) AS Volume
		, SUM(D.Volume) / CAST(@TotalVolume AS DECIMAL(10, 4)) AS PercentageTakeRate
	FROM 
	Fdp_PowertrainDataItem	AS D
	JOIN Fdp_Publish		AS P	ON	D.FdpVolumeHeaderId = P.FdpVolumeHeaderId
									AND D.MarketId			= P.MarketId
									AND P.IsPublished		= 1
	WHERE
	D.FdpVolumeHeaderId = @FdpVolumeHeaderId
	AND
	D.MarketId IS NOT NULL
	GROUP BY
	D.FdpVolumeHeaderId, D.DerivativeCode, D.FdoOxoDerivativeId;

	-- If nothing is published, insert empty mix entries
	IF @@ROWCOUNT = 0
	BEGIN
		INSERT INTO @DerivativeMix
		(
			  FdpVolumeHeaderId
			, DerivativeCode
			, FdpOxoDerivativeId
			, Volume
			, PercentageTakeRate
		)
		SELECT
		  D.FdpVolumeHeaderId 
		, D.DerivativeCode
		, D.FdoOxoDerivativeId
		, 0 AS Volume
		, 0 AS PercentageTakeRate
		FROM 
		Fdp_PowertrainDataItem	AS D
		WHERE
		D.FdpVolumeHeaderId = @FdpVolumeHeaderId
		AND
		D.MarketId IS NOT NULL
		GROUP BY
		D.FdpVolumeHeaderId, D.DerivativeCode, D.FdoOxoDerivativeId;
	END

	UPDATE P SET 
		  Volume = D.Volume
		, PercentageTakeRate = D.PercentageTakeRate
		, UpdatedBy = @CDSId
		, UpdatedOn = GETDATE()
	FROM
	@DerivativeMix				AS D
	JOIN Fdp_PowertrainDataItem AS P	ON	D.FdpVolumeHeaderId = P.FdpVolumeHeaderId
										AND D.DerivativeCode	= P.DerivativeCode
										AND P.MarketId			IS NULL
	WHERE
	D.Volume <> P.Volume 
	OR 
	D.PercentageTakeRate <> P.PercentageTakeRate
	
	INSERT INTO Fdp_PowertrainDataItem
	(
		  CreatedBy
		, FdpVolumeHeaderId
		, DerivativeCode
		, FdoOxoDerivativeId
		, Volume
		, PercentageTakeRate
	)
	SELECT
		  @CDSId
		, D.FdpVolumeHeaderId
		, D.DerivativeCode
		, D.FdpOxoDerivativeId
		, D.Volume
		, D.PercentageTakeRate
	FROM
	@DerivativeMix						AS D
	LEFT JOIN Fdp_PowertrainDataItem	AS P	ON	D.FdpVolumeHeaderId = P.FdpVolumeHeaderId
												AND D.DerivativeCode	= P.DerivativeCode
												AND P.MarketId			IS NULL
	WHERE
	P.FdpPowertrainDataItemId IS NULL;

	-- 3. Model mix
	-- Sum up the volumes for each model (across all markets) to get the raw volume
	-- Divide the raw volume by the total market volume from 1. above
	-- Update the model mix entries for all markets, adding if they don't exist

	DECLARE @ModelMix AS TABLE
	(
		  FdpVolumeHeaderId		INT
		, ModelId				INT
		, Volume				INT
		, PercentageTakeRate	DECIMAL(5,4)
	)
	INSERT INTO @ModelMix
	(
		  FdpVolumeHeaderId
		, ModelId
		, Volume
		, PercentageTakeRate
	)
	SELECT
		  S.FdpVolumeHeaderId
		, S.ModelId
		, SUM(S.Volume) AS Volume
		, SUM(S.Volume) / CAST(@TotalVolume AS DECIMAL(10, 4)) AS PercentageTakeRate
	FROM
	Fdp_TakeRateSummary		AS S
	JOIN Fdp_Publish		AS P	ON	S.FdpVolumeHeaderId = P.FdpVolumeHeaderId
									AND S.MarketId			= P.MarketId
									AND P.IsPublished		= 1
	WHERE
	S.FdpVolumeHeaderId = @FdpVolumeHeaderId
	AND
	S.MarketId IS NOT NULL
	AND
	S.ModelId IS NOT NULL
	GROUP BY
	S.FdpVolumeHeaderId, S.ModelId;

	IF @@ROWCOUNT = 0
	BEGIN
		INSERT INTO @ModelMix
		(
			  FdpVolumeHeaderId
			, ModelId
			, Volume
			, PercentageTakeRate
		)
		SELECT
			  S.FdpVolumeHeaderId
			, S.ModelId
			, 0 AS Volume
			, 0 AS PercentageTakeRate
		FROM
		Fdp_TakeRateSummary		AS S
		WHERE
		S.FdpVolumeHeaderId = @FdpVolumeHeaderId
		AND
		S.MarketId IS NOT NULL
		AND
		S.ModelId IS NOT NULL
		GROUP BY
		S.FdpVolumeHeaderId, S.ModelId;
	END

	UPDATE S SET 
		  Volume = M.Volume
		, PercentageTakeRate = M.PercentageTakeRate
		, UpdatedBy = @CDSId
		, UpdatedOn = GETDATE()
	FROM
	@ModelMix					AS M
	JOIN Fdp_TakeRateSummary	AS S	ON	M.FdpVolumeHeaderId = S.FdpVolumeHeaderId
										AND M.ModelId			= S.ModelId
										AND S.MarketId			IS NULL
	WHERE
	M.Volume <> S.Volume 
	OR 
	M.PercentageTakeRate <> S.PercentageTakeRate

	INSERT INTO Fdp_TakeRateSummary
	(
		  CreatedBy
		, FdpVolumeHeaderId
		, ModelId
		, Volume
		, PercentageTakeRate
	)
	SELECT
		  @CDSId
		, M.FdpVolumeHeaderId
		, M.ModelId
		, M.Volume
		, M.PercentageTakeRate
	FROM
	@ModelMix							AS M
	LEFT JOIN Fdp_TakeRateSummary		AS S	ON	M.FdpVolumeHeaderId = S.FdpVolumeHeaderId
												AND M.ModelId			= S.ModelId
												AND S.MarketId			IS NULL
	WHERE
	S.FdpTakeRateSummaryId IS NULL;

	-- 4. Feature
	-- Sum up the volumes for each feature (across all markets) to get the raw volume
	-- Divide the raw volume by the total volume for the model from 3. above
	-- Update the feature entries for all markets, adding if they don't exist

	DECLARE @Feature AS TABLE
	(
		  FdpVolumeHeaderId		INT
		, ModelId				INT
		, TrimId				INT
		, FeaturePackId			INT
		, FeatureId				INT
		, Volume				INT
		, PercentageTakeRate	DECIMAL(5,4)
	)
	INSERT INTO @Feature
	(
		  FdpVolumeHeaderId
		, ModelId
		, TrimId
		, FeaturePackId
		, FeatureId
		, Volume
		, PercentageTakeRate
	)
	SELECT
		  D.FdpVolumeHeaderId
		, D.ModelId
		, D.TrimId
		, D.FeaturePackId
		, D.FeatureId
		, SUM(ISNULL(PO.Volume, D.Volume)) AS Volume
		, dbo.fn_Fdp_PercentageTakeRate_Get(SUM(ISNULL(PO.Volume, D.Volume)), SUM(S.Volume)) AS PercentageTakeRate
	FROM
	Fdp_VolumeDataItem				AS D
	JOIN Fdp_TakeRateSummary		AS S	ON	D.FdpVolumeHeaderId = S.FdpVolumeHeaderId
											AND D.MarketId			= S.MarketId
											AND D.ModelId			= S.ModelId
	JOIN Fdp_Publish				AS P	ON	D.FdpVolumeHeaderId = P.FdpVolumeHeaderId
											AND D.MarketId			= P.MarketId
											AND P.IsPublished		= 1
	LEFT JOIN Fdp_CombinedPackOption AS PO	ON	D.FdpVolumeHeaderId = PO.FdpVolumeHeaderId
											AND D.MarketId			= PO.MarketId
											AND D.ModelId			= PO.ModelId
											AND D.FeatureId			= PO.FeatureId
	WHERE
	D.FdpVolumeHeaderId = @FdpVolumeHeaderId
	AND
	D.MarketId IS NOT NULL
	AND
	D.FeatureId IS NOT NULL
	GROUP BY
	D.FdpVolumeHeaderId, D.ModelId, D.TrimId, D.FeaturePackId, D.FeatureId

	UNION

	SELECT
		  D.FdpVolumeHeaderId
		, D.ModelId
		, D.TrimId
		, D.FeaturePackId
		, NULL
		, SUM(D.Volume) AS Volume
		, dbo.fn_Fdp_PercentageTakeRate_Get(SUM(D.Volume), SUM(S.Volume)) PercentageTakeRate
	FROM
	Fdp_VolumeDataItem	AS D
	JOIN Fdp_TakeRateSummary		AS S	ON	D.FdpVolumeHeaderId = S.FdpVolumeHeaderId
											AND D.MarketId			= S.MarketId
											AND D.ModelId			= S.ModelId
	JOIN Fdp_Publish	AS P	ON	D.FdpVolumeHeaderId = P.FdpVolumeHeaderId
								AND D.MarketId			= P.MarketId
								AND P.IsPublished		= 1
	WHERE
	D.FdpVolumeHeaderId = @FdpVolumeHeaderId
	AND
	D.MarketId IS NOT NULL
	AND
	D.FeatureId IS NULL
	AND
	D.FeaturePackId IS NOT NULL
	GROUP BY
	D.FdpVolumeHeaderId, D.ModelId, D.TrimId, D.FeaturePackId

	IF @@ROWCOUNT = 0
	BEGIN
		INSERT INTO @Feature
		(
			  FdpVolumeHeaderId
			, ModelId
			, TrimId
			, FeaturePackId
			, FeatureId
			, Volume
			, PercentageTakeRate
		)
		SELECT
			  D.FdpVolumeHeaderId
			, D.ModelId
			, D.TrimId
			, D.FeaturePackId
			, D.FeatureId
			, 0 AS Volume
			, 0 AS PercentageTakeRate
		FROM
		Fdp_VolumeDataItem				AS D
		WHERE
		D.FdpVolumeHeaderId = @FdpVolumeHeaderId
		AND
		D.MarketId IS NOT NULL
		AND
		D.FeatureId IS NOT NULL
		GROUP BY
		D.FdpVolumeHeaderId, D.ModelId, D.TrimId, D.FeaturePackId, D.FeatureId

		UNION

		SELECT
			  D.FdpVolumeHeaderId
			, D.ModelId
			, D.TrimId
			, D.FeaturePackId
			, NULL
			, 0 AS Volume
			, 0 AS PercentageTakeRate
		FROM
		Fdp_VolumeDataItem	AS D
		WHERE
		D.FdpVolumeHeaderId = @FdpVolumeHeaderId
		AND
		D.MarketId IS NOT NULL
		AND
		D.FeatureId IS NULL
		AND
		D.FeaturePackId IS NOT NULL
		GROUP BY
		D.FdpVolumeHeaderId, D.ModelId, D.TrimId, D.FeaturePackId
	END

	UPDATE D SET 
		  Volume = F.Volume
		, PercentageTakeRate = F.PercentageTakeRate
		, UpdatedBy = @CDSId
		, UpdatedOn = GETDATE()
	FROM
	@Feature					AS F
	JOIN Fdp_VolumeDataItem		AS D	ON	F.FdpVolumeHeaderId = D.FdpVolumeHeaderId
										AND F.ModelId			= D.ModelId
										AND F.FeatureId			= D.FeatureId
										AND D.MarketId			IS NULL
	WHERE
	F.Volume <> D.Volume
	OR
	F.PercentageTakeRate <> D.PercentageTakeRate

	UPDATE D SET 
		  Volume = F.Volume
		, PercentageTakeRate = F.PercentageTakeRate
		, UpdatedBy = @CDSId
		, UpdatedOn = GETDATE()
	FROM
	@Feature					AS F
	JOIN Fdp_VolumeDataItem		AS D	ON	F.FdpVolumeHeaderId = D.FdpVolumeHeaderId
										AND F.ModelId			= D.ModelId
										AND F.FeaturePackId		= D.FeaturePackId
										AND F.FeatureId			IS NULL
										AND D.FeatureId			IS NULL
										AND D.MarketId			IS NULL
	WHERE
	F.Volume <> D.Volume
	OR
	F.PercentageTakeRate <> D.PercentageTakeRate

	INSERT INTO Fdp_VolumeDataItem
	(
		  CreatedBy
		, FdpVolumeHeaderId
		, ModelId
		, TrimId
		, FeatureId
		, FeaturePackId
		, Volume
		, PercentageTakeRate
	)
	SELECT
		  @CDSId
		, F.FdpVolumeHeaderId
		, F.ModelId
		, F.TrimId
		, F.FeatureId
		, F.FeaturePackId
		, F.Volume
		, F.PercentageTakeRate
	FROM
	@Feature							AS F
	LEFT JOIN Fdp_VolumeDataItem		AS D	ON	F.FdpVolumeHeaderId = D.FdpVolumeHeaderId
												AND F.ModelId			= D.ModelId
												AND F.FeatureId			= D.FeatureId
												AND D.MarketId			IS NULL
	WHERE
	D.FdpVolumeDataItemId IS NULL
	AND
	F.FeatureId IS NOT NULL

	UNION

	SELECT
		  @CDSId
		, F.FdpVolumeHeaderId
		, F.ModelId
		, F.TrimId
		, F.FeatureId
		, F.FeaturePackId
		, F.Volume
		, F.PercentageTakeRate
	FROM
	@Feature							AS F
	LEFT JOIN Fdp_VolumeDataItem		AS D	ON	F.FdpVolumeHeaderId = D.FdpVolumeHeaderId
												AND F.ModelId			= D.ModelId
												AND D.FeatureId			IS NULL
												AND F.FeaturePackId		= D.FeaturePackId
												AND D.MarketId			IS NULL
	WHERE
	D.FdpVolumeDataItemId IS NULL
	AND
	F.FeatureId IS NULL
	AND
	F.FeaturePackId IS NOT NULL
	
	-- 5. Feature mix
	-- Sum up the volumes for each feature (across all markets)
	-- Divide the raw volume by the total volume for the market
	-- Update the feature mix entries for all markets, adding if they don't exist

	DECLARE @FeatureMix AS TABLE
	(
		  FdpVolumeHeaderId		INT
		, FeaturePackId			INT
		, FeatureId				INT
		, Volume				INT
		, PercentageTakeRate	DECIMAL(5,4)
	)
	INSERT INTO @FeatureMix
	(
		  FdpVolumeHeaderId
		, FeaturePackId
		, FeatureId
		, Volume
		, PercentageTakeRate
	)
	SELECT
		  D.FdpVolumeHeaderId
		, NULL AS FeaturePackId
		, D.FeatureId
		, SUM(D.Volume) AS Volume
		, SUM(D.Volume) / CAST(25000 AS DECIMAL(10, 4)) AS PercentageTakeRate
	FROM
	Fdp_Publish AS P
	CROSS APPLY dbo.fn_Fdp_AvailableModelByMarketWithPaging_GetMany(P.FdpVolumeHeaderId, P.MarketId, NULL, NULL) AS M
	JOIN Fdp_VolumeDataItem AS D ON P.FdpVolumeHeaderId = D.FdpVolumeHeaderId
									AND P.MarketId = D.MarketId
									AND M.Id = D.ModelId
									AND D.FeatureId IS NOT NULL
	
	LEFT JOIN Fdp_CombinedPackOption AS PO ON D.FdpVolumeHeaderId = PO.FdpVolumeHeaderId
											AND D.MarketId = PO.MarketId
											AND D.ModelId = PO.ModelId
											AND D.FeatureId = PO.FeatureId
	WHERE
	P.FdpVolumeHeaderId = @FdpVolumeHeaderId
	AND
	PO.FdpCombinedPackOptionId IS NULL
	GROUP BY
	D.FdpVolumeHeaderId, D.FeatureId

	UNION

	-- If we have a combined pack option take available for a specific market / model / feature, use it

	SELECT
		  D.FdpVolumeHeaderId
		, NULL AS FeaturePackId
		, D.FeatureId
		, SUM(PO.Volume) AS Volume
		, ROUND(SUM(PO.Volume) / CAST(@TotalVolume AS DECIMAL(10, 4)), 2) AS PercentageTakeRate
	FROM
	Fdp_Publish AS P
	CROSS APPLY dbo.fn_Fdp_AvailableModelByMarketWithPaging_GetMany(P.FdpVolumeHeaderId, P.MarketId, NULL, NULL) AS M
	JOIN Fdp_VolumeDataItem		AS D	ON	P.FdpVolumeHeaderId	= D.FdpVolumeHeaderId
										AND P.MarketId			= D.MarketId
										AND M.Id				= D.ModelId
										AND D.FeatureId			IS NOT NULL
	
	JOIN Fdp_CombinedPackOption AS PO	ON	D.FdpVolumeHeaderId = PO.FdpVolumeHeaderId
										AND D.MarketId			= PO.MarketId
										AND D.ModelId			= PO.ModelId
										AND D.FeatureId			= PO.FeatureId
	WHERE
	P.FdpVolumeHeaderId = @FdpVolumeHeaderId
	GROUP BY
	D.FdpVolumeHeaderId, D.FeatureId

	UNION

	SELECT
		  D.FdpVolumeHeaderId
		, D.FeaturePackId
		, NULL
		, SUM(D.Volume) AS Volume
		, SUM(D.Volume) / CAST(@TotalVolume AS DECIMAL(10, 4)) AS PercentageTakeRate
	FROM Fdp_Publish AS P
	CROSS APPLY dbo.fn_Fdp_AvailableModelByMarketWithPaging_GetMany(P.FdpVolumeHeaderId, P.MarketId, NULL, NULL) AS M
	JOIN Fdp_VolumeDataItem AS D ON P.FdpVolumeHeaderId = D.FdpVolumeHeaderId
									AND P.MarketId = D.MarketId
									AND M.Id = D.ModelId
									AND D.FeatureId IS NULL
									AND D.FeaturePackId IS NOT NULL
	WHERE
	P.FdpVolumeHeaderId = @FdpVolumeHeaderId
	GROUP BY
	D.FdpVolumeHeaderId, D.FeaturePackId

	IF @@ROWCOUNT = 0
	BEGIN
		INSERT INTO @FeatureMix
		(
			  FdpVolumeHeaderId
			, FeaturePackId
			, FeatureId
			, Volume
			, PercentageTakeRate
		)
		SELECT
			  D.FdpVolumeHeaderId
			, D.FeaturePackId
			, D.FeatureId
			, 0 AS Volume
			, 0 AS PercentageTakeRate
		FROM
		Fdp_VolumeDataItem AS D
		JOIN Fdp_Publish					AS P	ON	D.FdpVolumeHeaderId = P.FdpVolumeHeaderId
													AND D.MarketId			= P.MarketId
													AND P.IsPublished		= 1
		WHERE
		D.FdpVolumeHeaderId = @FdpVolumeHeaderId
		AND
		D.MarketId IS NOT NULL
		AND
		D.FeatureId IS NOT NULL
		GROUP BY
		D.FdpVolumeHeaderId, D.FeaturePackId, D.FeatureId

		UNION

		SELECT
			  D.FdpVolumeHeaderId
			, D.FeaturePackId
			, NULL
			, 0 AS Volume
			, 0 AS PercentageTakeRate
		FROM
		Fdp_VolumeDataItem AS D
		WHERE
		D.FdpVolumeHeaderId = @FdpVolumeHeaderId
		AND
		D.MarketId IS NOT NULL
		AND
		D.FeatureId IS NULL
		AND
		D.FeaturePackId IS NOT NULL
		GROUP BY
		D.FdpVolumeHeaderId, D.FeaturePackId
	END

	UPDATE F SET 
		  Volume = M.Volume
		, PercentageTakeRate = M.PercentageTakeRate
		, UpdatedBy = @CDSId
		, UpdatedOn = GETDATE()
	FROM
	@FeatureMix					AS M
	JOIN Fdp_TakeRateFeatureMix	AS F	ON	M.FdpVolumeHeaderId = F.FdpVolumeHeaderId
										AND M.FeatureId			= F.FeatureId
										AND F.MarketId			IS NULL
	WHERE
	F.Volume <> M.Volume
	OR
	F.PercentageTakeRate <> M.PercentageTakeRate

	UPDATE F SET 
		  Volume = M.Volume
		, PercentageTakeRate = M.PercentageTakeRate
		, UpdatedBy = @CDSId
		, UpdatedOn = GETDATE()
	FROM
	@FeatureMix					AS M
	JOIN Fdp_TakeRateFeatureMix	AS F	ON	M.FdpVolumeHeaderId = F.FdpVolumeHeaderId
										AND M.FeaturePackId		= F.FeaturePackId
										AND M.FeatureId			IS NULL
										AND F.FeatureId			IS NULL
										AND F.MarketId			IS NULL
	WHERE
	F.Volume <> M.Volume
	OR
	F.PercentageTakeRate <> M.PercentageTakeRate;

	INSERT INTO Fdp_TakeRateFeatureMix
	(
		  CreatedBy
		, FdpVolumeHeaderId
		, FeatureId
		, FeaturePackId
		, Volume
		, PercentageTakeRate
	)
	SELECT
		  @CDSId AS CreatedBy
		, M.FdpVolumeHeaderId
		, M.FeatureId
		, M.FeaturePackId
		, M.Volume
		, M.PercentageTakeRate
	FROM
	@FeatureMix							AS M
	LEFT JOIN Fdp_TakeRateFeatureMix	AS F	ON	M.FdpVolumeHeaderId = F.FdpVolumeHeaderId
												AND M.FeatureId			= F.FeatureId
												AND F.MarketId			IS NULL
	WHERE
	F.FdpTakeRateFeatureMixId IS NULL
	AND
	M.FeatureId IS NOT NULL
	AND
	M.FeaturePackId IS NULL

	UNION

	SELECT
		  @CDSId AS CreatedBy
		, M.FdpVolumeHeaderId
		, NULL AS FeatureId
		, M.FeaturePackId
		, M.Volume
		, M.PercentageTakeRate
	FROM
	@FeatureMix							AS M
	LEFT JOIN Fdp_TakeRateFeatureMix	AS F	ON	M.FdpVolumeHeaderId = F.FdpVolumeHeaderId
												AND M.FeaturePackId		= F.FeaturePackId
												AND F.MarketId			IS NULL
	WHERE
	F.FdpTakeRateFeatureMixId IS NULL
	AND
	M.FeatureId IS NULL
	AND
	M.FeaturePackId IS NOT NULL

	-- We may have changesets for other markets that have not been saved, but the % of market take will potentially have changed
	-- Note we need a volume here regardless, so use unpublished volumes so we can see how our work is changing other markets

	SELECT @TotalVolume = SUM(V.Volume)
	FROM
	dbo.fn_Fdp_VolumeByMarket_GetMany(@FdpVolumeHeaderId, NULL) AS V;

	UPDATE C SET TotalVolume = @TotalVolume
	FROM Fdp_ChangesetDataItem AS C
	JOIN Fdp_ChangesetDataItem_VW AS C1 ON C.FdpChangesetDataItemId = C1.FdpChangesetDataItemId
	WHERE
	C1.FdpVolumeHeaderId = @FdpVolumeHeaderId
	AND 
	C1.IsSaved = 0
	AND
	C1.IsDeleted = 0
	AND
	C1.IsMarketUpdate = 1
	AND
	C1.MarketId IS NULL

	UPDATE C SET PercentageTakeRate = C.TotalVolume / CAST(@TotalVolume AS DECIMAL(10, 4))
	FROM Fdp_ChangesetDataItem AS C
	JOIN Fdp_ChangesetDataItem_VW AS C1 ON C.FdpChangesetDataItemId = C1.FdpChangesetDataItemId
	WHERE
	C1.FdpVolumeHeaderId = @FdpVolumeHeaderId
	AND 
	C1.IsSaved = 0
	AND
	C1.IsDeleted = 0
	AND
	C1.IsMarketUpdate = 1
	AND
	C1.MarketId IS NOT NULL

END