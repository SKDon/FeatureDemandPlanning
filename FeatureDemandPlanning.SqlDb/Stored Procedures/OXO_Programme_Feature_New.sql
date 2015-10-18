
CREATE  PROCEDURE [dbo].[OXO_Programme_Feature_New] 
   @p_prog_id INT,
   @p_Description  nvarchar(500), 
   @p_Notes  nvarchar(2000), 
   @p_Feature_Group  nvarchar(500), 
   @p_Created_By  nvarchar(8), 
   @p_Created_On  datetime, 
   @p_Updated_By  nvarchar(8), 
   @p_Last_Updated  datetime, 
  @p_Id INT OUTPUT
AS
	
  DECLARE @vehicle_id INT 	
  	
  INSERT INTO dbo.OXO_Feature_Ext
  (
    Description,  
  --  Notes,  
  --  Feature_Group,  
    Created_By,  
    Created_On,  
    Updated_By,  
    Last_Updated  
          
  )
  VALUES 
  (
    @p_Description,  
   -- @p_Notes,  
   -- @p_Feature_Group,  
    @p_Created_By,  
    @p_Created_On,  
    @p_Updated_By,  
    @p_Last_Updated  
      );

  SET @p_Id = SCOPE_IDENTITY();

  SELECT @vehicle_id = Vehicle_Id FROM dbo.OXO_Programme WHERE Id = @p_prog_id;   	
  
 -- INSERT INTO dbo.OXO_Programme_Feature_Link (Programme_Id, Feature_Id)
 --             VALUES (@p_prog_id, @p_Id);        


 -- INSERT INTO dbo.OXO_Vehicle_Feature_Link (Vehicle_Id, Feature_Id)
 --             VALUES (@vehicle_id, @p_Id);        
              
 --INSERT INTO dbo.OXO_Feature_Marketing_Info (Vehicle_Id, Feature_Id, Description)
 --              VALUES (@vehicle_id, @p_Id, @p_Description);              
     


