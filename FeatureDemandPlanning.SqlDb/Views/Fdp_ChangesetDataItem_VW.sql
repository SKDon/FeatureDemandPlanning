﻿









CREATE VIEW [dbo].[Fdp_ChangesetDataItem_VW]
AS
	SELECT
	  D.FdpChangesetDataItemId
	, C.FdpChangesetId
	, C.FdpVolumeHeaderId
	, C.CreatedBy AS CDSId
	, D.CreatedOn
	, D.MarketId
	, D.ModelId
	, D.FdpModelId
	, D.FeatureId
	, D.FdpFeatureId
	, D.FeaturePackId
	, D.DerivativeCode
	, D.Note
	, D.TotalVolume
	, D.PercentageTakeRate
	, D.IsDeleted
	, D.IsVolumeUpdate
	, D.IsPercentageUpdate
	, D.OriginalVolume
	, D.OriginalPercentageTakeRate
	, D.FdpVolumeDataItemId
	, D.FdpTakeRateSummaryId
	, D.FdpTakeRateFeatureMixId
	, D.FdpPowertrainDataItemId
	, D.ParentFdpChangesetDataItemId
	, C.IsSaved
	, CAST(CASE
		WHEN 
		(D.FeatureId IS NOT NULL OR D.FdpFeatureId IS NOT NULL OR D.FeaturePackId IS NOT NULL) 
		AND
		(D.ModelId IS NOT NULL OR D.FdpModelId IS NOT NULL)
		AND
		D.Note IS NULL
		THEN
		1
		ELSE
		0
	  END AS BIT)
	  AS IsFeatureUpdate
	, CAST(CASE
		WHEN 
		D.FeatureId IS NULL 
		AND 
		D.FdpFeatureId IS NULL
		AND
		D.FeaturePackId IS NULL
		AND
		(D.ModelId IS NOT NULL OR D.FdpModelId IS NOT NULL)
		AND
		D.Note IS NULL
		THEN
		1
		ELSE
		0
	  END AS BIT)
	  AS IsModelUpdate
	, CAST(CASE
		WHEN 
		D.ModelId IS NULL 
		AND 
		D.FdpModelId IS NULL
		AND
		(D.FeatureId IS NOT NULL OR D.FdpFeatureId IS NOT NULL OR D.FeaturePackId IS NOT NULL)
		AND
		D.Note IS NULL
		THEN
		1
		ELSE
		0
	  END AS BIT)
	  AS IsFeatureMixUpdate
	, CAST(CASE
		WHEN
		D.DerivativeCode IS NOT NULL
		AND
		D.Note IS NULL
		THEN
		1
		ELSE
		0
	  END AS BIT)
	  AS IsPowertrainUpdate
	, CAST(CASE
		WHEN 
		D.FeatureId IS NULL 
		AND 
		D.FdpFeatureId IS NULL
		AND
		D.FeaturePackId IS NULL
		AND
		D.ModelId IS NULL
		AND
		D.FdpModelId IS NULL
		AND
		D.DerivativeCode IS NULL
		AND
		D.Note IS NULL
		THEN
		1
		ELSE
		0
	  END AS BIT)
	  AS IsMarketUpdate
	, CAST(
		CASE
			WHEN
			(
				D.FeatureId IS NOT NULL 
				OR 
				D.FeaturePackId IS NOT NULL 
				OR 
				D.ModelId IS NOT NULL 
			)
			AND 
			D.Note IS NOT NULL 
			THEN 
			1
			ELSE 
			0
		END AS BIT)
	  AS IsNote
	FROM
	Fdp_Changeset AS C
	JOIN Fdp_ChangesetDataItem AS D ON C.FdpChangesetId = D.FdpChangesetId
	WHERE
	D.IsDeleted = 0
	AND
	C.IsDeleted = 0
	AND
	C.IsSaved = 0