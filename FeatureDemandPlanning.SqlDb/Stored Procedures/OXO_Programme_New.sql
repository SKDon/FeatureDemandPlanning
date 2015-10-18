
CREATE  PROCEDURE [dbo].[OXO_Programme_New] 
   @p_Model_Year  varchar(500), 
   @p_Notes  varchar(2000), 
   @p_Product_Manager  varchar(8), 
   @p_RSG_UID  varchar(500), 
   @p_Active  bit, 
   @p_OXO_Enabled bit,
   @p_Created_By  varchar(8), 
   @p_Created_On  datetime, 
   @p_Updated_By  varchar(8), 
   @p_Last_Updated  datetime, 
  @p_Id INT OUTPUT
AS
	
  INSERT INTO dbo.OXO_Programme
  (
    Model_Year,
    Notes,  
    Product_Manager,  
    RSG_UID,  
    Active,  
    OXO_Enabled,
    Created_By,  
    Created_On,  
    Updated_By,  
    Last_Updated  
          
  )
  VALUES 
  (
    @p_Model_Year,  
    @p_Notes,  
    @p_Product_Manager,  
    @p_RSG_UID,  
    @p_Active,  
    @p_OXO_Enabled,
    @p_Created_By,  
    @p_Created_On,  
    @p_Updated_By,  
    @p_Last_Updated  
      );

  SET @p_Id = SCOPE_IDENTITY();


