
CREATE PROCEDURE [dbo].[OXO_Permission_Get] 
  @p_Id int
AS
	
	SELECT 
      Id  AS Id,
      CDSID  AS CDSID,  
      Object_Type  AS ObjectType,  
      [Object_Id]  AS ObjectId,  
      Object_Val  AS ObjectVal,  
      Operation  AS Operation,  
      Created_By  AS CreatedBy,  
      Created_On  AS CreatedOn,  
      Updated_By  AS UpdatedBy,  
      Last_Updated  AS LastUpdated  
      	     
    FROM dbo.OXO_Permission
	WHERE Id = @p_Id;



