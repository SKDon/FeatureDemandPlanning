CREATE PROCEDURE [dbo].[Fdp_ChangesetDataItem_CalculateFeatureMixForSingleFeature]
	@FdpChangesetDataItemId AS INT
AS
	SET NOCOUNT ON;

	DECLARE @TotalVolumeByMarket AS INT;
	DECLARE @DataForFeature AS TABLE
	(
		  Id					INT PRIMARY KEY IDENTITY(1,1)
		, FdpChangesetId		INT
		, MarketId				INT
		, ModelId				INT NULL
		, FeatureId				INT NULL
		, FdpModelId			INT NULL
		, FdpFeatureId			INT NULL
		, TotalVolume			INT
		, PercentageTakeRate	DECIMAL(5, 4)
		, FdpVolumeDataItemId	INT 
	)
	DECLARE @FeatureMix AS TABLE
	(
		  FdpChangesetId		INT
		, MarketId				INT
		, FeatureId				INT NULL
		, FdpFeatureId			INT	NULL
		, TotalVolume			INT
		, PercentageTakeRate	DECIMAL(5, 4)
	)
	
	-- Determine the total volume for the car line by market
	
	SELECT @TotalVolumeByMarket = dbo.fn_Fdp_VolumeByMarket_Get(FdpVolumeHeaderId, MarketId, CDSId)
	FROM
	Fdp_ChangesetDataItem_VW
	WHERE
	FdpChangesetDataItemId = @FdpChangesetDataItemId;

	SELECT @TotalVolumeByMarket AS TotalVolumeByMarket
												
	-- Mark previous feature mix changeset entries as deleted
	
	UPDATE D2 SET IsDeleted = 1
	FROM
	Fdp_ChangesetDataItem			AS D
	JOIN Fdp_ChangesetDataItem_VW	AS D1	ON	D.FdpChangesetId			= D1.FdpChangesetId
											AND D.MarketId					= D1.MarketId
											AND D1.FdpChangesetDataItemId	<> D.FdpChangesetDataItemId
											AND D1.IsFeatureMixUpdate		= 1
											AND D.FeatureId					= D1.FeatureId
	JOIN Fdp_ChangesetDataItem		AS D2	ON	D1.FdpChangesetDataItemId	= D2.FdpChangesetDataItemId
	WHERE
	D.FdpChangesetDataItemId = @FdpChangesetDataItemId;

	UPDATE D2 SET IsDeleted = 1
	FROM
	Fdp_ChangesetDataItem			AS D
	JOIN Fdp_ChangesetDataItem_VW	AS D1	ON	D.FdpChangesetId			= D1.FdpChangesetId
											AND D.MarketId					= D1.MarketId
											AND D1.FdpChangesetDataItemId	<> D.FdpChangesetDataItemId
											AND D1.IsFeatureMixUpdate		= 1
											AND D.FdpFeatureId				= D1.FdpFeatureId
	JOIN Fdp_ChangesetDataItem		AS D2	ON	D1.FdpChangesetDataItemId	= D2.FdpChangesetDataItemId
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
	)
	SELECT
		  C.FdpChangesetId
		, D.MarketId
		, D.ModelId
		, D.FdpModelId
		, D.FeatureId
		, D.FdpFeatureId
		, D.Volume
		, D.PercentageTakeRate
		, D.FdpVolumeDataItemId
	FROM
	Fdp_ChangesetDataItem_VW	AS C
	JOIN Fdp_VolumeDataItem		AS D	ON	C.FdpVolumeHeaderId	= D.FdpVolumeHeaderId
										AND C.MarketId			= D.MarketId
										AND C.FeatureId			= D.FeatureId
	WHERE
	C.FdpChangesetDataItemId = @FdpChangesetDataItemId
	
	UNION
	
	SELECT
		  C.FdpChangesetId
		, D.MarketId
		, D.ModelId
		, D.FdpModelId
		, D.FeatureId
		, D.FdpFeatureId
		, D.Volume
		, D.PercentageTakeRate
		, D.FdpVolumeDataItemId
	FROM
	Fdp_ChangesetDataItem_VW	AS C
	JOIN Fdp_VolumeDataItem		AS D	ON	C.FdpVolumeHeaderId	= D.FdpVolumeHeaderId
										AND C.MarketId			= D.MarketId
										AND C.FdpFeatureId		= D.FdpFeatureId
	WHERE
	C.FdpChangesetDataItemId = @FdpChangesetDataItemId

	SELECT * FROM @DataForFeature
	
	-- Replace all volume data rows with any changes from the changeset
	
	UPDATE D SET
		  D.TotalVolume = D1.TotalVolume
		, D.PercentageTakeRate = D1.PercentageTakeRate
	FROM @DataForFeature			AS D
	JOIN Fdp_ChangesetDataItem_VW	AS D1	ON	D.FdpChangesetId	= D1.FdpChangesetId
											AND D.MarketId			= D1.MarketId
											AND D.ModelId			= D1.ModelId
											AND D.FeatureId			= D1.FeatureId

	UPDATE D SET
		  D.TotalVolume = D1.TotalVolume
		, D.PercentageTakeRate = D1.PercentageTakeRate
	FROM @DataForFeature			AS D
	JOIN Fdp_ChangesetDataItem_VW	AS D1	ON	D.FdpChangesetId	= D1.FdpChangesetId
											AND D.MarketId			= D1.MarketId
											AND D.FdpModelId		= D1.FdpModelId
											AND D.FeatureId			= D1.FeatureId
										
	UPDATE D SET
		  D.TotalVolume = D1.TotalVolume
		, D.PercentageTakeRate = D1.PercentageTakeRate
	FROM @DataForFeature			AS D
	JOIN Fdp_ChangesetDataItem_VW	AS D1	ON	D.FdpChangesetId	= D1.FdpChangesetId
											AND D.MarketId			= D1.MarketId
											AND D.ModelId			= D1.ModelId
											AND D.FdpFeatureId		= D1.FdpFeatureId
										
	UPDATE D SET
		  D.TotalVolume = D1.TotalVolume
		, D.PercentageTakeRate = D1.PercentageTakeRate
	FROM @DataForFeature			AS D
	JOIN Fdp_ChangesetDataItem_VW	AS D1	ON	D.FdpChangesetId	= D1.FdpChangesetId
											AND D.MarketId			= D1.MarketId
											AND D.FdpModelId		= D1.FdpModelId
											AND D.FdpFeatureId		= D1.FdpFeatureId

	SELECT * FROM @DataForFeature

	INSERT INTO @FeatureMix
	(
		  FdpChangesetId
		, MarketId
		, FeatureId
		, FdpFeatureId
		, TotalVolume
		, PercentageTakeRate
	)
	SELECT 
		  FdpChangesetId
		, MarketId
		, FeatureId
		, CAST(NULL AS INT) AS FdpFeatureId
		, SUM(TotalVolume) AS TotalVolume
		, CASE 
			WHEN ISNULL(@TotalVolumeByMarket, 0) <> 0 THEN SUM(TotalVolume) / CAST(@TotalVolumeByMarket AS DECIMAL)
			ELSE 0
		  END AS PercentageTakeRate
	FROM 
	@DataForFeature
	WHERE
	FeatureId IS NOT NULL
	GROUP BY
	  FdpChangesetId
	, MarketId
	, FeatureId

	UNION

	SELECT 
		  FdpChangesetId
		, MarketId
		, CAST(NULL AS INT) AS FeatureId
		, FdpFeatureId
		, SUM(TotalVolume) AS TotalVolume
		, CASE 
			WHEN ISNULL(@TotalVolumeByMarket, 0) <> 0 THEN SUM(TotalVolume) / CAST(@TotalVolumeByMarket AS DECIMAL)
			ELSE 0
		  END AS PercentageTakeRate
	FROM 
	@DataForFeature
	WHERE
	FdpFeatureId IS NOT NULL
	GROUP BY
	  FdpChangesetId
	, MarketId
	, FdpFeatureId

	SELECT * FROM @FeatureMix;

	INSERT INTO Fdp_ChangesetDataItem
	(
		  FdpChangesetId
		, MarketId
		, FeatureId
		, FdpFeatureId
		, TotalVolume
		, PercentageTakeRate
	)
	SELECT
		  FdpChangesetId
		, MarketId
		, FeatureId
		, FdpFeatureId
		, TotalVolume
		, PercentageTakeRate
	FROM
	@FeatureMix;