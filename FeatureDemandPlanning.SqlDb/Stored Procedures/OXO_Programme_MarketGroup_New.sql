CREATE  PROCEDURE [OXO_Programme_MarketGroup_New] 
   @p_prog_id INT, 
   @p_Group_Name  varchar(500), 
   @p_Extra_Info  varchar(500), 
   @p_Active  bit, 
   @p_Created_By  varchar(8), 
   @p_Created_On  datetime, 
   @p_Updated_By  varchar(8), 
   @p_Last_Updated  datetime, 
  @p_Id INT OUTPUT
AS
	
  INSERT INTO dbo.OXO_Programme_MarketGroup
  (
    Programme_Id,
    Group_Name,  
    Extra_Info,  
    Active,  
    Created_By,  
    Created_On,  
    Updated_By,  
    Last_Updated  
          
  )
  VALUES 
  (
    @p_prog_id,
    @p_Group_Name,  
    @p_Extra_Info,   
    @p_Active,  
    @p_Created_By,  
    @p_Created_On,  
    @p_Updated_By,  
    @p_Last_Updated  
      );

  SET @p_Id = SCOPE_IDENTITY();

