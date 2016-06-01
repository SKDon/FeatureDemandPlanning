CREATE VIEW Fdp_FeatureMix_VW AS

SELECT
  H.FdpVolumeHeaderId AS [Take Rate Id]
, MK.[Market_Id] AS [Market Id] 
, MK.Market_Name AS Market
, F.FeatureCode AS [Feature Code]
, ISNULL(F.BrandDescription, F.SystemDescription) AS [Feature Description]
, M.PercentageTakeRate AS [% Take Rate]
, M.Volume
FROM
Fdp_VolumeHeader_VW AS H
JOIN OXO_Programme_MarketGroupMarket_VW AS MK ON H.ProgrammeId = MK.Programme_Id
JOIN Fdp_Feature_VW AS F ON H.DocumentId = F.DocumentId
JOIN Fdp_TakeRateFeatureMix AS M ON H.FdpVolumeHeaderId = M.FdpVolumeHeaderId
									AND MK.Market_Id = M.MarketId
									AND F.FeatureId = M.FeatureId
UNION

SELECT
  H.FdpVolumeHeaderId AS [Take Rate Id]
, MK.[Market_Id] AS [Market Id]  
, MK.Market_Name AS Market
, F.FeatureCode AS [Feature Code]
, ISNULL(F.BrandDescription, F.SystemDescription) AS [Feature Description]
, M.PercentageTakeRate AS [% Take Rate]
, M.Volume
FROM
Fdp_VolumeHeader_VW AS H
JOIN OXO_Programme_MarketGroupMarket_VW AS MK ON H.ProgrammeId = MK.Programme_Id
JOIN Fdp_Feature_VW AS F ON H.DocumentId = F.DocumentId
JOIN Fdp_TakeRateFeatureMix AS M ON H.FdpVolumeHeaderId = M.FdpVolumeHeaderId
									AND MK.Market_Id = M.MarketId
									AND F.FeatureId IS NULL
									AND F.FeaturePackId = M.FeaturePackId