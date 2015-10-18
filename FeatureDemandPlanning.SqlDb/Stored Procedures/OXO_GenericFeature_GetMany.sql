

CREATE PROCEDURE [dbo].[OXO_GenericFeature_GetMany]
   @p_lookup NVARCHAR(50)
AS

   IF @p_lookup = '@@@'
	   SET @p_lookup = NULL; 
		
   SELECT 
    F.Id  AS Id,
    F.Description  AS SystemDescription,    
    F.feat_code AS FeatureCode,
    F.OA_Code AS OACode,
    G.Group_Name  AS FeatureGroup,    
    F.Created_By  AS CreatedBy,  
    F.Created_On  AS CreatedOn,  
    F.Updated_By  AS UpdatedBy,  
    F.Last_Updated  AS LastUpdated  
    FROM dbo.OXO_Feature_Ext F
    INNER JOIN dbo.OXO_feature_Group G
    ON F.OXO_Grp = G.ID
    WHERE 
    (
		(@p_lookup IS NULL OR F.Feat_Code LIKE '%' + @p_lookup + '%' OR F.OA_Code LIKE '%' + @p_lookup + '%')
	OR                             
		(@p_lookup IS NULL OR F.Description LIKE '%' + @p_lookup + '%')
    )       
    Order by FeatureCode

