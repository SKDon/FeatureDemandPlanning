CREATE PROCEDURE [dbo].[Fdp_Changeset_PersistChanges]
	  @FdpChangesetId	AS INT
	, @Comment			AS NVARCHAR(MAX)
	, @CDSID			AS NVARCHAR(16)
AS
	SET NOCOUNT ON;

	-- Update existing rows

	UPDATE D1 SET
		  Volume				= D.TotalVolume
		, PercentageTakeRate	= D.PercentageTakeRate
		, UpdatedOn				= D.CreatedOn
		, UpdatedBy				= D.CDSId
	FROM
	Fdp_ChangesetDataItem_VW	AS D
	JOIN Fdp_VolumeDataItem		AS D1	ON	D.FdpVolumeDataItemId	= D1.FdpVolumeDataItemId
	WHERE
	D.FdpChangesetId = @FdpChangesetId
	AND
	D.IsSaved = 0
	AND
	D.IsFeatureUpdate = 1

	-- Model summary rows

	UPDATE S SET
		  Volume				= D.TotalVolume
		, PercentageTakeRate	= D.PercentageTakeRate
		, UpdatedOn				= D.CreatedOn
		, UpdatedBy				= D.CDSId
	FROM
	Fdp_ChangesetDataItem_VW	AS D
	JOIN Fdp_TakeRateSummary	AS S	ON	D.FdpTakeRateSummaryId	= S.FdpTakeRateSummaryId
	WHERE
	D.FdpChangesetId = @FdpChangesetId
	AND
	D.IsSaved = 0
	AND
	D.IsModelUpdate = 1

	-- Market summary rows

	UPDATE S SET
		  Volume				= D.TotalVolume
		, PercentageTakeRate	= D.PercentageTakeRate
		, UpdatedOn				= D.CreatedOn
		, UpdatedBy				= D.CDSId
	FROM
	Fdp_ChangesetDataItem_VW	AS D
	JOIN Fdp_TakeRateSummary	AS S	ON	D.FdpTakeRateSummaryId	= S.FdpTakeRateSummaryId
	WHERE
	D.FdpChangesetId = @FdpChangesetId
	AND
	D.IsSaved = 0
	AND
	D.IsMarketUpdate = 1

	-- Update the header with the overall volume

	UPDATE H SET TotalVolume = C.TotalVolume
	FROM 
	Fdp_ChangesetDataItem_VW AS C
	JOIN Fdp_VolumeHeader AS H ON C.FdpVolumeHeaderId = H.FdpVolumeHeaderId
	WHERE
	C.FdpChangesetId = @FdpChangesetId
	AND
	C.IsMarketUpdate = 1
	AND
	C.MarketId IS NULL

	-- Feature mix changes

	UPDATE M SET
		  Volume				= D.TotalVolume
		, PercentageTakeRate	= D.PercentageTakeRate
		, UpdatedOn				= D.CreatedOn
		, UpdatedBy				= D.CDSId
	FROM
	Fdp_ChangesetDataItem_VW	AS D
	JOIN Fdp_TakeRateFeatureMix AS M	ON	D.FdpTakeRateFeatureMixId = M.FdpTakeRateFeatureMixId
	WHERE
	D.FdpChangesetId = @FdpChangesetId
	AND
	D.IsSaved = 0
	AND
	D.IsFeatureMixUpdate = 1
	
	-- Powertrain changes
	
	UPDATE P SET
		  Volume				= D.TotalVolume
		, PercentageTakeRate	= D.PercentageTakeRate
		, UpdatedOn				= D.CreatedOn
		, UpdatedBy				= D.CDSId
	FROM
	Fdp_ChangesetDataItem_VW AS D
	JOIN Fdp_PowertrainDataItem AS P ON D.FdpPowertrainDataItemId = P.FdpPowertrainDataItemId
	WHERE
	D.FdpChangesetId = @FdpChangesetId
	AND
	D.IsSaved = 0
	AND
	D.IsPowertrainUpdate = 1

	-- Add Notes

	INSERT INTO Fdp_TakeRateDataItemNote
	(
		  FdpTakeRateDataItemId
		, FdpTakeRateSummaryId
		, EnteredOn
		, EnteredBy
		, Note
	)
	SELECT
		  D.FdpVolumeDataItemId
		, D.FdpTakeRateSummaryId
		, D.CreatedOn
		, D.CDSId
		, D.Note
	FROM
	Fdp_ChangesetDataItem_VW AS D
	JOIN Fdp_VolumeDataItem AS D1 ON D.FdpVolumeDataItemId = D1.FdpVolumeDataItemId
	WHERE
	D.FdpChangesetId = @FdpChangesetId
	AND
	D.IsSaved = 0
	AND
	D.IsNote = 1

	UNION

	SELECT
		  D.FdpVolumeDataItemId
		, D.FdpTakeRateSummaryId
		, D.CreatedOn
		, D.CDSId
		, D.Note
	FROM
	Fdp_ChangesetDataItem_VW AS D
	JOIN Fdp_TakeRateSummary AS S ON D.FdpTakeRateSummaryId = S.FdpTakeRateSummaryId
	WHERE
	D.FdpChangesetId = @FdpChangesetId
	AND
	D.IsSaved = 0
	AND
	D.IsNote = 1

	-- Add the comment to the changeset
	
	UPDATE C SET Comment = @Comment
	FROM Fdp_Changeset AS C
	WHERE
	C.FdpChangesetId = @FdpChangesetId;
	
	-- Remove any "cached" pivot data for that market
	-- as the underlying dataset will now have changed

	DECLARE @FdpVolumeHeaderId AS INT;
	DECLARE @MarketId AS INT;

	SELECT TOP 1 @FdpVolumeHeaderId = FdpVolumeHeaderId, @MarketId = MarketId
	FROM Fdp_Changeset WHERE FdpChangesetId = @FdpChangesetId;

	DELETE FROM Fdp_PivotData WHERE FdpPivotHeaderId IN (SELECT FdpPivotHeaderId FROM Fdp_PivotHeader WHERE FdpVolumeHeaderId = @FdpVolumeHeaderId AND (MarketId = @MarketId OR MarketId IS NULL));
	DELETE FROM Fdp_PivotHeader WHERE FdpPivotHeaderId IN (SELECT FdpPivotHeaderId FROM Fdp_PivotHeader WHERE FdpVolumeHeaderId = @FdpVolumeHeaderId AND (MarketId = @MarketId OR MarketId IS NULL));

	-- Update the ALL MARKETS view accordingly

	EXEC Fdp_TakeRateData_CalculateAllMarkets @FdpVolumeHeaderId = @FdpVolumeHeaderId, @CDSID = @CDSID;