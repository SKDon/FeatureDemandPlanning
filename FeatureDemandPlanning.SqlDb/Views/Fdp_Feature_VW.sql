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
	  ROW_NUMBER() OVER (ORDER BY (SELECT NULL)) AS Id
	, F.FeatureId
	, F.CreatedOn
	, F.CreatedBy
	, F.FdpFeatureId
	, F.Name
	, F.AKA
	, F.ModelYear
	, F.DocumentId
	, F.ProgrammeId
	, F.Gateway
	, F.Make
	, F.FeatureCode
	, F.OACode
	, F.SystemDescription
	, F.BrandDescription
	, F.FeatureGroupId
	, F.FeatureGroup
	, F.FeatureSubGroup
	, F.FeaturePackId
	, F.FeaturePackName
	, F.FeaturePackCode
	, F.DisplayOrder
	, F.FeatureComment
	, F.FeatureRuleText
	, F.LongDescription
	, F.EFGName
	, F.IsFdpFeature
	, F.UpdatedOn
	, F.UpdatedBy
	, F.ExclusiveFeatureGroup
	, F.IsActive
FROM
(
SELECT
	  F.ID					AS FeatureId
	, ISNULL(LR.Created_On, J.Created_On)	AS CreatedOn
	, ISNULL(LR.Created_By, J.Created_By)	AS CreatedBy
	, CAST(NULL AS INT)		AS FdpFeatureId
	, F.Name 
	, F.AKA
	, F.ModelYear
	, O.Id AS DocumentId
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
	, ISNULL(LR.Last_Updated, J.Last_Updated)		AS UpdatedOn
	, ISNULL(LR.Updated_By, J.Last_Updated)			AS UpdatedBy
	, F.EFGName				AS ExclusiveFeatureGroup
	, CAST(CASE WHEN ISNULL(F.[Status], '') = 'REMOVED' THEN 0 ELSE 1 END AS BIT) AS IsActive
	
FROM 
OXO_Doc							AS O
JOIN OXO_Programme_Feature_VW	AS F	ON O.Programme_Id	= F.ProgrammeId  
LEFT JOIN OXO_Feature_Ext		AS LR	WITH (INDEX(Ix_NC_OXO_Feature_Ext_Cover)) ON F.FeatureCode	= LR.Feat_Code
LEFT JOIN OXO_Feature_Ext		AS J	WITH (INDEX(Ix_NC_OXO_Feature_Ext_Cover)) ON F.FeatureCode	= J.OA_Code
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
										AND O.Programme_Id	= P.ProgrammeId
										AND P1.FeatureCode	= P.FeatureCode

UNION ALL

-- Feature Packs

SELECT 
	  CAST(NULL AS INT)		AS FeatureId 
	, P.Created_On			AS CreatedOn
	, P.Created_By			AS CreatedBy
	, CAST(NULL AS INT)		AS FdpFeatureId
	, P1.VehicleName		AS Name
	, P1.VehicleAKA			AS AKA
	, P1.ModelYear
	, O.Id					AS DocumentId
	, P1.Id					AS ProgrammeId
	, O.Gateway
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
	, RANK() OVER(PARTITION BY P1.Id, O.Gateway ORDER BY P.Pack_Name) 
							AS DisplayOrder
	, P.Extra_Info			AS FeatureComment
	, P.Rule_Text			AS FeatureRuleText
	, ''					AS LongDescription
	, 'Unknown'				AS EFGName
	, CAST(0 AS BIT)		AS IsFdpFeature
	, P.Last_Updated		AS UpdatedOn			
	, P.Updated_By			AS UpdatedBy
	, CAST(NULL AS NVARCHAR(100)) AS ExclusiveFeatureGroup
	, CAST(1 AS BIT)		AS IsActive
	
FROM 
OXO_Doc					AS O
JOIN OXO_Programme_VW	AS P1	ON O.Programme_Id	= P1.Id
JOIN OXO_Programme_Pack AS P	ON P1.Id			= P.Programme_Id
)
AS F