CREATE PROCEDURE [dbo].[Fdp_TakeRateFeatureMix_CalculateFeatureMixForAllFeatures]
	  @FdpVolumeHeaderId	AS INT
	, @MarketId				AS INT
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
		, TotalVolume					INT
		, PercentageTakeRate			DECIMAL(5, 4)
	)
	
	-- Add all volume data existing rows to our data table
	
	INSERT INTO @DataForFeature
	(
		  FdpVolumeHeaderId
		, MarketId
		, FeatureId
		, FdpFeatureId
		, TotalVolume
		, PercentageTakeRate
		, FdpVolumeDataItemId
	)
	SELECT
		  D.FdpVolumeHeaderId
		, D.MarketId
		, D.FeatureId
		, D.FdpFeatureId
		, D.Volume
		, D.PercentageTakeRate
		, D.FdpVolumeDataItemId
	FROM
	Fdp_VolumeDataItem_VW	AS D
	WHERE
	D.FdpVolumeHeaderId = @FdpVolumeHeaderId
	AND
	(@MarketId IS NULL OR D.MarketId = @MarketId)
	AND
	D.IsFeatureData = 1;

	INSERT INTO @FeatureMix
	(
		  FdpVolumeHeaderId
		, MarketId
		, FeatureId
		, FdpFeatureId
		, TotalVolume
		, PercentageTakeRate
	)
	SELECT 
		  D.FdpVolumeHeaderId
		, D.MarketId
		, D.FeatureId
		, CAST(NULL AS INT) AS FdpFeatureId
		, SUM(D.TotalVolume) AS TotalVolume
		, dbo.fn_Fdp_PercentageTakeRate_Get(SUM(D.TotalVolume), 
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
		, D.FdpFeatureId
		, SUM(D.TotalVolume) AS TotalVolume
		, dbo.fn_Fdp_PercentageTakeRate_Get(SUM(D.TotalVolume), 
		  dbo.fn_Fdp_VolumeByMarket_Get(D.FdpVolumeHeaderId, D.MarketId, NULL)) AS PercentageTakeRate
	FROM 
	@DataForFeature AS D
	WHERE
	D.FdpFeatureId IS NOT NULL
	GROUP BY
	  D.FdpVolumeHeaderId
	, D.MarketId
	, D.FdpFeatureId;

	-- Update existing feature mix entries

	UPDATE F1 SET 
		  PercentageTakeRate	= F.PercentageTakeRate
		, Volume				= F.TotalVolume
		, UpdatedBy				= @CDSId
		, UpdatedOn				= GETDATE()
	FROM
	@FeatureMix AS F
	JOIN Fdp_TakeRateFeatureMix AS F1	ON  F.FdpVolumeHeaderId = F1.FdpVolumeHeaderId
										AND F.MarketId		= F1.MarketId
										AND F.FeatureId		= F1.FeatureId
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
		, Volume
		, PercentageTakeRate
	)
	SELECT
		  @CDSId
		, F.FdpVolumeHeaderId
		, F.MarketId  
		, F.FeatureId
		, F.FdpFeatureId
		, F.TotalVolume
		, F.PercentageTakeRate
	FROM
	@FeatureMix AS F
	LEFT JOIN Fdp_TakeRateFeatureMix AS CUR ON F.FdpVolumeHeaderId = CUR.FdpVolumeHeaderId
											AND F.MarketId			= CUR.MarketId
											AND F.FeatureId			= CUR.FeatureId
	WHERE
	CUR.FdpTakeRateFeatureMixId IS NULL
	AND
	F.FeatureId IS NOT NULL

	UNION

	SELECT
		  @CDSId
		, F.FdpVolumeHeaderId
		, F.MarketId  
		, F.FeatureId
		, F.FdpFeatureId
		, F.TotalVolume
		, F.PercentageTakeRate
	FROM 
	@FeatureMix AS F
	LEFT JOIN Fdp_TakeRateFeatureMix AS CUR ON F.FdpVolumeHeaderId  = CUR.FdpVolumeHeaderId
											AND F.MarketId			= CUR.MarketId
											AND F.FdpFeatureId		= CUR.FdpFeatureId
	WHERE
	CUR.FdpTakeRateFeatureMixId IS NULL
	AND
	F.FdpFeatureId IS NOT NULL;