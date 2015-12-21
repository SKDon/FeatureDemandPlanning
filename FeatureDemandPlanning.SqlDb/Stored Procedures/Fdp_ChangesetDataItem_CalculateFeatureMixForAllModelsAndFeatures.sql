CREATE PROCEDURE [dbo].[Fdp_ChangesetDataItem_CalculateFeatureMixForAllModelsAndFeatures]
	@FdpChangesetDataItemId AS INT
AS
	SET NOCOUNT ON;

	DECLARE @TotalVolumeByMarket AS INT;
	DECLARE @DataForModelAndFeature AS TABLE
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
	
	-- Determine the total volume for the car line by market (include any unsaved changes that may have been made to the figure)
	
	SELECT 
		@TotalVolumeByMarket = 
			CASE 
				WHEN D1.FdpChangesetDataItemId IS NOT NULL THEN D1.TotalVolume
				ELSE S.TotalVolume
			END
	FROM
	Fdp_Changeset						AS C
	JOIN Fdp_VolumeHeader				AS H	ON C.FdpVolumeHeaderId	= H.FdpVolumeHeaderId
	JOIN Fdp_ChangesetDataItem			AS D	ON C.FdpChangesetId		= C.FdpChangesetId
	JOIN Fdp_TakeRateSummaryByMarket_VW AS S	ON H.DocumentId			= S.DocumentId
												AND D.MarketId			= S.MarketId
	LEFT JOIN Fdp_ChangesetDataItem		AS D1	ON C.FdpChangesetId		= D1.FdpChangesetId
												AND D1.IsDeleted		= 0
												AND D.MarketId			= D1.MarketId
												AND D1.ModelId			IS NULL
												AND D1.FdpModelId		IS NULL
												AND D1.FeatureId		IS NULL
												AND D1.FdpFeatureId		IS NULL
	WHERE
	D.FdpChangesetDataItemId = @FdpChangesetDataItemId;
												
	-- Mark previous feature mix changeset entries as deleted
	
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
	
	INSERT INTO @DataForModelAndFeature
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
		, D1.MarketId
		, D1.ModelId
		, D1.FdpModelId
		, D1.FeatureId
		, D1.FdpFeatureId
		, D1.Volume
		, D1.PercentageTakeRate
		, D1.FdpVolumeDataItemId
	FROM
	Fdp_Changeset				AS C
	JOIN Fdp_VolumeHeader		AS H	ON	C.FdpVolumeHeaderId			= H.FdpVolumeHeaderId
	JOIN Fdp_ChangesetDataItem	AS D	ON	C.FdpChangesetId			= D.FdpChangesetId
										AND D.FdpChangesetDataItemId	= @FdpChangesetDataItemId
	JOIN Fdp_VolumeDataItem		AS D1	ON	H.FdpVolumeHeaderId			= D1.FdpVolumeHeaderId
										AND D.MarketId					= D1.MarketId
										AND (D1.FeatureId IS NOT NULL OR D1.FdpFeatureId IS NOT NULL)
	
	-- Replace all volume data rows with any changes from the changeset
	
	UPDATE D SET
		  D.TotalVolume = D1.TotalVolume
		, D.PercentageTakeRate = D1.PercentageTakeRate
	FROM @DataForModelAndFeature		AS D
	JOIN Fdp_Changeset			AS C	ON	D.FdpChangesetId	= C.FdpChangesetId
	JOIN Fdp_ChangesetDataItem	AS D1	ON	C.FdpChangesetId	= D1.FdpChangesetId
										AND D.MarketId			= D1.MarketId
										AND D.ModelId			= D1.ModelId
										AND D.FeatureId			= D1.FeatureId
										AND D1.IsDeleted		= 0;
										
	UPDATE D SET
		  D.TotalVolume = D1.TotalVolume
		, D.PercentageTakeRate = D1.PercentageTakeRate
	FROM @DataForModelAndFeature		AS D
	JOIN Fdp_Changeset			AS C	ON	D.FdpChangesetId	= C.FdpChangesetId
	JOIN Fdp_ChangesetDataItem	AS D1	ON	C.FdpChangesetId	= D1.FdpChangesetId
										AND D.MarketId			= D1.MarketId
										AND D.FdpModelId		= D1.FdpModelId
										AND D.FeatureId			= D1.FeatureId
										AND D1.IsDeleted		= 0;
										
	UPDATE D SET
		  D.TotalVolume = D1.TotalVolume
		, D.PercentageTakeRate = D1.PercentageTakeRate
	FROM @DataForModelAndFeature		AS D
	JOIN Fdp_Changeset			AS C	ON	D.FdpChangesetId	= C.FdpChangesetId
	JOIN Fdp_ChangesetDataItem	AS D1	ON	C.FdpChangesetId	= D1.FdpChangesetId
										AND D.MarketId			= D1.MarketId
										AND D.ModelId			= D1.ModelId
										AND D.FdpFeatureId		= D1.FdpFeatureId
										AND D1.IsDeleted		= 0;
										
	UPDATE D SET
		  D.TotalVolume = D1.TotalVolume
		, D.PercentageTakeRate = D1.PercentageTakeRate
	FROM @DataForModelAndFeature		AS D
	JOIN Fdp_Changeset			AS C	ON	D.FdpChangesetId	= C.FdpChangesetId
	JOIN Fdp_ChangesetDataItem	AS D1	ON	C.FdpChangesetId	= D1.FdpChangesetId
										AND D.MarketId			= D1.MarketId
										AND D.FdpModelId		= D1.FdpModelId
										AND D.FdpFeatureId		= D1.FdpFeatureId
										AND D1.IsDeleted		= 0;
	
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
		, SUM(TotalVolume) AS TotalVolume
		, CASE 
			WHEN ISNULL(@TotalVolumeByMarket, 0) <> 0 THEN SUM(TotalVolume) / CAST(@TotalVolumeByMarket AS DECIMAL)
			ELSE 0
		  END AS PercentageTakeRate
	FROM 
	@DataForModelAndFeature
	GROUP BY
	  FdpChangesetId
	, MarketId
	, FeatureId
	, FdpFeatureId