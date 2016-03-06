CREATE PROCEDURE [dbo].[Fdp_TakeRateFeatureMix_CalculateFeatureMixForAllFeatures]
	  @FdpVolumeHeaderId	AS INT
	, @MarketId				AS INT = NULL
	, @CDSId				AS NVARCHAR(16)
AS
	SET NOCOUNT ON;

	DECLARE @DataForFeature AS TABLE
	(
		  Id							INT PRIMARY KEY IDENTITY(1,1)
		, FdpVolumeHeaderId				INT
		, MarketId						INT
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
		, MarketId						INT
		, FeatureId						INT NULL
		, FdpFeatureId					INT	NULL
		, FeaturePackId					INT NULL
		, TotalVolume					INT
		, PercentageTakeRate			DECIMAL(5, 4)
		, FdpTakeRateFeatureMixId		INT NULL
	)
	DECLARE @Market AS TABLE
	(
		MarketId INT
	)
	
	-- Filter by markets
	INSERT INTO @Market (MarketId)
	SELECT 
		DISTINCT MarketId 
	FROM
	Fdp_VolumeDataItem_VW AS D
	WHERE
	D.FdpVolumeHeaderId = @FdpVolumeHeaderId
	AND
	(@MarketId IS NULL OR D.MarketId = @MarketId);
	
	-- Add all volume data existing rows to our data table
	
	INSERT INTO @DataForFeature
	(
		  FdpVolumeHeaderId
		, MarketId
		, FeatureId
		, FdpFeatureId
		, FeaturePackId
		, TotalVolume
		, PercentageTakeRate
		, FdpVolumeDataItemId
	)
	SELECT
		  F.FdpVolumeHeaderId
		, M.MarketId
		, F.FeatureId
		, F.FdpFeatureId
		, NULL
		, ISNULL(D.Volume, 0)
		, ISNULL(D.PercentageTakeRate, 0)
		, D.FdpVolumeDataItemId
	FROM
	Fdp_AllFeatures_VW		AS F
	CROSS APPLY @Market		AS M
	LEFT JOIN Fdp_VolumeDataItem_VW	AS D ON M.MarketId = D.MarketId
										 AND F.FdpVolumeHeaderId = D.FdpVolumeHeaderId
										 AND D.IsFeatureData = 1
										 AND 
										 (
											F.FeatureId = D.FeatureId
											OR
											F.FdpFeatureId = D.FdpFeatureId
										)
	WHERE
	F.FdpVolumeHeaderId = @FdpVolumeHeaderId

	UNION

	SELECT
		  F.FdpVolumeHeaderId
		, M.MarketId
		, NULL
		, NULL
		, F.FeaturePackId
		, ISNULL(D.Volume, 0)
		, ISNULL(D.PercentageTakeRate, 0)
		, D.FdpVolumeDataItemId
	FROM
	Fdp_AllFeatures_VW		AS F
	CROSS APPLY @Market		AS M
	LEFT JOIN Fdp_VolumeDataItem_VW	AS D ON M.MarketId = D.MarketId
										 AND F.FdpVolumeHeaderId = D.FdpVolumeHeaderId
										 AND D.IsFeatureData = 1
										 AND F.FeaturePackId = D.FeaturePackId
										 AND D.FeatureId IS NULL
	WHERE
	F.FdpVolumeHeaderId = @FdpVolumeHeaderId
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
		, FdpTakeRateFeatureMixId
	)
	SELECT 
		  D.FdpVolumeHeaderId
		, D.MarketId
		, D.FeatureId
		, CAST(NULL AS INT) AS FdpFeatureId
		, CAST(NULL AS INT) AS FeaturePackId
		, SUM(D.TotalVolume) AS TotalVolume
		, dbo.fn_Fdp_PercentageTakeRate_Get(SUM(D.TotalVolume), 
		  dbo.fn_Fdp_VolumeByMarket_Get(D.FdpVolumeHeaderId, D.MarketId, NULL)) AS PercentageTakeRate
		, MAX(CUR.FdpTakeRateFeatureMixId) AS FdpTakeRateFeatureMixId
	FROM 
	@DataForFeature AS D
	JOIN @Market	AS M ON D.MarketId = M.MarketId
	LEFT JOIN Fdp_TakeRateFeatureMix AS CUR ON	D.FeatureId = CUR.FeatureId
											AND D.FdpVolumeHeaderId = CUR.FdpVolumeHeaderId
											AND D.MarketId = CUR.MarketId
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
		, D.FdpFeatureId
		, CAST(NULL AS INT) AS FeaturePackId
		, SUM(D.TotalVolume) AS TotalVolume
		, dbo.fn_Fdp_PercentageTakeRate_Get(SUM(D.TotalVolume), 
		  dbo.fn_Fdp_VolumeByMarket_Get(D.FdpVolumeHeaderId, D.MarketId, NULL)) AS PercentageTakeRate
		, MAX(CUR.FdpTakeRateFeatureMixId) AS FdpTakeRateFeatureMixId
	FROM 
	@DataForFeature AS D
	JOIN @Market	AS M ON D.MarketId = M.MarketId
	LEFT JOIN Fdp_TakeRateFeatureMix AS CUR ON	D.FdpFeatureId = CUR.FdpFeatureId
											AND D.FdpVolumeHeaderId = CUR.FdpVolumeHeaderId
											AND D.MarketId = CUR.MarketId
	WHERE
	D.FdpFeatureId IS NOT NULL
	GROUP BY
	  D.FdpVolumeHeaderId
	, D.MarketId
	, D.FdpFeatureId
	
	UNION
	
	SELECT 
		  D.FdpVolumeHeaderId
		, D.MarketId
		, CAST(NULL AS INT) AS FeatureId
		, CAST(NULL AS INT) AS FdpFeatureId
		, D.FeaturePackId
		, SUM(D.TotalVolume) AS TotalVolume
		, dbo.fn_Fdp_PercentageTakeRate_Get(SUM(D.TotalVolume), 
		  dbo.fn_Fdp_VolumeByMarket_Get(D.FdpVolumeHeaderId, D.MarketId, NULL)) AS PercentageTakeRate
		, MAX(CUR.FdpTakeRateFeatureMixId) AS FdpTakeRateFeatureMixId
	FROM 
	@DataForFeature AS D
	JOIN @Market	AS M ON D.MarketId = M.MarketId
	LEFT JOIN Fdp_TakeRateFeatureMix AS CUR ON	D.FeaturePackId = CUR.FeaturePackId
											AND D.FdpVolumeHeaderId = CUR.FdpVolumeHeaderId
											AND D.MarketId = CUR.MarketId
											AND CUR.FeatureId IS NULL
	WHERE
	D.FeaturePackId IS NOT NULL
	AND
	D.FeatureId IS NULL
	GROUP BY
	  D.FdpVolumeHeaderId
	, D.MarketId
	, D.FeaturePackId

	-- Update existing feature mix entries

	UPDATE F1 SET 
		  PercentageTakeRate	= F.PercentageTakeRate
		, Volume				= F.TotalVolume
		, UpdatedBy				= @CDSId
		, UpdatedOn				= GETDATE()
	FROM
	@FeatureMix					AS F
	JOIN Fdp_TakeRateFeatureMix AS F1	ON  F.FdpTakeRateFeatureMixId = F1.FdpTakeRateFeatureMixId
										AND 
										(
											F.PercentageTakeRate <> F1.PercentageTakeRate
											OR
											F.TotalVolume <> F1.Volume
										)
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
	WHERE
	F.FdpTakeRateFeatureMixId IS NULL