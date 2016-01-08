


CREATE VIEW [dbo].[Fdp_Feature_VW]
AS

SELECT 
	  F.ID					AS FeatureId
	, E.Created_On			AS CreatedOn
	, E.Created_By			AS CreatedBy
	, CAST(NULL AS INT)		AS FdpFeatureId
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
	, GR.Id					AS FeatureGroupId
	, F.FeatureGroup
	, F.FeatureSubGroup
	, P.PackId				AS FeaturePackId
	, P.PackName			AS FeaturePackName
	, P.PackFeatureCode		AS FeaturePackCode
	, F.DisplayOrder
	, ISNULL(F.FeatureComment, '') AS FeatureComment
	, ISNULL(F.FeatureRuleText, '') AS FeatureRuleText
	, ISNULL(F.LongDescription, '') AS LongDescription
	, F.EFGName
	, CAST(0 AS BIT)		AS IsFdpFeature
	, E.Last_Updated		AS UpdatedOn
	, E.Updated_By			AS UpdatedBy
	
FROM OXO_Programme_Feature_VW	AS F 
JOIN OXO_Feature_Ext			AS E	ON F.FeatureCode	= E.Feat_Code
JOIN Fdp_Gateways_VW			AS G	ON F.ProgrammeId	= G.ProgrammeId
LEFT JOIN OXO_Feature_Group		AS GR	ON F.FeatureGroup	= GR.Group_Name
										AND 
										(
											F.FeatureSubGroup = GR.Sub_Group_Name
											OR
											F.FeatureSubGroup IS NULL
										)
LEFT JOIN OXO_Pack_Feature_VW	AS P	ON F.ProgrammeId	= P.ProgrammeId
										AND F.FeatureCode	= P.FeatureCode

UNION

SELECT
	  CAST(NULL AS INT) AS FeatureId 
	, F.CreatedOn
	, F.CreatedBy
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
	, G.Id					AS FeatureGroupId
	, G.Group_Name			AS FeatureGroup
	, G.Sub_Group_Name		AS FeatureSubGroup
	, NULL					AS FeaturePackId
	, NULL					AS FeaturePackName
	, NULL					AS FeaturePackCode
	, G.Display_Order		AS DisplayOrder
	, '' AS FeatureComment
	, '' AS FeatureRuleText
	, ISNULL(F.FeatureDescription, '') AS LongDescription
	, 'Unknown'				AS EFGName
	, CAST(1 AS BIT)		AS IsFdpFeature
	, F.UpdatedOn
	, F.UpdatedBy
						
FROM Fdp_Feature			AS F 
JOIN OXO_Programme_VW		AS P ON F.ProgrammeId		= P.Id
LEFT JOIN OXO_Feature_Group AS G ON F.FeatureGroupId	= G.Id
WHERE
F.IsActive = 1