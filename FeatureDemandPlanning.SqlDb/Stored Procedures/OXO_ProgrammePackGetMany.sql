CREATE PROCEDURE [dbo].[OXO_ProgrammePackGetMany]
	@p_prog_Id INT,
	@p_doc_Id INT,
	@p_use_OA_code bit = 0,
	@p_new_only bit	 
AS
	
SELECT 
	F.Id  AS Id,
	F.Description  AS SystemDescription,  
	ISNULL(M.Brand_Desc, F.Description) AS BrandDescription,
	CASE WHEN ISNULL(@p_use_OA_code, 0) = 0 THEN F.Feat_Code
	ELSE F.OA_Code END  AS FeatureCode,
	F.OA_Code AS OACode,   
	G.Group_Name  AS FeatureGroup,    
	G.Display_Order AS GroupOrder,
	G.Sub_Group_Name AS FeatureSubGroup,
	F.Created_By  AS CreatedBy,  
	F.Created_On  AS CreatedOn,  
	F.Updated_By  AS UpdatedBy,  
	F.Last_Updated  AS LastUpdated  
	FROM dbo.OXO_Vehicle V
	INNER JOIN dbo.OXO_Vehicle_Feature_Applicability L
	ON V.Id = L.Vehicle_Id
	INNER JOIN dbo.OXO_Feature_Ext F
	ON L.Feature_ID = F.ID
	INNER JOIN OXO_Feature_Group G
	ON F.OXO_Grp = G.ID
	AND G.Status = 1
	LEFT JOIN dbo.OXO_Feature_Brand_Desc M
	ON M.Feat_Code = F.Feat_Code
	AND M.Brand =  V.Make
	WHERE V.Id = 4
	
