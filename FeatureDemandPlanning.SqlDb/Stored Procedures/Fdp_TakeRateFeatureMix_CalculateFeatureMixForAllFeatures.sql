CREATE PROCEDURE [dbo].[Fdp_TakeRateFeatureMix_CalculateFeatureMixForAllFeatures]
	  @FdpVolumeHeaderId	AS INT
	, @CDSId				AS NVARCHAR(16)
AS
	SET NOCOUNT ON;

	DECLARE @DataForFeature AS TABLE
	(
		  Id							INT PRIMARY KEY IDENTITY(1,1)
		, FdpVolumeHeaderId				INT
		, MarketId						INT
		, ModelId						INT
		, FeatureId						INT NULL
		, FdpFeatureId					INT NULL
		, FeaturePackId					INT NULL
		, TotalVolume					INT
		, PercentageTakeRate			DECIMAL(5, 4)
		, FdpVolumeDataItemId			INT
	)
	DECLARE @FeatureMix AS TABLE
	(
		  FdpVolumeHeaderId				INT
		, MarketId						INT NULL
		, FeatureId						INT NULL
		, FdpFeatureId					INT	NULL
		, FeaturePackId					INT NULL
		, TotalVolume					INT
		, PercentageTakeRate			DECIMAL(5, 4)
	)

	-- Add all volume data existing rows to our data table
	
	INSERT INTO @DataForFeature
	(
		  FdpVolumeHeaderId
		, MarketId
		, ModelId
		, FeatureId
		, FdpFeatureId
		, FeaturePackId
		, TotalVolume
		, PercentageTakeRate
		, FdpVolumeDataItemId
	)
	SELECT
		  H.FdpVolumeHeaderId
		, M.MarketId
		, D.ModelId
		, F.FeatureId
		, F.FdpFeatureId
		, NULL
		, ISNULL(D.Volume, 0)
		, ISNULL(D.PercentageTakeRate, 0)
		, D.FdpVolumeDataItemId
	FROM
	Fdp_VolumeHeader_VW AS H
	JOIN OXO_Programme_MarketGroupMarket_VW AS MK ON H.ProgrammeId = MK.Programme_Id
	JOIN Fdp_Feature_VW		AS F	ON H.DocumentId = F.DocumentId
	CROSS APPLY dbo.fn_Fdp_AvailableModelByMarketWithPaging_GetMany(H.FdpVolumeHeaderId, MK.Market_Id, NULL, NULL) AS M
	LEFT JOIN Fdp_VolumeDataItem_VW	AS D ON H.FdpVolumeHeaderId = D.FdpVolumeHeaderId
										 AND MK.Market_Id = D.MarketId
										 AND M.Id = D.ModelId
										 AND F.FeatureId = D.FeatureId
	WHERE
	H.FdpVolumeHeaderId = @FdpVolumeHeaderId

	UNION

	SELECT
		  H.FdpVolumeHeaderId
		, M.MarketId
		, D.ModelId
		, NULL
		, NULL
		, F.FeaturePackId
		, ISNULL(D.Volume, 0)
		, ISNULL(D.PercentageTakeRate, 0)
		, D.FdpVolumeDataItemId
	FROM
	Fdp_VolumeHeader_VW AS H
	JOIN OXO_Programme_MarketGroupMarket_VW AS MK ON H.ProgrammeId = MK.Programme_Id
	JOIN Fdp_Feature_VW		AS F	ON H.DocumentId = F.DocumentId
	CROSS APPLY dbo.fn_Fdp_AvailableModelByMarketWithPaging_GetMany(H.FdpVolumeHeaderId, MK.Market_Id, NULL, NULL) AS M
	LEFT JOIN Fdp_VolumeDataItem_VW	AS D ON MK.Market_Id = D.MarketId
										 AND H.FdpVolumeHeaderId = D.FdpVolumeHeaderId
										 AND M.Id = D.ModelId
										 AND F.FeaturePackId = D.FeaturePackId
										 AND D.FeatureId IS NULL
	WHERE
	H.FdpVolumeHeaderId = @FdpVolumeHeaderId
	AND
	F.FeatureId IS NULL

	INSERT INTO @FeatureMix
	(
		  FdpVolumeHeaderId
		, MarketId
		, FeatureId
		, FdpFeatureId
		, FeaturePackId
		, TotalVolume
		, PercentageTakeRate
	)
	SELECT 
		  D.FdpVolumeHeaderId
		, D.MarketId
		, D.FeatureId
		, CAST(NULL AS INT) AS FdpFeatureId
		, CAST(NULL AS INT) AS FeaturePackId
		, SUM(ISNULL(D.TotalVolume, 0)) AS TotalVolume
		, dbo.fn_Fdp_PercentageTakeRate_Get(SUM(ISNULL(D.TotalVolume, 0)), 
		  dbo.fn_Fdp_VolumeByMarket_Get(D.FdpVolumeHeaderId, D.MarketId, NULL)) AS PercentageTakeRate
	FROM 
	@DataForFeature AS D
	WHERE
	D.FeatureId IS NOT NULL
	GROUP BY
	  D.FdpVolumeHeaderId
	, D.MarketId
	, D.FeatureId

	UNION
	
	SELECT 
		  D.FdpVolumeHeaderId
		, D.MarketId
		, CAST(NULL AS INT) AS FeatureId
		, CAST(NULL AS INT) AS FdpFeatureId
		, D.FeaturePackId
		, SUM(ISNULL(D.TotalVolume, 0)) AS TotalVolume
		, dbo.fn_Fdp_PercentageTakeRate_Get(SUM(ISNULL(D.TotalVolume, 0)), 
		  dbo.fn_Fdp_VolumeByMarket_Get(D.FdpVolumeHeaderId, D.MarketId, NULL)) AS PercentageTakeRate
	FROM 
	@DataForFeature AS D
	WHERE
	D.FeaturePackId IS NOT NULL
	AND
	D.FeatureId IS NULL
	GROUP BY
	  D.FdpVolumeHeaderId
	, D.MarketId
	, D.FeaturePackId

	-- Sanity checks, ensure we don't end up with silly feature mix entries

	UPDATE @FeatureMix SET PercentageTakeRate = 1
	WHERE
	PercentageTakeRate > 1;

	UPDATE @FeatureMix SET PercentageTakeRate = 0
	WHERE
	PercentageTakeRate < 0

	UPDATE F SET TotalVolume = M.Volume
	FROM @FeatureMix	AS F
	CROSS APPLY dbo.fn_Fdp_VolumeByMarket_GetMany(@FdpVolumeHeaderId, @CDSID) AS M
	WHERE
	F.MarketId = M.MarketId
	AND
	F.TotalVolume > M.Volume

	-- We need to add an "ALL MARKETS" feature mix entry to save computing aggregates each time

	DECLARE @TotalVolume AS INT = 0;
	SELECT @TotalVolume = SUM(Volume)
	FROM dbo.fn_Fdp_VolumeByMarket_GetMany(@FdpVolumeHeaderId, NULL)

	INSERT INTO @FeatureMix
	(
		  FdpVolumeHeaderId
		, FeatureId
		, FeaturePackId
		, TotalVolume
		, PercentageTakeRate
	)
	SELECT
		  M.FdpVolumeHeaderId
		, M.FeatureId
		, NULL
		, SUM(TotalVolume) AS TotalVolume
		, SUM(TotalVolume) / CAST(@TotalVolume AS DECIMAL(10, 4)) AS PercentageTakeRate
	FROM
	@FeatureMix AS M
	WHERE
	M.FeatureId IS NOT NULL
	GROUP BY
	FdpVolumeHeaderId, FeatureId

	UNION

	SELECT
		  FdpVolumeHeaderId
		, NULL
		, FeaturePackId
		, SUM(TotalVolume) AS TotalVolume
		, SUM(TotalVolume) / CAST(@TotalVolume AS DECIMAL(10, 4)) AS PercentageTakeRate
	FROM
	@FeatureMix
	WHERE
	FeatureId IS NULL
	AND
	FeaturePackId IS NOT NULL
	GROUP BY
	FdpVolumeHeaderId, FeaturePackId

	-- Delete all feature mix entries

	DELETE FROM Fdp_TakeRateFeatureMixAudit WHERE FdpTakeRateFeatureMixId IN (SELECT FdpTakeRateFeatureMixId FROM Fdp_TakeRateFeatureMix WHERE FdpVolumeHeaderId = @FdpVolumeHeaderId)
	DELETE FROM Fdp_TakeRateFeatureMix WHERE FdpVolumeHeaderId = @FdpVolumeHeaderId;

	-- Add new ones

	INSERT INTO Fdp_TakeRateFeatureMix
	(
		  CreatedBy
		, FdpVolumeHeaderId
		, MarketId
		, FeatureId
		, FdpFeatureId
		, FeaturePackId
		, Volume
		, PercentageTakeRate
	)
	SELECT
		  @CDSId
		, F.FdpVolumeHeaderId
		, F.MarketId  
		, F.FeatureId
		, F.FdpFeatureId
		, F.FeaturePackId
		, F.TotalVolume
		, F.PercentageTakeRate
	FROM
	@FeatureMix AS F

	PRINT CAST(@@ROWCOUNT AS NVARCHAR(10)) + ' feature mix entries added'