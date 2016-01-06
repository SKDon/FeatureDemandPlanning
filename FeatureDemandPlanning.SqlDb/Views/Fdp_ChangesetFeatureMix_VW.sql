


CREATE VIEW [dbo].[Fdp_ChangesetFeatureMix_VW]
AS
	SELECT
		  C.FdpChangesetId
		, C.FdpVolumeHeaderId
		, C.CreatedOn
		, C.CreatedBy	AS CDSId
		, D.MarketId
		, D.FeatureId
		, D.FdpFeatureId
		, D.IsPercentageUpdate
		, D.IsVolumeUpdate
		, D.TotalVolume
		, D.PercentageTakeRate
		, D.OriginalVolume
		, D.OriginalPercentageTakeRate
		, D.FdpTakeRateFeatureMixId

	FROM Fdp_Changeset			AS C
	JOIN Fdp_ChangesetDataItem	AS D	ON	C.FdpChangesetId = D.FdpChangesetId
										AND D.ModelId		IS NULL
										AND D.FdpModelId	IS NULL
										AND (D.FeatureId	IS NOT NULL OR D.FdpFeatureId	IS NOT NULL)
										AND D.IsDeleted = 0
	WHERE
	C.IsSaved = 0
	AND
	C.IsDeleted = 0;