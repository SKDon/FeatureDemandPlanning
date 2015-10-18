
CREATE PROCEDURE [dbo].[OXO_Permission_Edit] 
   @p_Id INT
  ,@p_CDSID  nvarchar(50) 
  ,@p_Object_Type  nvarchar(500) 
  ,@p_Object_Id  int 
  ,@p_Object_Val  nvarchar(500) 
  ,@p_Operation  nvarchar(500) 
  ,@p_Created_By  nvarchar(50) 
  ,@p_Created_On  datetime 
  ,@p_Updated_By  nvarchar(50) 
  ,@p_Last_Updated  datetime 
      
AS
	
  UPDATE dbo.OXO_Permission 
    SET 
  CDSID=@p_CDSID,  
  Object_Type=@p_Object_Type,  
  [Object_Id]=@p_Object_Id,  
  Object_Val=@p_Object_Val,  
  Operation=@p_Operation,  
  Created_By=@p_Created_By,  
  Created_On=@p_Created_On,  
  Updated_By=@p_Updated_By,  
  Last_Updated=@p_Last_Updated  
  	     
   WHERE Id = @p_Id;

