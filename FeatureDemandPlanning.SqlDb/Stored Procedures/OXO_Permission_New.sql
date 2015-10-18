
CREATE  PROCEDURE [dbo].[OXO_Permission_New] 
   @p_CDSID  nvarchar(50), 
   @p_Object_Type  nvarchar(500), 
   @p_Object_Id  int, 
   @p_Object_Val  nvarchar(500), 
   @p_Operation  nvarchar(500), 
   @p_Created_By  nvarchar(50), 
   @p_Created_On  datetime, 
   @p_Updated_By  nvarchar(50), 
   @p_Last_Updated  datetime, 
  @p_Id INT OUTPUT
AS
	
  INSERT INTO dbo.OXO_Permission
  (
    CDSID,  
    Object_Type,  
    [Object_Id],  
    Object_Val,  
    Operation,  
    Created_By,  
    Created_On,  
    Updated_By,  
    Last_Updated  
          
  )
  VALUES 
  (
    @p_CDSID,  
    @p_Object_Type,  
    @p_Object_Id,  
    @p_Object_Val,  
    @p_Operation,  
    @p_Created_By,  
    @p_Created_On,  
    @p_Updated_By,  
    @p_Last_Updated  
      );

  SET @p_Id = SCOPE_IDENTITY();


