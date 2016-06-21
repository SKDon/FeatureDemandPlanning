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

	-- Store the combined pack / option take for those features that are part of a pack, but can also be chosen as optional items
	-- This is to cater for the CPAT export that is available from the ALL MARKETS view

	-- Just delete the rows, easier than updating existing. There's no dependencies

	DELETE FROM Fdp_CombinedPackOption WHERE FdpVolumeHeaderId = @FdpVolumeHeaderId AND MarketId = @MarketId;

	;WITH PackFeaturesAsOptions AS
	(
		SELECT
			  C.MarketId
			, C.FdpVolumeHeaderId
			, F.FeatureId
			, F.FeaturePackId 
		FROM
		Fdp_Changeset					AS C
		JOIN Fdp_VolumeHeader_VW		AS H	ON	C.FdpVolumeHeaderId		= H.FdpVolumeHeaderId
		JOIN Fdp_Feature_VW				AS F	ON	H.DocumentId			= F.DocumentId
		JOIN Fdp_FeatureApplicability	AS A	ON	F.FeatureId				= A.FeatureId
												AND H.DocumentId			= A.DocumentId
												AND C.MarketId				= A.MarketId
		WHERE
		F.FeaturePackId IS NOT NULL
		AND
		A.Applicability LIKE '%O%'
		AND
		C.FdpChangesetId = @FdpChangesetId
		GROUP BY
		C.FdpVolumeHeaderId, C.MarketId, F.FeatureId, F.FeaturePackId
	)
	INSERT INTO Fdp_CombinedPackOption
	(
		  FdpVolumeHeaderId
		, MarketId
		, ModelId
		, FeatureId
		, Volume
		, PercentageTakeRate
	)
	SELECT
		  PF.FdpVolumeHeaderId
		, PF.MarketId
		, FT.ModelId
		, PF.FeatureId
		, CASE
			WHEN A.Applicability LIKE '%O%' THEN ISNULL(FT.Volume, 0) + ISNULL(PT.Volume, 0) 
			ELSE ISNULL(FT.Volume, 0)
		  END AS Volume
		, CASE
			WHEN A.Applicability LIKE '%O%' THEN ISNULL(FT.PercentageTakeRate, 0) + ISNULL(PT.PercentageTakeRate, 0) 
			ELSE ISNULL(FT.PercentageTakeRate, 0)
		  END AS PercentageTakeRate
	FROM
	PackFeaturesAsOptions		AS PF
	JOIN Fdp_VolumeHeader_VW	AS H	ON	PF.FdpVolumeHeaderId	= H.FdpVolumeHeaderId
	JOIN Fdp_VolumeDataItem		AS FT	ON	H.FdpVolumeHeaderId		= FT.FdpVolumeHeaderId
										AND PF.MarketId				= FT.MarketId
										AND PF.FeatureId			= FT.FeatureId

	JOIN Fdp_FeatureApplicability AS A	ON	H.DocumentId		= A.DocumentId
										AND PF.MarketId			= A.MarketId
										AND PF.FeatureId		= A.FeatureId
										AND FT.ModelId			= A.ModelId

	LEFT JOIN Fdp_VolumeDataItem AS PT ON	H.FdpVolumeHeaderId = PT.FdpVolumeHeaderId
										AND PF.MarketId			= PT.MarketId
										AND PT.FeatureId		IS NULL
										AND PF.FeaturePackId	= PT.FeaturePackId
										AND FT.ModelId			= PT.ModelId

	-- Feature mix for these combined options

	INSERT INTO Fdp_CombinedPackOption
	(
		  FdpVolumeHeaderId
		, MarketId
		, FeatureId
		, Volume
		, PercentageTakeRate
	)
	SELECT
		  C.FdpVolumeHeaderId
		, C.MarketId
		, C.FeatureId
		, SUM(C.Volume)
		, SUM(C.Volume) / CAST(SUM(S.TotalVolume) AS DECIMAL(10, 4))

	FROM Fdp_CombinedPackOption AS C
	JOIN Fdp_TakeRateSummaryByModelAndMarket_VW AS S ON C.FdpVolumeHeaderId = S.FdpVolumeHeaderId
													 AND C.MarketId			= S.MarketId
													 AND C.ModelId			= S.ModelId
	WHERE
	C.FdpVolumeHeaderId = @FdpVolumeHeaderId
	AND
	C.MarketId = @MarketId
	GROUP BY
	C.FdpVolumeHeaderId, C.MarketId, C.FeatureId

	-- Update the ALL MARKETS view accordingly

	EXEC Fdp_TakeRateData_CalculateAllMarkets @FdpVolumeHeaderId = @FdpVolumeHeaderId, @CDSID = @CDSID;