
CREATE PROCEDURE [dbo].[OXO_Vehicle_Edit] 
   @p_Id INT
  ,@p_Name  nvarchar(500) 
  ,@p_AKA  nvarchar(500) 
  ,@p_Make  nvarchar(500) 
  ,@p_Active  bit 
  ,@p_Created_By  nvarchar(8) 
  ,@p_Created_On  datetime 
  ,@p_Updated_By  nvarchar(8) 
  ,@p_Last_Updated  datetime 
      
AS
	
  UPDATE dbo.OXO_Vehicle 
    SET 
  Name=@p_Name,  
  AKA=@p_AKA,  
  Make=@p_Make,  
  Active=@p_Active,  
  Created_By=@p_Created_By,  
  Created_On=@p_Created_On,  
  Updated_By=@p_Updated_By,  
  Last_Updated=@p_Last_Updated  
  	     
   WHERE Id = @p_Id;

