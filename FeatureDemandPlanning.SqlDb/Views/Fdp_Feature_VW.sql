CREATE VIEW Fdp_Feature_VW
AS

SELECT 
	  F.ID
	, CAST(NULL AS INT) AS FdpFeatureId
	, F.Name 
	, F.AKA
	, F.ModelYear
	, F.ProgrammeId
	, G.Gateway
	, F.Make
	, F.FeatureCode
	, F.OACode
	, F.SystemDescription
	, F.BrandDescription
	, F.FeatureGroup
	, F.FeatureSubGroup
	, F.DisplayOrder
	, F.FeatureComment
	, F.FeatureRuleText
	, F.LongDescription
	, F.EFGName
	, CAST(0 AS BIT) AS IsFdpFeature
	
FROM OXO_Programme_Feature_VW	AS F
JOIN Fdp_Gateways_VW			AS G ON F.ProgrammeId = G.ProgrammeId

UNION

SELECT
	  CAST(NULL AS INT) AS Id 
	, F.FdpFeatureId
	, P.VehicleName			AS Name
	, P.VehicleAKA			AS AKA
	, P.ModelYear
	, F.ProgrammeId
	, F.Gateway
	, P.VehicleMake			AS Make
	, F.FeatureCode
	, F.FeatureCode			AS OACode
	, F.FeatureDescription	AS SystemDescription
	, F.FeatureDescription	AS BrandDescription
	, G.Group_Name			AS FeatureGroup
	, G.Sub_Group_Name		AS FeatureSubGroup
	, 0						AS DisplayOrder
	, NULL					AS FeatureComment
	, NULL					AS FeatureRuleText
	, F.FeatureDescription	AS LongDescription
	, 'Unknown'				AS EFGName
	, CAST(1 AS BIT)		AS IsFdpFeature
						
FROM Fdp_Feature			AS F 
JOIN OXO_Programme_VW		AS P ON F.ProgrammeId		= P.Id
LEFT JOIN OXO_Feature_Group AS G ON F.FeatureGroupId	= G.Id
WHERE
F.IsActive = 1