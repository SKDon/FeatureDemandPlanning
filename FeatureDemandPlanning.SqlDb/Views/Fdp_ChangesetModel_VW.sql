

CREATE VIEW [dbo].[Fdp_ChangesetModel_VW]
AS
	SELECT
		  C.FdpChangesetId
		, C.FdpVolumeHeaderId
		, C.CreatedOn
		, C.CreatedBy	AS CDSId
		, D.MarketId
		, D.ModelId
		, D.FdpModelId
		, D.IsPercentageUpdate
		, D.IsVolumeUpdate
		, D.TotalVolume
		, D.PercentageTakeRate
		, D.OriginalVolume
		, D.OriginalPercentageTakeRate
		, D.FdpTakeRateSummaryId

	FROM Fdp_Changeset			AS C
	JOIN Fdp_ChangesetDataItem	AS D	ON	C.FdpChangesetId = D.FdpChangesetId
										AND (D.ModelId		IS NOT NULL OR D.FdpModelId IS NOT NULL)
										AND D.FeatureId		IS NULL
										AND D.FdpFeatureId	IS NULL
										AND D.IsDeleted		= 0
	WHERE
	C.IsSaved = 0
	AND
	C.IsDeleted = 0;