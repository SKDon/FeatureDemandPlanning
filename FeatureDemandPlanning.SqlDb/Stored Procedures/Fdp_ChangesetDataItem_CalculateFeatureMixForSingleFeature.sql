CREATE PROCEDURE [dbo].[Fdp_ChangesetDataItem_CalculateFeatureMixForSingleFeature]
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
		, FeaturePackId					INT	NULL
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
	)
	
	-- Determine the total volume for the car line by market
	
	SELECT @TotalVolumeByMarket = dbo.fn_Fdp_VolumeByMarket_Get(FdpVolumeHeaderId, MarketId, CDSId)
	FROM
	Fdp_ChangesetDataItem_VW
	WHERE
	FdpChangesetDataItemId = @FdpChangesetDataItemId;
												
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
	
	UPDATE D2 SET IsDeleted = 1
	FROM
	Fdp_ChangesetDataItem			AS D
	JOIN Fdp_ChangesetDataItem_VW	AS D1	ON	D.FdpChangesetId			= D1.FdpChangesetId
											AND D.MarketId					= D1.MarketId
											AND D1.FdpChangesetDataItemId	<> D.FdpChangesetDataItemId
											AND D1.IsFeatureMixUpdate		= 1
											AND D.FeaturePackId				= D1.FeaturePackId
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
		, FeaturePackId
		, TotalVolume
		, PercentageTakeRate
		, FdpVolumeDataItemId
		, ParentFdpChangesetDataItemId
	)
	SELECT
		  C.FdpChangesetId
		, D.MarketId
		, D.ModelId
		, D.FdpModelId
		, D.FeatureId
		, D.FdpFeatureId
		, D.FeaturePackId
		, D.Volume
		, D.PercentageTakeRate
		, D.FdpVolumeDataItemId
		, C.FdpChangesetDataItemId
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
		, D.FeaturePackId
		, D.Volume
		, D.PercentageTakeRate
		, D.FdpVolumeDataItemId
		, C.FdpChangesetDataItemId
	FROM
	Fdp_ChangesetDataItem_VW	AS C
	JOIN Fdp_VolumeDataItem		AS D	ON	C.FdpVolumeHeaderId	= D.FdpVolumeHeaderId
										AND C.MarketId			= D.MarketId
										AND C.FdpFeatureId		= D.FdpFeatureId
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
		, D.FeaturePackId
		, D.Volume
		, D.PercentageTakeRate
		, D.FdpVolumeDataItemId
		, C.FdpChangesetDataItemId
	FROM
	Fdp_ChangesetDataItem_VW	AS C
	JOIN Fdp_VolumeDataItem		AS D	ON	C.FdpVolumeHeaderId	= D.FdpVolumeHeaderId
										AND C.MarketId			= D.MarketId
										AND C.FeaturePackId		= D.FeaturePackId
	WHERE
	C.FdpChangesetDataItemId = @FdpChangesetDataItemId;

	
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
											
	UPDATE D SET
		  D.TotalVolume = D1.TotalVolume
		, D.PercentageTakeRate = D1.PercentageTakeRate
	FROM @DataForFeature			AS D
	JOIN Fdp_ChangesetDataItem_VW	AS D1	ON	D.FdpChangesetId	= D1.FdpChangesetId
											AND D.MarketId			= D1.MarketId
											AND D.ModelId			= D1.ModelId
											AND D.FeaturePackId		= D1.FeaturePackId
	
	UPDATE D SET
		  D.TotalVolume = D1.TotalVolume
		, D.PercentageTakeRate = D1.PercentageTakeRate
	FROM @DataForFeature			AS D
	JOIN Fdp_ChangesetDataItem_VW	AS D1	ON	D.FdpChangesetId	= D1.FdpChangesetId
											AND D.MarketId			= D1.MarketId
											AND D.FdpModelId		= D1.FdpModelId
											AND D.FeaturePackId		= D1.FeaturePackId

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
	FROM 
	@DataForFeature						AS D
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
	FROM 
	@DataForFeature						AS D
	JOIN Fdp_Changeset					AS C	ON D.FdpChangesetId		= C.FdpChangesetId
	JOIN Fdp_VolumeHeader				AS H	ON C.FdpVolumeHeaderId	= H.FdpVolumeHeaderId
	LEFT JOIN Fdp_TakeRateFeatureMix	AS M	ON H.FdpVolumeHeaderId	= M.FdpVolumeHeaderId
												AND D.MarketId			= M.MarketId
												AND D.FeaturePackId		= M.FeaturePackId
	WHERE
	D.FdpFeatureId IS NOT NULL
	GROUP BY
	  D.FdpChangesetId
	, D.MarketId
	, D.FeaturePackId;

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