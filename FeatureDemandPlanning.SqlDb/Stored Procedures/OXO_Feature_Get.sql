CREATE PROCEDURE [dbo].[OXO_Feature_Get] 
  @p_Id int
AS
	
	SELECT 
      F.Id  AS Id,
      F.Description  AS Description,  
	  F.Feat_Code AS FeatureCode,
	  F.OA_Code AS OACode,	 
      F.FEAT_EFG AS FEATEFG,
      G.Group_Name  AS FeatureGroup,  
      G.Sub_Group_Name  AS FeatureSubGroup,  
      F.Created_By  AS CreatedBy,  
      F.Created_On  AS CreatedOn,  
      F.Updated_By  AS UpdatedBy,  
      F.Last_Updated  AS LastUpdated        	     
    FROM dbo.OXO_Feature_Ext F
    INNER JOIN dbo.OXO_Feature_Group G 
    ON F.OXO_Grp = G.Id
	WHERE F.Id = @p_Id;

