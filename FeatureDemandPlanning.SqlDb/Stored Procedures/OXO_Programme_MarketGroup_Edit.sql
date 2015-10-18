CREATE PROCEDURE [OXO_Programme_MarketGroup_Edit] 
   @p_Id INT
  ,@p_prog_id INT 
  ,@p_Group_Name  varchar(500) 
  ,@p_Extra_Info  varchar(500) 
  ,@p_Active  bit 
  ,@p_Created_By  varchar(8) 
  ,@p_Created_On  datetime 
  ,@p_Updated_By  varchar(8) 
  ,@p_Last_Updated  datetime 
      
AS
	
  UPDATE dbo.OXO_Programme_MarketGroup 
    SET 
  Group_Name=@p_Group_Name,  
  Extra_Info=@p_Extra_Info,  
  Active=@p_Active,  
  Created_By=@p_Created_By,  
  Created_On=@p_Created_On,  
  Updated_By=@p_Updated_By,  
  Last_Updated=@p_Last_Updated    	     
   WHERE Id = @p_Id;

