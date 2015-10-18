CREATE PROCEDURE [dbo].[OXO_Feature_New] 
   @p_Description  varchar(500), 
   @p_Notes  varchar(2000), 
   @p_PROFEAT  varchar(500), 
   @p_Active  bit, 
   @p_Feature_Group  varchar(500), 
   @p_Feature_Sub_Group  varchar(500), 
   @p_Make  varchar(500),    
   @p_Car_Lines  varchar(500), 
   @p_Created_By  varchar(8), 
   @p_Created_On  datetime, 
   @p_Updated_By  varchar(8), 
   @p_Last_Updated  datetime, 
  @p_Id INT OUTPUT
AS
	
  INSERT INTO dbo.OXO_Feature_Ext
  (
    Description,  
  --  Notes,  
  --  PROFET_JAG,  
  --  Active,  
  --  Feature_Group,  
  --  Feature_Sub_Group,
    Created_By,  
    Created_On,  
    Updated_By,  
    Last_Updated  
          
  )
  VALUES 
  (
    @p_Description,  
  --  @p_Notes,  
  --  @p_PROFEAT,  
  --  @p_Active,  
  --  @p_Feature_Group,  
   -- @p_feature_Sub_Group,
    @p_Created_By,  
    @p_Created_On,  
    @p_Updated_By,  
    @p_Last_Updated  
      );

  SET @p_Id = SCOPE_IDENTITY();

