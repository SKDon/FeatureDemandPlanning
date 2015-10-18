CREATE VIew [OXO_Rule_Feature_VW]
 AS
 SELECT 
    V.Make AS VehicleMake,
    V.Name AS VehicleName,
    V.AKA AS VehicleAKA,
    P.Id AS Programme_Id,
    P.Model_Year AS ModelYear,
    R.Id AS RuleId,
    R.Rule_Response AS RuleResponse,
    R.Rule_Reason AS RuleReason,
    R.Approved AS RuleApproved,
    R.Rule_Category AS RuleCategory,
    R.Active AS RuleActive,
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
    F.Last_Updated  AS LastUpdated      
    FROM dbo.OXO_Vehicle V
    INNER JOIN dbo.OXO_Programme P
    ON V.Id = P.Vehicle_Id
    INNER JOIN dbo.OXO_Programme_Rule R
    ON P.ID = R.Programme_Id
    INNER JOIN dbo.OXO_Rule_Feature_Link L
    ON R.Id = L.Rule_Id
    AND L.Programme_Id = P.Id    
    INNER JOIN dbo.OXO_Feature_Ext F
    ON L.Feature_Id = F.Id
	LEFT JOIN dbo.OXO_Feature_Brand_Desc M
	ON M.Feat_Code = F.FEat_Code
	AND M.Brand =  V.Make

