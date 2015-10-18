
CREATE PROCEDURE [dbo].[OXO_ModelEngine_Get] 
  @p_Id int
AS
	
	SELECT 
      Id  AS Id,
      Programme_Id  AS ProgrammeId,  
      Size  AS Size,  
      Cylinder  AS Cylinder,  
      Turbo  AS Turbo,  
      Fuel_Type  AS FuelType,  
      Power  AS Power,  
      Electrification AS Electrification,
      Active  AS Active,  
      Created_By  AS CreatedBy,  
      Created_On  AS CreatedOn,  
      Updated_By  AS UpdatedBy,  
      Last_Updated  AS LastUpdated  
      	     
    FROM dbo.OXO_Programme_Engine
	WHERE Id = @p_Id;



