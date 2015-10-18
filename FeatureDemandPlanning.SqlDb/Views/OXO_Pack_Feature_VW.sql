CREATE VIew [OXO_Pack_Feature_VW]
 AS
 SELECT 
    V.Make AS VehicleMake,
    V.Name AS VehicleName,
    V.AKA AS VehicleAKA,
    P.Id AS ProgrammeId,
    P.Model_Year AS ModelYear,
    K.Id AS PackId,
    K.Pack_Name AS PackName,    
    K.Extra_Info As ExtraInfo,
    K.Feature_Code AS PackFeatureCode,
    ISNULL(F.Id, -1000) AS Id,
    CASE WHEN F.ID IS NULL THEN 'No Feature Selected' 
    ELSE F.Description END  AS SystemDescription,  
    CASE WHEN F.ID IS NULL THEN 'No Feature Selected' 
    ELSE ISNULL(M.Brand_Desc, F.Description) END AS BrandDescription,
    CASE WHEN ISNULL(P.Use_OA_Code, 0) = 0 THEN F.Feat_Code 
	ELSE F.OA_Code END AS FeatureCode,         
    F.OA_Code AS OACode,
    L.Comment AS FeatureComment,
    L.Rule_Text AS FeatureRuleText,
    F.Long_Desc AS LongDescription,
    F.Created_By  AS CreatedBy,  
    F.Created_On  AS CreatedOn,  
    F.Updated_By  AS UpdatedBy,  
    F.Last_Updated  AS LastUpdated  
    
    FROM dbo.OXO_Vehicle V
    INNER JOIN dbo.OXO_Programme P
    ON V.Id = P.Vehicle_Id
    INNER JOIN dbo.OXO_Programme_Pack K
    ON P.ID = K.Programme_Id
    LEFT OUTER JOIN dbo.OXO_Pack_Feature_Link L
    ON K.Id = L.Pack_Id
    AND L.Programme_Id = P.Id    
    LEFT OUTER JOIN dbo.OXO_Feature_Ext F
    ON L.Feature_Id = F.Id
	LEFT JOIN dbo.OXO_Feature_Brand_Desc M
	ON M.Feat_Code = F.Feat_Code
	AND M.Brand =  V.Make

