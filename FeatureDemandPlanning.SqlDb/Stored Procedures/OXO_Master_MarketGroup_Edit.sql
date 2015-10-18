CREATE PROCEDURE [dbo].[OXO_Master_MarketGroup_Edit] 
   @p_Id INT OUTPUT
  ,@p_Group_Name  varchar(500) 
  ,@p_Active  bit
  ,@p_Display_Order int
  ,@p_Created_By  varchar(8) 
  ,@p_Created_On  datetime 
  ,@p_Updated_By  varchar(8) 
  ,@p_Last_Updated  datetime 
      
AS
	
  UPDATE dbo.OXO_Master_MarketGroup 
    SET 
  Group_Name=@p_Group_Name,
  Active=@p_Active,  
  Display_Order=@p_Display_Order,
  Updated_By=@p_Updated_By,  
  Last_Updated=@p_Last_Updated  
  	     
   WHERE Id = @p_Id;

