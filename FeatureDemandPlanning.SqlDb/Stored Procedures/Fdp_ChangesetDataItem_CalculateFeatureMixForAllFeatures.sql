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
		, TotalVolume					INT
		, PercentageTakeRate			DECIMAL(5, 4)
		, ParentFdpChangesetDataItemId	INT
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
										AND (D1.FeatureId IS NOT NULL OR D1.FdpFeatureId IS NOT NULL)
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

	SELECT * FROM @DataForFeature
	
	-- Replace all volume data rows with any changes from the changeset
	
	UPDATE D SET
		  D.TotalVolume = D1.TotalVolume
		, D.PercentageTakeRate = D1.PercentageTakeRate
	FROM @DataForFeature			AS D
	JOIN Fdp_ChangesetDataItem_VW	AS D1	ON	D.FdpChangesetId		= D1.FdpChangesetId
											AND D.FdpVolumeDataItemId	= D1.FdpVolumeDataItemId;
										
	SELECT * FROM @DataForFeature

	INSERT INTO @FeatureMix
	(
		  FdpChangesetId
		, MarketId
		, FeatureId
		, FdpFeatureId
		, TotalVolume
		, PercentageTakeRate
		, ParentFdpChangesetDataItemId
	)
	SELECT 
		  D.FdpChangesetId
		, D.MarketId
		, D.FeatureId
		, CAST(NULL AS INT) AS FdpFeatureId
		, SUM(D.TotalVolume) AS TotalVolume
		, dbo.fn_Fdp_PercentageTakeRate_Get(SUM(D.TotalVolume), @TotalVolumeByMarket) AS PercentageTakeRate
		, MAX(D.ParentFdpChangesetDataItemId)
	FROM 
	@DataForFeature AS D
	WHERE
	D.FeatureId IS NOT NULL
	GROUP BY
	  D.FdpChangesetId
	, D.MarketId
	, D.FeatureId

	UNION

	SELECT 
		  FdpChangesetId
		, MarketId
		, CAST(NULL AS INT) AS FeatureId
		, FdpFeatureId
		, SUM(TotalVolume) AS TotalVolume
		, dbo.fn_Fdp_PercentageTakeRate_Get(SUM(D.TotalVolume), @TotalVolumeByMarket) AS PercentageTakeRate
		, MAX(D.ParentFdpChangesetDataItemId)
	FROM 
	@DataForFeature AS D
	WHERE
	D.FdpFeatureId IS NOT NULL
	GROUP BY
	  D.FdpChangesetId
	, D.MarketId
	, D.FdpFeatureId;

	INSERT INTO Fdp_ChangesetDataItem
	(
		  FdpChangesetId
		, MarketId
		, FeatureId
		, FdpFeatureId
		, TotalVolume
		, PercentageTakeRate
		, ParentFdpChangesetDataItemId
	)
	SELECT
		  FdpChangesetId
		, MarketId
		, FeatureId
		, FdpFeatureId
		, TotalVolume
		, PercentageTakeRate
		, ParentFdpChangesetDataItemId
	FROM
	@FeatureMix;