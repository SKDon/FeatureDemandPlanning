CREATE PROCEDURE [dbo].[Fdp_ChangesetDataItem_CalculateVolumeForAllModels]
	@FdpChangesetDataItemId AS INT
AS
	SET NOCOUNT ON;

	DECLARE @TotalVolumeByMarket AS INT;
	DECLARE @DataForModel AS TABLE
	(
		  Id					INT PRIMARY KEY IDENTITY(1,1)
		, FdpChangesetId		INT
		, MarketId				INT
		, ModelId				INT NULL
		, FdpModelId			INT NULL
		, TotalVolume			INT
		, PercentageTakeRate	DECIMAL(5, 4)
		, FdpTakeRateSummaryId	INT 
	)

	-- Determine the total volume for the market
	
	SELECT 
		@TotalVolumeByMarket = TotalVolume
	FROM
	Fdp_ChangesetDataItem AS D
	WHERE
	D.FdpChangesetDataItemId = @FdpChangesetDataItemId;
												
	-- Create new changeset entries based on older changeset entries
	-- We need to update the volume based on the % take for the changeset item
	
	PRINT 'Calculating new changeset data from existing changes...'
	
	INSERT INTO @DataForModel
	(
		  FdpChangesetId
		, MarketId
		, ModelId
		, FdpModelId
		, TotalVolume
		, PercentageTakeRate
		, FdpTakeRateSummaryId
	)
	SELECT 
		  C.FdpChangesetId
		, D.MarketId
		, D.ModelId
		, D.FdpModelId
		, CASE 
			WHEN (@TotalVolumeByMarket * D1.PercentageTakeRate) > 0 AND (@TotalVolumeByMarket * D1.PercentageTakeRate) < 1 THEN 1
			ELSE (@TotalVolumeByMarket * D1.PercentageTakeRate)
		  END
		, D1.PercentageTakeRate
		, D1.FdpTakeRateSummaryId
		
	FROM Fdp_Changeset AS C
	JOIN Fdp_ChangesetDataItem AS D ON C.FdpChangesetId		= D.FdpChangesetId
	JOIN Fdp_ChangesetDataItem AS D1	ON D.FdpChangesetId = C.FdpChangesetId
										AND D.MarketId		= D1.MarketId
										AND D.FdpChangesetDataItemId <> D1.FdpChangesetDataItemId
										AND D.ModelId		= D1.ModelId
										AND D1.FeatureId	IS NULL
										AND D1.FdpFeatureId IS NULL
										AND D1.IsDeleted	= 0
	WHERE
	D.FdpChangesetDataItemId = @FdpChangesetDataItemId
	
	UNION
	
	SELECT 
		  C.FdpChangesetId
		, D.MarketId
		, D.ModelId
		, D.FdpModelId
		, CASE 
			WHEN (@TotalVolumeByMarket * D1.PercentageTakeRate) > 0 AND (@TotalVolumeByMarket * D1.PercentageTakeRate) < 1 THEN 1
			ELSE (@TotalVolumeByMarket * D1.PercentageTakeRate)
		  END
		, D1.PercentageTakeRate
		, D1.FdpTakeRateSummaryId
		
	FROM Fdp_Changeset AS C
	JOIN Fdp_ChangesetDataItem AS D ON C.FdpChangesetId		= D.FdpChangesetId
	JOIN Fdp_ChangesetDataItem AS D1	ON D.FdpChangesetId = C.FdpChangesetId
										AND D.MarketId		= D1.MarketId
										AND D.FdpChangesetDataItemId <> D1.FdpChangesetDataItemId
										AND D.FdpModelId	= D1.FdpModelId
										AND D1.FeatureId	IS NULL
										AND D1.FdpFeatureId IS NULL
										AND D1.IsDeleted	= 0
	WHERE
	D.FdpChangesetDataItemId = @FdpChangesetDataItemId;
	
	-- Add all volume data existing rows to our data table where there is not an active changeset item currently
	
	PRINT 'Calculating new changeset data...'
	
	INSERT INTO @DataForModel
	(
		  FdpChangesetId
		, MarketId
		, ModelId
		, FdpModelId
		, TotalVolume
		, PercentageTakeRate
		, FdpTakeRateSummaryId
	)
	SELECT
		  C.FdpChangesetId
		, S.MarketId
		, S.ModelId
		, S.FdpModelId
		, CASE 
			WHEN (@TotalVolumeByMarket * S.PercentageTakeRate) > 0 AND (@TotalVolumeByMarket * S.PercentageTakeRate) < 1 THEN 1
			ELSE (@TotalVolumeByMarket * S.PercentageTakeRate)
		  END
		, S.PercentageTakeRate
		, S.FdpTakeRateSummaryId
	FROM
	Fdp_Changeset				AS C
	JOIN Fdp_VolumeHeader		AS H	ON	C.FdpVolumeHeaderId			= H.FdpVolumeHeaderId
	JOIN Fdp_ChangesetDataItem	AS D	ON	C.FdpChangesetId			= D.FdpChangesetId
										AND D.FdpChangesetDataItemId	= @FdpChangesetDataItemId
	JOIN Fdp_TakeRateSummary	AS S	ON	H.FdpVolumeHeaderId			= S.FdpVolumeHeaderId
										AND D.MarketId					= S.MarketId
	LEFT JOIN Fdp_ChangesetDataItem AS CUR
										ON	S.FdpTakeRateSummaryId		= CUR.FdpTakeRateSummaryId
										AND CUR.IsDeleted				= 0
	WHERE
	CUR.FdpChangesetDataItemId IS NULL
	
	-- Delete any existing changeset rows
	
	PRINT 'Deleting existing changes for model...'
	
	UPDATE D1 SET IsDeleted = 1
	FROM
	Fdp_Changeset AS C
	JOIN Fdp_ChangesetDataItem AS D		ON	C.FdpChangesetId	= D.FdpChangesetId
	JOIN Fdp_ChangesetDataItem AS D1	ON	C.FdpChangesetId	= D1.FdpChangesetId
										AND D1.IsDeleted		= 0
										AND D.ModelId			= D1.ModelId
										AND D1.FeatureId		IS NULL 
										AND D1.FdpFeatureId		IS NULL
	WHERE
	D.FdpChangesetDataItemId = @FdpChangesetDataItemId;
	
	UPDATE D1 SET IsDeleted = 1
	FROM
	Fdp_Changeset AS C
	JOIN Fdp_ChangesetDataItem AS D		ON	C.FdpChangesetId	= D.FdpChangesetId
	JOIN Fdp_ChangesetDataItem AS D1	ON	C.FdpChangesetId	= D1.FdpChangesetId
										AND D1.IsDeleted		= 0
										AND D.FdpModelId		= D1.FdpModelId
										AND D1.FeatureId		IS NULL 
										AND D1.FdpFeatureId		IS NULL
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
		, TotalVolume
		, PercentageTakeRate
		, IsVolumeUpdate
		, IsPercentageUpdate
		, FdpTakeRateSummaryId
	)
	SELECT 
		  FdpChangesetId
		, MarketId
		, ModelId
		, FdpModelId
		, TotalVolume
		, PercentageTakeRate
		, 1
		, 0
		, FdpTakeRateSummaryId
	FROM 
	@DataForModel