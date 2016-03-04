CREATE PROCEDURE [dbo].[Fdp_Changeset_PersistChanges]
	  @FdpChangesetId	AS INT
	, @Comment		AS NVARCHAR(MAX)
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

	-- Add the comment to the changeset
	
	UPDATE C SET Comment = @Comment
	FROM Fdp_Changeset AS C
	WHERE
	C.FdpChangesetId = @FdpChangesetId;
	
	-- Add any new ones

	--INSERT INTO Fdp_VolumeDataItem
	--(
	--	  CreatedOn
	--	, CreatedBy
	--	, FdpVolumeHeaderId
	--	, IsManuallyEntered
	--	, MarketId
	--	, MarketGroupId
	--	, ModelId
	--	, FdpModelId
	--	, TrimId
	--	, FdpTrimId
	--	, FeatureId
	--	, FdpFeatureId
	--	, Volume
	--	, PercentageTakeRate
	--)
	--SELECT
	--	  D.CreatedOn
	--	, C.CreatedBy
	--	, H.FdpVolumeHeaderId
	--	, 1
	--	, D.MarketId
	--	, MK.Market_Group_Id
	--	, D.ModelId
	--	, D.FdpModelId
	--	, CASE 
	--		WHEN M.Id IS NOT NULL THEN M.Trim_Id
	--		ELSE M1.TrimId
	--	  END
	--	, M1.FdpTrimId
	--	, D.FeatureId
	--	, D.FdpFeatureId
	--	, D.TotalVolume
	--	, D.PercentageTakeRate
	--FROM
	--Fdp_Changeset					AS C
	--JOIN Fdp_VolumeHeader			AS H	ON C.FdpVolumeHeaderId = H.FdpVolumeHeaderId
	--JOIN Fdp_ChangesetDataItem		AS D	ON	C.FdpChangesetId	= D.FdpChangesetId
	--										AND D.IsDeleted			= 0
	--										AND (D.FeatureId IS NOT NULL OR D.FdpFeatureId IS NOT NULL)
	--										AND D.FdpVolumeDataItemId IS NULL
	--JOIN OXO_Market_Group_Market_VW	AS MK	ON D.MarketId			= MK.Market_Id
	--LEFT JOIN OXO_Programme_Model	AS M	ON D.ModelId			= M.Id
	--LEFT JOIN Fdp_Model				AS M1	ON D.FdpModelId			= M1.FdpModelId
	--WHERE
	--C.FdpChangesetId = @FdpChangesetId
	--AND
	--C.IsSaved = 0;

	--INSERT INTO Fdp_TakeRateSummary
	--(
	--	  CreatedOn
	--	, CreatedBy
	--	, FdpVolumeHeaderId
	--	, FdpSpecialFeatureMappingId
	--	, MarketId
	--	, ModelId
	--	, FdpModelId
	--	, Volume
	--	, PercentageTakeRate
	--)
	--SELECT
	--	  D.CreatedOn
	--	, C.CreatedBy
	--	, H.FdpVolumeHeaderId
	--	, 1 -- Full year take, we have no idea what the figure actually represents
	--	, D.MarketId
	--	, D.ModelId
	--	, D.FdpModelId
	--	, D.TotalVolume
	--	, D.PercentageTakeRate
	--FROM
	--Fdp_Changeset				AS C
	--JOIN Fdp_VolumeHeader		AS H	ON	C.FdpVolumeHeaderId		= H.FdpVolumeHeaderId
	--JOIN Fdp_ChangesetDataItem	AS D	ON	C.FdpChangesetId		= D.FdpChangesetId
	--									AND D.IsDeleted				= 0
	--									AND (D.FeatureId IS NOT NULL OR D.FdpFeatureId IS NOT NULL)
	--LEFT JOIN Fdp_TakeRateSummary	AS S	ON	H.FdpVolumeHeaderId		= S.FdpVolumeHeaderId
	--									AND D.MarketId				= S.MarketId
	--									AND D.ModelId				= S.ModelId
	--									AND (D.FeatureId IS NULL AND D.FdpFeatureId IS NULL)
	--WHERE
	--C.FdpChangesetId = @FdpChangesetId
	--AND
	--C.IsSaved = 0
	--AND
	--S.FdpTakeRateSummaryId IS NULL

	--UNION

	--SELECT
	--	  D.CreatedOn
	--	, C.CreatedBy
	--	, H.FdpVolumeHeaderId
	--	, 1 -- Full year take, we have no idea what the figure actually represents
	--	, D.MarketId
	--	, D.ModelId
	--	, D.FdpModelId
	--	, D.TotalVolume
	--	, D.PercentageTakeRate
	--FROM
	--Fdp_Changeset				AS C
	--JOIN Fdp_VolumeHeader		AS H	ON	C.FdpVolumeHeaderId		= H.FdpVolumeHeaderId
	--JOIN Fdp_ChangesetDataItem	AS D	ON	C.FdpChangesetId		= D.FdpChangesetId
	--									AND D.IsDeleted				= 0
	--									AND (D.FeatureId IS NOT NULL OR D.FdpFeatureId IS NOT NULL)
	--LEFT JOIN Fdp_TakeRateSummary	AS S	ON	H.FdpVolumeHeaderId		= S.FdpVolumeHeaderId
	--									AND D.MarketId				= S.MarketId
	--									AND D.FdpModelId			= S.FdpModelId
	--									AND (D.FeatureId IS NULL AND D.FdpFeatureId IS NULL)
	--WHERE
	--C.FdpChangesetId = @FdpChangesetId
	--AND
	--C.IsSaved = 0
	--AND
	--S.FdpTakeRateSummaryId IS NULL;