
CREATE PROCEDURE [dbo].[OXO_Programme_GetMany]
 
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
    ORDER BY VehicleName, ModelYear;

