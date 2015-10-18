CREATE PROCEDURE [dbo].[OXO_Feature_GetMany]
   @p_vehicle_id INT,
   @p_lookup    NVARCHAR(50)
AS

   IF @p_lookup = '@@@'
	   SET @p_lookup = NULL; 
		
   SELECT 
    F.Id  AS Id,
    F.Description  AS SystemDescription,  
    ISNULL(M.Brand_Desc, F.Description) AS BrandDescription, 
	F.Feat_Code AS FeatureCode,
	F.OA_Code AS OACode,
    G.Group_Name  AS FeatureGroup,  
    G.Sub_Group_Name  AS FeatureSubGroup,    
    G.Display_Order AS GroupOrder,
    F.Created_By  AS CreatedBy,  
    F.Created_On  AS CreatedOn,  
    F.Updated_By  AS UpdatedBy,  
    F.Last_Updated  AS LastUpdated  
    FROM dbo.OXO_Vehicle V
    INNER JOIN dbo.OXO_Vehicle_Feature_Applicability L
    ON V.Id = L.Vehicle_Id
    INNER JOIN dbo.OXO_Feature_Ext F
    ON L.Feature_Id = F.Id
	INNER JOIN OXO_Feature_Group G
	ON F.OXO_Grp = G.ID
	LEFT JOIN dbo.OXO_Feature_Brand_Desc M
	ON M.Feat_Code = F.Feat_Code
	AND M.Brand =  V.Make
	WHERE V.Id = @p_vehicle_id
	AND (
		(@p_lookup IS NULL OR F.Feat_Code LIKE '%' + @p_lookup + '%' OR F.OA_Code LIKE '%' + @p_lookup + '%')
	OR                             
		(@p_lookup IS NULL OR F.Description LIKE '%' + @p_lookup + '%')
    )       
	ORDER BY G.Display_Order;

