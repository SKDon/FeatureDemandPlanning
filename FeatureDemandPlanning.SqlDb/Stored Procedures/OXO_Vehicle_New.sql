
CREATE  PROCEDURE [dbo].[OXO_Vehicle_New] 
   @p_Name  nvarchar(500), 
   @p_AKA  nvarchar(500), 
   @p_Make  nvarchar(500), 
   @p_Active  bit, 
   @p_Created_By  nvarchar(8), 
   @p_Created_On  datetime, 
   @p_Updated_By  nvarchar(8), 
   @p_Last_Updated  datetime, 
  @p_Id INT OUTPUT
AS
	
  INSERT INTO dbo.OXO_Vehicle
  (
    Name,  
    AKA,  
    Make,  
    Active,  
    Created_By,  
    Created_On,  
    Updated_By,  
    Last_Updated  
          
  )
  VALUES 
  (
    @p_Name,  
    @p_AKA,  
    @p_Make,  
    @p_Active,  
    @p_Created_By,  
    @p_Created_On,  
    @p_Updated_By,  
    @p_Last_Updated  
      );

  SET @p_Id = SCOPE_IDENTITY();


