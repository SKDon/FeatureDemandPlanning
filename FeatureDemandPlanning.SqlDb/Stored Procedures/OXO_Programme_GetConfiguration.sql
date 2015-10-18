CREATE PROCEDURE [dbo].[OXO_Programme_GetConfiguration] 
  @p_Id int
AS	
	SET NOCOUNT ON;
		
	-- This should return 5 resultsets	
	-- set 1 vehicle programme detail - single record	
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

	-- set 2 all bodies - multiple records	   		
	EXEC dbo.OXO_ModelBody_GetMany @p_prog_id= @p_Id;
	
	-- set 3 all engines - multiple records	  
	EXEC dbo.OXO_ModelEngine_GetMany @p_prog_id= @p_Id;
	
	-- set 3 all transmissions - multiple records	  
	EXEC dbo.OXO_ModelTransmission_GetMany @p_prog_id= @p_Id;
			
    -- set 5 all trims - multiple records
   EXEC dbo.OXO_ModelTrim_GetMany @p_prog_id= @p_Id;

