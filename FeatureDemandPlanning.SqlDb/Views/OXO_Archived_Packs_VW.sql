CREATE VIew [dbo].[OXO_Archived_Packs_VW]
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
    F.Id AS Id,
    F.Description  AS SystemDescription,  
    ISNULL(M.Brand_Desc, F.Description) AS BrandDescription,
    CASE 
	WHEN ISNULL(P.Use_OA_Code, 0) = 0 THEN F.Feat_Code 
	ELSE F.OA_Code END AS FeatureCode,     	
    F.OA_Code AS OACode,
    F.Created_By  AS CreatedBy,  
    F.Created_On  AS CreatedOn,  
    F.Updated_By  AS UpdatedBy,  
    F.Last_Updated  AS LastUpdated,
    K.Doc_Id      
    FROM dbo.OXO_Vehicle V
    INNER JOIN dbo.OXO_Programme P
    ON V.Id = P.Vehicle_Id
    INNER JOIN dbo.OXO_Archived_Programme_Pack K
    ON P.ID = K.Programme_Id
    LEFT OUTER JOIN dbo.OXO_Archived_Pack_Feature_Link L
    ON K.Id = L.Pack_Id
    AND L.Programme_Id = P.Id
    AND K.Doc_Id = L.Doc_Id    
    LEFT OUTER JOIN dbo.OXO_Feature_Ext F
    ON L.Feature_Id = F.Id
	LEFT JOIN dbo.OXO_Feature_Brand_Desc M
	ON M.Feat_Code = F.Feat_Code
	AND M.Brand =  V.Make

