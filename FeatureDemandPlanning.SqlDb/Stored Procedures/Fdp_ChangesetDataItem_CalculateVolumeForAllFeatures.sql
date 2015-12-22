CREATE PROCEDURE [dbo].[Fdp_ChangesetDataItem_CalculateVolumeForAllFeatures]
	@FdpChangesetDataItemId AS INT
AS
	SET NOCOUNT ON;

	DECLARE @TotalVolumeByModel AS TABLE
	(
		  ModelId INT NULL
		, FdpModelId INT NULL
		, Volume INT
	)
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
	
	-- Determine the total volume for the model for the market
	
	INSERT INTO @TotalVolumeByModel
	(
		  ModelId
		, FdpModelId
		, Volume
	)
	SELECT 
		  S.ModelId
		, S.FdpModelId
		, CASE 
			WHEN D1.FdpChangesetDataItemId IS NOT NULL THEN D1.TotalVolume
			ELSE S.Volume
		  END 
	FROM
	Fdp_Changeset						AS C
	JOIN Fdp_VolumeHeader				AS H	ON	C.FdpVolumeHeaderId			= H.FdpVolumeHeaderId
	JOIN Fdp_ChangesetDataItem			AS D	ON	C.FdpChangesetId			= D.FdpChangesetId
												AND D.FdpChangesetDataItemId	= @FdpChangesetDataItemId
	JOIN Fdp_TakeRateSummary			AS S	ON	H.FdpVolumeHeaderId			= S.FdpVolumeHeaderId
												AND D.MarketId					= S.MarketId
												AND S.ModelId					IS NOT NULL
	LEFT JOIN Fdp_ChangesetDataItem		AS D1	ON	C.FdpChangesetId			= D1.FdpChangesetId
												AND D1.IsDeleted				= 0
												AND D1.MarketId					= D.MarketId
												AND D1.ModelId					= S.ModelId
												AND D1.FeatureId				IS NULL
												AND D1.FdpFeatureId				IS NULL						
	UNION
	
	SELECT 
		  S.ModelId
		, S.FdpModelId
		, CASE 
			WHEN D1.FdpChangesetDataItemId IS NOT NULL THEN D1.TotalVolume
			ELSE S.Volume
		  END
	FROM
	Fdp_Changeset AS C
	JOIN Fdp_VolumeHeader				AS H	ON	C.FdpVolumeHeaderId			= H.FdpVolumeHeaderId
	JOIN Fdp_ChangesetDataItem			AS D	ON	C.FdpChangesetId			= D.FdpChangesetId
												AND D.FdpChangesetDataItemId	= @FdpChangesetDataItemId
	JOIN Fdp_TakeRateSummary			AS S	ON	H.FdpVolumeHeaderId			= S.FdpVolumeHeaderId
												AND D.MarketId					= S.MarketId
												AND S.FdpModelId				IS NOT NULL
	LEFT JOIN Fdp_ChangesetDataItem		AS D1	ON	C.FdpChangesetId			= D1.FdpChangesetId
												AND D1.IsDeleted				= 0
												AND D1.MarketId					= D.MarketId
												AND D1.FdpModelId				= S.FdpModelId
												AND D1.FeatureId				IS NULL
												AND D1.FdpFeatureId				IS NULL
												
	-- Create new changeset entries based on older changeset entries
	-- We need to update the volume based on the % take for the changeset item
	
	PRINT 'Calculating new changeset data from existing changes...'
	
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
		, D1.FeatureId
		, D1.FdpFeatureId
		, V.Volume * D1.PercentageTakeRate
		, D1.PercentageTakeRate
		, D1.FdpVolumeDataItemId
		
	FROM Fdp_Changeset AS C
	JOIN Fdp_ChangesetDataItem AS D ON C.FdpChangesetId		= D.FdpChangesetId
	JOIN Fdp_ChangesetDataItem AS D1	ON D.FdpChangesetId = C.FdpChangesetId
										AND D.MarketId		= D1.MarketId
										AND D.FdpChangesetDataItemId <> D1.FdpChangesetDataItemId
										AND D1.ModelId		IS NOT NULL								-- Specific to model being updated level
										AND (D1.FeatureId	IS NOT NULL OR D1.FdpFeatureId	IS NOT NULL) -- Feature level, not summary
										AND D1.IsDeleted	= 0
	JOIN @TotalVolumeByModel	AS V	ON D1.ModelId		= V.ModelId
	WHERE
	D.FdpChangesetDataItemId = @FdpChangesetDataItemId
	
	UNION
	
	SELECT 
		  C.FdpChangesetId
		, D.MarketId
		, D.ModelId
		, D.FdpModelId
		, D1.FeatureId
		, D1.FdpFeatureId
		, V.Volume * D1.PercentageTakeRate
		, D1.PercentageTakeRate
		, D1.FdpVolumeDataItemId
		
	FROM Fdp_Changeset AS C
	JOIN Fdp_ChangesetDataItem AS D ON C.FdpChangesetId		= D.FdpChangesetId
	JOIN Fdp_ChangesetDataItem AS D1	ON D.FdpChangesetId = C.FdpChangesetId
										AND D.MarketId		= D1.MarketId
										AND D.FdpChangesetDataItemId <> D1.FdpChangesetDataItemId
										AND D1.FdpModelId	IS NOT NULL								-- Specific to model being updated level
										AND (D1.FeatureId	IS NOT NULL OR D1.FdpFeatureId	IS NOT NULL) -- Feature level, not summary
										AND D1.IsDeleted	= 0
	JOIN @TotalVolumeByModel	AS V	ON D1.FdpModelId	= V.FdpModelId
	WHERE
	D.FdpChangesetDataItemId = @FdpChangesetDataItemId
	
	-- Add all volume data existing rows to our data table where there is not an active changeset item currently
	
	PRINT 'Calculating new changeset data...'
	
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
		, D1.MarketId
		, D1.ModelId
		, D1.FdpModelId
		, D1.FeatureId
		, D1.FdpFeatureId
		, V.Volume * D1.PercentageTakeRate
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
										AND D1.ModelId IS NOT NULL
	JOIN @TotalVolumeByModel	AS V	ON	D1.ModelId					= V.ModelId
	LEFT JOIN Fdp_ChangesetDataItem AS CUR
										ON	D1.FdpVolumeDataItemId		= CUR.FdpVolumeDataItemId
										AND CUR.IsDeleted				= 0
	WHERE
	CUR.FdpChangesetDataItemId IS NULL
	
	UNION
	
		SELECT
		  C.FdpChangesetId
		, D1.MarketId
		, D1.ModelId
		, D1.FdpModelId
		, D1.FeatureId
		, D1.FdpFeatureId
		, V.Volume * D1.PercentageTakeRate
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
										AND D1.FdpModelId IS NOT NULL
	JOIN @TotalVolumeByModel	AS V	ON	D1.FdpModelId				= V.FdpModelId
	LEFT JOIN Fdp_ChangesetDataItem AS CUR
										ON	D1.FdpVolumeDataItemId		= CUR.FdpVolumeDataItemId
										AND CUR.IsDeleted				= 0
	WHERE
	CUR.FdpChangesetDataItemId IS NULL;
	
	-- Delete any existing changeset rows
	
	PRINT 'Deleting existing changes for model...'
	
	UPDATE D1 SET IsDeleted = 1
	FROM
	Fdp_Changeset AS C
	JOIN Fdp_ChangesetDataItem AS D		ON	C.FdpChangesetId	= D.FdpChangesetId
	JOIN Fdp_ChangesetDataItem AS D1	ON	C.FdpChangesetId	= D1.FdpChangesetId
										AND D1.IsDeleted		= 0
										AND (D1.ModelId IS NOT NULL OR D1.FdpModelId IS NOT NULL)
										AND (D1.FeatureId IS NOT NULL OR D1.FdpFeatureId IS NOT NULL)
	WHERE
	D.FdpChangesetDataItemId = @FdpChangesetDataItemId;
	
	-- Add new new changeset rows
	
	PRINT 'Adding new changeset data...'
	
	INSERT INTO Fdp_ChangesetDataItem
	(
		  FdpChangesetId
		, MarketId
		, ModelId
		, FdpModelId
		, FeatureId
		, FdpFeatureId
		, TotalVolume
		, PercentageTakeRate
		, IsVolumeUpdate
		, IsPercentageUpdate
		, FdpVolumeDataItemId
	)
	SELECT 
		  FdpChangesetId
		, MarketId
		, ModelId
		, FdpModelId
		, FeatureId
		, FdpFeatureId
		, TotalVolume
		, PercentageTakeRate
		, 1
		, 0
		, FdpVolumeDataItemId
	FROM 
	@DataForFeature