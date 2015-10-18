
CREATE PROCEDURE [dbo].[OXO_ModelTransmission_Get] 
  @p_Id int
AS
	
	SELECT 
      Id  AS Id,
      Programme_Id  AS ProgrammeId,  
      Type  AS Type,  
      Drivetrain  AS Drivetrain,  
      Active  AS Active,  
      Created_By  AS CreatedBy,  
      Created_On  AS CreatedOn,  
      Updated_By  AS UpdatedBy,  
      Last_Updated  AS LastUpdated        	     
    FROM dbo.OXO_Programme_Transmission
	WHERE Id = @p_Id;



