CREATE PROCEDURE [dbo].[Fdp_ChangesetDataItem_CalculateFeatureMixForAllFeatures]
	@FdpChangesetDataItemId AS INT
AS
	SET NOCOUNT ON;

	DECLARE @TotalVolumeByMarket AS INT;
	DECLARE @DataForFeature AS TABLE
	(
		  Id							INT PRIMARY KEY IDENTITY(1,1)
		, FdpChangesetId				INT
		, MarketId						INT
		, ModelId						INT NULL
		, FeatureId						INT NULL
		, FdpModelId					INT NULL
		, FdpFeatureId					INT NULL
		, FeaturePackId					INT NULL
		, TotalVolume					INT
		, PercentageTakeRate			DECIMAL(5, 4)
		, FdpVolumeDataItemId			INT
		, ParentFdpChangesetDataItemId	INT
	)
	DECLARE @FeatureMix AS TABLE
	(
		  FdpChangesetId				INT
		, MarketId						INT
		, FeatureId						INT NULL
		, FdpFeatureId					INT	NULL
		, FeaturePackId					INT NULL
		, TotalVolume					INT
		, PercentageTakeRate			DECIMAL(5, 4)
		, ParentFdpChangesetDataItemId	INT
		, FdpTakeRateFeatureMixId		INT
		, OriginalVolume				INT NULL
		, OriginalPercentageTakeRate	DECIMAL(5, 4) NULL
	)
	
	-- Determine the total volume for the car line by market
	
	SELECT 
		@TotalVolumeByMarket = dbo.fn_Fdp_VolumeByMarket_Get(D.FdpVolumeHeaderId, D.MarketId, D.CDSId)
	FROM
	Fdp_ChangesetDataItem_VW AS D
	WHERE
	D.FdpChangesetDataItemId = @FdpChangesetDataItemId;

	SELECT @TotalVolumeByMarket AS TotalVolumeByMarket;
												
	-- Mark previous market mix changset entries as deleted
	
	UPDATE D1 SET IsDeleted = 1
	FROM Fdp_Changeset AS C
	JOIN Fdp_ChangesetDataItem AS D ON C.FdpChangesetId = D.FdpChangesetId
	JOIN Fdp_ChangesetDataItem AS D1	ON D.FdpChangesetId = C.FdpChangesetId
										AND D.MarketId		= D1.MarketId
										AND D.FdpChangesetDataItemId <> D1.FdpChangesetDataItemId
										AND D1.ModelId		IS NULL
										AND D1.FdpModelId	IS NULL
										AND (D1.FeatureId IS NOT NULL OR D1.FdpFeatureId IS NOT NULL OR D1.FeaturePackId IS NOT NULL)
										AND D1.IsDeleted	= 0
	WHERE
	D.FdpChangesetDataItemId = @FdpChangesetDataItemId;
	
	-- Add all volume data existing rows to our data table
	
	INSERT INTO @DataForFeature
	(
		  FdpChangesetId
		, MarketId
		, ModelId
		, FdpModelId
		, FeatureId
		, FdpFeatureId
		, FeaturePackId
		, TotalVolume
		, PercentageTakeRate
		, FdpVolumeDataItemId
		, ParentFdpChangesetDataItemId
	)
	SELECT
		  D.FdpChangesetId
		, D1.MarketId
		, D1.ModelId
		, D1.FdpModelId
		, D1.FeatureId
		, D1.FdpFeatureId
		, D1.FeaturePackId
		, D1.Volume
		, D1.PercentageTakeRate
		, D1.FdpVolumeDataItemId
		, D.FdpChangesetDataItemId
	FROM
	Fdp_ChangesetDataItem_VW	AS D
	JOIN Fdp_VolumeDataItem_VW	AS D1	ON	D.FdpVolumeHeaderId	= D1.FdpVolumeHeaderId
										AND D.MarketId			= D1.MarketId
										AND D1.IsFeatureData	= 1
	WHERE
	D.FdpChangesetDataItemId = @FdpChangesetDataItemId;
	
	-- Replace all volume data rows with any changes from the changeset
	
	UPDATE D SET
		  D.TotalVolume = D1.TotalVolume
		, D.PercentageTakeRate = D1.PercentageTakeRate
	FROM @DataForFeature			AS D
	JOIN Fdp_ChangesetDataItem_VW	AS D1	ON	D.FdpChangesetId		= D1.FdpChangesetId
											AND D.FdpVolumeDataItemId	= D1.FdpVolumeDataItemId;

	INSERT INTO @FeatureMix
	(
		  FdpChangesetId
		, MarketId
		, FeatureId
		, FdpFeatureId
		, FeaturePackId
		, TotalVolume
		, PercentageTakeRate
		, ParentFdpChangesetDataItemId
		, FdpTakeRateFeatureMixId
		, OriginalVolume
		, OriginalPercentageTakeRate
	)
	SELECT 
		  D.FdpChangesetId
		, D.MarketId
		, D.FeatureId
		, CAST(NULL AS INT) AS FdpFeatureId
		, CAST(NULL AS INT) AS FeaturePackId
		, SUM(D.TotalVolume) AS TotalVolume
		, dbo.fn_Fdp_PercentageTakeRate_Get(SUM(D.TotalVolume), @TotalVolumeByMarket) AS PercentageTakeRate
		, MAX(D.ParentFdpChangesetDataItemId)
		, MAX(M.FdpTakeRateFeatureMixId)
		, MAX(M.Volume)
		, MAX(M.PercentageTakeRate)
	FROM 
	@DataForFeature						AS D
	JOIN Fdp_Changeset					AS C	ON D.FdpChangesetId		= C.FdpChangesetId
	JOIN Fdp_VolumeHeader				AS H	ON C.FdpVolumeHeaderId	= H.FdpVolumeHeaderId
	LEFT JOIN Fdp_TakeRateFeatureMix	AS M	ON H.FdpVolumeHeaderId	= M.FdpVolumeHeaderId
												AND D.MarketId			= M.MarketId
												AND D.FeatureId			= M.FeatureId
	WHERE
	D.FeatureId IS NOT NULL
	GROUP BY
	  D.FdpChangesetId
	, D.MarketId
	, D.FeatureId

	UNION

	SELECT 
		  D.FdpChangesetId
		, D.MarketId
		, CAST(NULL AS INT) AS FeatureId
		, D.FdpFeatureId
		, CAST(NULL AS INT) AS FeaturePackId
		, SUM(D.TotalVolume) AS TotalVolume
		, dbo.fn_Fdp_PercentageTakeRate_Get(SUM(D.TotalVolume), @TotalVolumeByMarket) AS PercentageTakeRate
		, MAX(D.ParentFdpChangesetDataItemId)
		, MAX(M.FdpTakeRateFeatureMixId)
		, MAX(M.Volume)
		, MAX(M.PercentageTakeRate)
	FROM 
	@DataForFeature AS D
	JOIN Fdp_Changeset					AS C	ON D.FdpChangesetId		= C.FdpChangesetId
	JOIN Fdp_VolumeHeader				AS H	ON C.FdpVolumeHeaderId	= H.FdpVolumeHeaderId
	LEFT JOIN Fdp_TakeRateFeatureMix	AS M	ON H.FdpVolumeHeaderId	= M.FdpVolumeHeaderId
												AND D.MarketId			= M.MarketId
												AND D.FdpFeatureId		= M.FdpFeatureId
	WHERE
	D.FdpFeatureId IS NOT NULL
	GROUP BY
	  D.FdpChangesetId
	, D.MarketId
	, D.FdpFeatureId
	
	UNION
	
	SELECT 
		  D.FdpChangesetId
		, D.MarketId
		, CAST(NULL AS INT) AS FeatureId
		, CAST(NULL AS INT) AS FdpFeatureId
		, D.FeaturePackId
		, SUM(D.TotalVolume) AS TotalVolume
		, dbo.fn_Fdp_PercentageTakeRate_Get(SUM(D.TotalVolume), @TotalVolumeByMarket) AS PercentageTakeRate
		, MAX(D.ParentFdpChangesetDataItemId)
		, MAX(M.FdpTakeRateFeatureMixId)
		, MAX(M.Volume)
		, MAX(M.PercentageTakeRate)
	FROM 
	@DataForFeature						AS D
	JOIN Fdp_Changeset					AS C	ON D.FdpChangesetId		= C.FdpChangesetId
	JOIN Fdp_VolumeHeader				AS H	ON C.FdpVolumeHeaderId	= H.FdpVolumeHeaderId
	LEFT JOIN Fdp_TakeRateFeatureMix	AS M	ON H.FdpVolumeHeaderId	= M.FdpVolumeHeaderId
												AND D.MarketId			= M.MarketId
												AND D.FeaturePackId		= M.FeaturePackId
	WHERE
	D.FeaturePackId IS NOT NULL
	GROUP BY
	  D.FdpChangesetId
	, D.MarketId
	, D.FeaturePackId

	INSERT INTO Fdp_ChangesetDataItem
	(
		  FdpChangesetId
		, MarketId
		, FeatureId
		, FdpFeatureId
		, FeaturePackId
		, TotalVolume
		, PercentageTakeRate
		, ParentFdpChangesetDataItemId
		, FdpTakeRateFeatureMixId
	)
	SELECT
		  FdpChangesetId
		, MarketId
		, FeatureId
		, FdpFeatureId
		, FeaturePackId
		, TotalVolume
		, PercentageTakeRate
		, ParentFdpChangesetDataItemId
		, FdpTakeRateFeatureMixId
	FROM
	@FeatureMix;