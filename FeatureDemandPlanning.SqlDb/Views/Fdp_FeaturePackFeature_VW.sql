CREATE VIEW [dbo].[Fdp_FeaturePackFeature_VW] AS

	SELECT P.FdpVolumeHeaderId
	, P.MarketId
	, P.FeaturePackId
	, P.FeaturePack
	, P.ModelId
	, P.Volume AS FeaturePackVolume
	, P.PercentageTakeRate AS FeaturePackTakeRate
	, D.FeatureId
	, F.BrandDescription
	, F.SystemDescription
	, F.FeatureCode
	, D.Volume
	, D.PercentageTakeRate
	-- Can only work validity out at this stage if the take for a feature is less than the take for any parent pack
	, CAST(CASE WHEN P.Volume >= D.Volume THEN 1 ELSE 0 END AS BIT) AS IsValid
	FROM Fdp_FeaturePack_VW AS P
	JOIN Fdp_VolumeDataItem_VW AS D ON P.FdpVolumeHeaderId = D.FdpVolumeHeaderId
										AND P.MarketId = D.MarketId
										AND P.ModelId = D.ModelId
										AND P.FeaturePackId = D.FeaturePackId
										AND D.FeatureId IS NOT NULL
	JOIN Fdp_VolumeHeader AS H ON D.FdpVolumeHeaderId = H.FdpVolumeHeaderId
	JOIN OXO_Doc AS O ON H.DocumentId = O.Id
	JOIN OXO_Programme_Feature_VW AS F ON D.FeatureId = F.ID
										AND F.ProgrammeId = O.Programme_Id