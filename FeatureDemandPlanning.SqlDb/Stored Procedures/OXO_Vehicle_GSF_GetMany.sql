

CREATE PROCEDURE [dbo].[OXO_Vehicle_GSF_GetMany]
   @p_vehicle_id INT,
   @p_lookup   NVARCHAR(50) = NULL,
   @p_group    NVARCHAR(500) = NULL,
   @p_exclude_progid INT = 0,
   @p_exclude_docid INT = 0,
   @p_use_OA_code BIT = 0
AS

   IF @p_lookup = '@@@'
	  SET @p_lookup = NULL; 
	
   IF @p_group = 'All'
	  SET @p_group = NULL;  		
		
    WITH SET_A
    AS
    (				
		SELECT 
		F.Id  AS Id,
		F.Description  AS SystemDescription,  
		ISNULL(M.Brand_Desc, F.Description) AS BrandDescription,
		CASE WHEN ISNULL(@p_use_OA_code,0) = 0 THEN F.Feat_Code
		    ELSE F.OA_Code END AS FeatureCode, 		
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
		ON L.Feature_Id = F.Id
		LEFT JOIN OXO_Feature_Group G
		ON F.OXO_GRP = G.ID
		LEFT JOIN dbo.OXO_Feature_Brand_Desc M
		ON M.Feat_Code = F.Feat_Code
		AND M.Brand =  V.Make
		WHERE V.Id = @p_vehicle_id
		AND G.Status = 1
		AND (
			(@p_lookup IS NULL OR F.Feat_Code LIKE '%' + @p_lookup + '%' OR F.OA_Code LIKE '%' + @p_lookup + '%')
		OR                             
			(@p_lookup IS NULL OR F.Description LIKE '%' + @p_lookup + '%')
		)   
		AND (
			@p_group IS NULL OR G.Group_Name = @p_group
		)    
	), SET_B 
	AS
	(	
	   SELECT DISTINCT Id AS Id
       FROM dbo.FN_Programme_GSF_Get(@p_exclude_progid, @p_exclude_docid)                         
	)
	SELECT * FROM SET_A A 
	WHERE NOT EXISTS
	(SELECT 1 FROM SET_B WHERE ID = A.ID)	
  	ORDER BY A.GroupOrder, A.FeatureSubGroup, A.FeatureCode;

