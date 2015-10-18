CREATE  PROCEDURE [dbo].[OXO_Master_MarketGroup_New] 
   @p_Group_Name  varchar(500), 
   @p_Active  bit,
   @p_Display_Order int, 
   @p_Created_By  varchar(8), 
   @p_Created_On  datetime, 
   @p_Updated_By  varchar(8), 
   @p_Last_Updated  datetime, 
  @p_Id INT OUTPUT
AS
	
  INSERT INTO dbo.OXO_Master_MarketGroup
  (
    Group_Name,  
    Active,
    Display_Order,
    Created_By,  
    Created_On,  
    Updated_By,  
    Last_Updated  
          
  )
  VALUES 
  (
    @p_Group_Name, 
    @p_Active,  
    @p_Display_Order,
    @p_Created_By,  
    @p_Created_On,  
    @p_Updated_By,  
    @p_Last_Updated  
   );

  SET @p_Id = SCOPE_IDENTITY();

