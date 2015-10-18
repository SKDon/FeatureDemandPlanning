
CREATE PROCEDURE [dbo].[OXO_Programme_Edit] 
   @p_Id INT
  ,@p_Model_Year  varchar(500) 
  ,@p_Notes  varchar(2000) 
  ,@p_Product_Manager  varchar(8) 
  ,@p_RSG_UID  varchar(500) 
  ,@p_Active  bit 
  ,@p_OXO_Enabled bit
  ,@p_Created_By  varchar(8) 
  ,@p_Created_On  datetime 
  ,@p_Updated_By  varchar(8) 
  ,@p_Last_Updated  datetime 
      
AS
	
  UPDATE dbo.OXO_Programme 
    SET 
  Model_Year=@p_Model_Year,  
  Notes=@p_Notes,  
  Product_Manager=@p_Product_Manager,  
  RSG_UID=@p_RSG_UID,  
  Active=@p_Active,  
  OXO_Enabled = @p_OXO_Enabled,
  Created_By=@p_Created_By,  
  Created_On=@p_Created_On,  
  Updated_By=@p_Updated_By,  
  Last_Updated=@p_Last_Updated  
  	     
   WHERE Id = @p_Id;

