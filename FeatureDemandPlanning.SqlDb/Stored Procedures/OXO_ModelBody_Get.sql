
CREATE PROCEDURE [dbo].[OXO_ModelBody_Get] 
  @p_Id int
AS
	
	SELECT 
      Id  AS Id,
      Programme_Id  AS ProgrammeId,  
      Shape  AS Shape,  
      Doors  AS Doors,  
      Wheelbase  AS Wheelbase,  
      Active  AS Active,  
      Created_By  AS Created_By,  
      Created_On  AS Created_On,  
      Updated_By  AS Updated_By,  
      Last_Updated  AS LastUpdated        	     
    FROM dbo.OXO_Programme_Body
	WHERE Id = @p_Id;



