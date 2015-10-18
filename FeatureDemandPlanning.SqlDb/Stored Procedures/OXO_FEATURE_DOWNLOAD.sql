CREATE PROCEDURE [dbo].[OXO_FEATURE_DOWNLOAD]
AS
SELECT ISNULL(G.Group_Name, 'Unknown') AS OXO_GROUP, G.Sub_Group_Name AS OXO_SUB_GROUP, 
       F.Id, F.Feat_Code, F.OA_Code, F.Description , ISNULL(JB.Brand_Desc, '') AS J_Desc, ISNULL(LB.Brand_Desc, '') AS LB_Desc, dbo.FN_OXO_FEAT_APPLICABILITY(F.Id)
FROM OXO_Feature_Ext F
LEFT OUTER JOIN OXO_Feature_Brand_Desc JB
ON F.Feat_Code = JB.Feat_Code
AND JB.Brand = 'Jaguar'
LEFT OUTER JOIN OXO_Feature_Brand_Desc LB
ON F.Feat_Code = LB.Feat_Code
AND LB.Brand = 'Land Rover'
LEFT JOIN OXO_Feature_Group G
ON F.OXO_Grp = G.Id
ORDER BY ISNULL(G.Group_Name, 'Unknown'), F.Feat_Code