

CREATE VIEW [dbo].[Fdp_Feature_VW]
AS

WITH Packs AS
(
	SELECT ProgrammeId, FeatureCode, MAX(PackId) AS PackId
	FROM
	OXO_Pack_Feature_VW
	WHERE
	FeatureCode IS NOT NULL
	GROUP BY
	ProgrammeId, FeatureCode
)
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
	, P1.PackId				AS FeaturePackId
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
LEFT JOIN Packs					AS P1	ON	F.ProgrammeId	= P1.ProgrammeId
										AND F.FeatureCode	= P1.FeatureCode
LEFT JOIN OXO_Pack_Feature_VW	AS P	ON	P1.PackId		= P.PackId


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

UNION

SELECT 
	  CAST(NULL AS INT)		AS FeatureId 
	, P.Created_On			AS CreatedOn
	, P.Created_By			AS CreatedBy
	, CAST(NULL AS INT)		AS FdpFeatureId
	, P1.VehicleName		AS Name
	, P1.VehicleAKA			AS AKA
	, P1.ModelYear
	, P1.Id					AS ProgrammeId
	, G.Gateway
	, P1.VehicleMake		AS Make
	, P.Feature_Code		AS FeatureCode
	, P.Feature_Code		AS OACode
	, P.Pack_Name			AS SystemDescription
	, P.Pack_Name			AS BrandDescription
	, CAST(NULL AS INT)		AS FeatureGroupId
	, 'OPTION PACKS'		AS FeatureGroup
	, NULL					AS FeatureSubGroup
	, P.Id					AS FeaturePackId
	, P.Pack_Name			AS FeaturePackName
	, P.Feature_Code		AS FeaturePackCode
	, RANK() OVER(PARTITION BY P1.Id, G.Gateway ORDER BY P.Pack_Name) 
							AS DisplayOrder
	, P.Extra_Info			AS FeatureComment
	, P.Rule_Text			AS FeatureRuleText
	, ''					AS LongDescription
	, 'Unknown'				AS EFGName
	, CAST(0 AS BIT)		AS IsFdpFeature
	, P.Last_Updated		AS UpdatedOn			
	, P.Updated_By			AS UpdatedBy
FROM OXO_Programme_Pack AS P
JOIN Fdp_Gateways_VW	AS G	ON P.Programme_Id	= G.ProgrammeId
JOIN OXO_Programme_VW	AS P1	ON P.Programme_Id	= P1.Id