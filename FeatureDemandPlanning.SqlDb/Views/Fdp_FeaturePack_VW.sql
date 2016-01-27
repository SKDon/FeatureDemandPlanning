
CREATE VIEW [dbo].[Fdp_FeaturePack_VW] AS

	SELECT 
		  D.FdpVolumeHeaderId
		, D.MarketId
		, D.ModelId
		, D.FeaturePackId
		, P.Pack_Name AS FeaturePack
		, D.Volume
		, D.PercentageTakeRate
	FROM Fdp_VolumeDataItem_VW AS D
	JOIN Fdp_VolumeHeader AS H ON D.FdpVolumeHeaderId = H.FdpVolumeHeaderId
	JOIN OXO_Doc AS O ON H.DocumentId = O.Id
	JOIN OXO_Programme_Pack AS P ON D.FeaturePackId = P.Id
								 AND O.Programme_Id = P.Programme_Id
	WHERE
	FeatureId IS NULL
	AND
	FeaturePackId IS NOT NULL