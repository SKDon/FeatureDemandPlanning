
CREATE PROCEDURE [dbo].[OXO_Feature_Edit] 
   @p_Id INT
  ,@p_Description  varchar(500) 
  ,@p_Notes  varchar(2000) 
  ,@p_PROFEAT  varchar(500) 
  ,@p_Active  bit 
  ,@p_Feature_Group  varchar(500)
  ,@p_Make varchar(500) 
  ,@p_Car_Lines  varchar(500) 
  ,@p_Created_By  varchar(8) 
  ,@p_Created_On  datetime 
  ,@p_Updated_By  varchar(8) 
  ,@p_Last_Updated  datetime 
      
AS

	
  UPDATE dbo.OXO_Feature_Ext
    SET 
  Description=@p_Description,  
  --Notes=@p_Notes,  
  OA_Code=@p_PROFEAT,  
  --Active=@p_Active,  
  --Feature_Group=@p_Feature_Group,  
  --Make = @p_Make,
  --Car_Lines=@p_Car_Lines,  
  Created_By=@p_Created_By,  
  Created_On=@p_Created_On,  
  Updated_By=@p_Updated_By,  
  Last_Updated=@p_Last_Updated  
  	     
   WHERE Id = @p_Id;