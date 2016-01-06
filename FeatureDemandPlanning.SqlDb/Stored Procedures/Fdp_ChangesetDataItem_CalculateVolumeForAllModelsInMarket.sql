CREATE PROCEDURE [dbo].[Fdp_ChangesetDataItem_CalculateVolumeForAllModelsInMarket]
	@FdpChangesetDataItemId AS INT
AS
	SET NOCOUNT ON;

	DECLARE @TotalVolumeByMarket AS INT;
	DECLARE @DataForModel AS TABLE
	(
		  Id							INT PRIMARY KEY IDENTITY(1,1)
		, FdpChangesetId				INT
		, MarketId						INT
		, ModelId						INT NULL
		, FdpModelId					INT NULL
		, TotalVolume					INT
		, PercentageTakeRate			DECIMAL(5, 4)
		, FdpTakeRateSummaryId			INT 
		, ParentFdpChangesetDataItemId	INT
	)

	-- Determine the total volume for the market
	
	SELECT 
		@TotalVolumeByMarket = dbo.fn_Fdp_VolumeByMarket_Get(D.FdpVolumeHeaderId, D.MarketId, D.CDSId)
	FROM
	Fdp_ChangesetDataItem_VW AS D
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
		, ParentFdpChangesetDataItemId
	)
	SELECT 
		  D.FdpChangesetId
		, D.MarketId
		, D.ModelId
		, D.FdpModelId
		, CASE 
			WHEN (@TotalVolumeByMarket * D1.PercentageTakeRate) > 0 AND (@TotalVolumeByMarket * D1.PercentageTakeRate) < 1 THEN 1
			ELSE (@TotalVolumeByMarket * D1.PercentageTakeRate)
		  END
		, D1.PercentageTakeRate
		, D1.FdpTakeRateSummaryId
		, D.FdpChangesetDataItemId
		
	FROM Fdp_ChangesetDataItem AS D
	JOIN Fdp_ChangesetDataItem_VW AS D1 ON D.FdpChangesetId = D1.FdpChangesetId
										AND D.MarketId = D1.MarketId
										AND D.FdpChangesetDataItemId <> D1.FdpChangesetDataItemId
										AND D.ModelId = D1.ModelId
										AND D1.IsModelUpdate = 1
	WHERE
	D.FdpChangesetDataItemId = @FdpChangesetDataItemId
	
	UNION
	
	SELECT 
		  D.FdpChangesetId
		, D.MarketId
		, D.ModelId
		, D.FdpModelId
		, CASE 
			WHEN (@TotalVolumeByMarket * D1.PercentageTakeRate) > 0 AND (@TotalVolumeByMarket * D1.PercentageTakeRate) < 1 THEN 1
			ELSE (@TotalVolumeByMarket * D1.PercentageTakeRate)
		  END
		, D1.PercentageTakeRate
		, D1.FdpTakeRateSummaryId
		, D.FdpChangesetDataItemId
		
	FROM Fdp_ChangesetDataItem AS D
	JOIN Fdp_ChangesetDataItem_VW AS D1 ON D.FdpChangesetId = D1.FdpChangesetId
										AND D.MarketId = D1.MarketId
										AND D.FdpChangesetDataItemId <> D1.FdpChangesetDataItemId
										AND D.ModelId = D1.ModelId
										AND D1.IsModelUpdate = 1
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
		, ParentFdpChangesetDataItemId
	)
	SELECT
		  D.FdpChangesetId
		, S.MarketId
		, S.ModelId
		, S.FdpModelId
		, CASE 
			WHEN (@TotalVolumeByMarket * S.PercentageTakeRate) > 0 AND (@TotalVolumeByMarket * S.PercentageTakeRate) < 1 THEN 1
			ELSE (@TotalVolumeByMarket * S.PercentageTakeRate)
		  END
		, S.PercentageTakeRate
		, S.FdpTakeRateSummaryId
		, D.FdpChangesetDataItemId
	FROM
	Fdp_ChangesetDataItem_VW			AS D
	JOIN Fdp_TakeRateSummary			AS S	ON	D.FdpVolumeHeaderId			= S.FdpVolumeHeaderId
												AND D.MarketId					= S.MarketId
	LEFT JOIN Fdp_ChangesetDataItem_VW	AS CUR	ON	S.FdpTakeRateSummaryId		= CUR.FdpTakeRateSummaryId
	WHERE
	D.FdpChangesetDataItemId = @FdpChangesetDataItemId
	AND
	CUR.FdpChangesetDataItemId IS NULL
	
	-- Delete any existing changeset rows
	
	PRINT 'Deleting existing changes for model...'
	
	UPDATE D1 SET IsDeleted = 1
	FROM
	Fdp_ChangesetDataItem_VW		AS D
	JOIN Fdp_ChangesetDataItem_VW	AS D1	ON	D.FdpChangesetId			= D1.FdpChangesetId
											AND D1.IsModelUpdate			= 1
	JOIN Fdp_ChangesetDataItem		AS D2	ON	D1.FdpChangesetDataItemId	= D2.FdpChangesetDataItemId
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
		, ParentFdpChangesetDataItemId
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
		, ParentFdpChangesetDataItemId
	FROM 
	@DataForModel