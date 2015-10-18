
CREATE PROCEDURE [OXO_Programme_Get] 
  @p_Id int
AS	
    SELECT 
		Id,
		VehicleId,  
		VehicleName,  
		VehicleAKA,
		VehicleMake,
		VehicleDisplayFormat,
		ModelYear,
		PS,
		J1,
		Notes,  
		ProductManager,  
		RSGUID,  
		OXOEnabled,		
		Active,  
		UseOACode,
		CreatedBy,  
		CreatedOn,  
		UpdatedBy,  
		LastUpdated  
    FROM dbo.OXO_Programme_VW
    WHERE Id = @p_Id;

