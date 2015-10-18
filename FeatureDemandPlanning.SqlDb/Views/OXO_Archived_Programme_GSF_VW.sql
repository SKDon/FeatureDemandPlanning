CREATE VIEW [OXO_Archived_Programme_GSF_VW]
AS

SELECT     
   F.Id AS Id, 
   V.Name AS Name, 
   V.AKA AS AKA, 
   P.Model_Year AS ModelYear, 
   P.Id AS ProgrammeId, 
   V.Make, 
   CASE 
	WHEN ISNULL(P.Use_OA_Code, 0) = 0 THEN F.Feat_Code 
	ELSE F.OA_Code END AS FeatureCode, 
   F.OA_Code AS OACode, 
   F.Description AS SystemDescription, 
   ISNULL(M.Brand_Desc, F.Description) AS BrandDescription, 
   G.Group_Name AS FeatureGroup, 
   G.Sub_Group_Name AS FeatureSubGroup, 
   G.Display_Order AS DisplayOrder, 
   L.Comment AS FeatureComment,
   L.Rule_Text AS FeatureRuleText,
   F.Long_Desc AS LongDescription,
   L.Doc_Id AS Doc_Id,
   ISNULL(E.EFG_Desc, 'Unknown') AS EFGName
   
   FROM dbo.OXO_Vehicle AS V 
   INNER JOIN dbo.OXO_Programme AS P 
   ON V.Id = P.Vehicle_Id 
   INNER JOIN dbo.OXO_Archived_Programme_GSF_Link  AS L    
   ON P.Id = L.Programme_Id 
   INNER JOIN dbo.OXO_Feature_Ext AS F 
   ON L.Feature_Id = F.Id 
   INNER JOIN dbo.OXO_Feature_Group AS G 
   ON F.OXO_Grp = G.Id 
   LEFT OUTER JOIN dbo.OXO_Feature_Brand_Desc AS M 
   ON F.Feat_Code = M.Feat_Code 
   AND M.Brand = V.Make
   LEFT OUTER JOIN dbo.OXO_Exclusive_Feature_Group E
   ON E.EFG_Code =  F.Feat_EFG





