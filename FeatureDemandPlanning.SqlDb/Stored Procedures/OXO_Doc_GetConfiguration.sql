CREATE PROCEDURE [dbo].[OXO_Doc_GetConfiguration] 
  @p_doc_id int
AS	
	SET NOCOUNT ON;

	DECLARE @_prog_Id INT	
	DECLARE @p_archived BIT;
  	
	SELECT @p_archived = Archived,  
		   @_prog_Id = Programme_Id
	FROM OXO_Doc 
	WHERE Id = @p_doc_id;	

	IF ISNULL(@p_archived,0) = 0
	BEGIN	
		-- This should return 4 resultsets	
		-- set 1 all bodies - multiple records	   	
		SELECT 
		Id  AS Id,
		Programme_Id  AS ProgrammeId,  
		Shape  AS Shape,  
		Doors  AS Doors,  
		Wheelbase  AS Wheelbase,  
		Active,  
	    Created_By AS CreatedBy,  
		Created_On AS CreatedOn,  
		Updated_By AS UpdatedBy,  
		Last_Updated  AS LastUpdated  
		FROM OXO_Programme_Body
		WHERE Programme_Id = @_prog_Id
		AND Active = 1;
		
		-- set 2 all engines - multiple records	  
		SELECT 
			Id AS Id,
			Programme_Id  AS ProgrammeId,  
			Size  AS Size,  
			Cylinder  AS Cylinder,  
			Turbo  AS Turbo,  
			Fuel_Type  AS FuelType,  
			[Power]  AS [Power],  
			Electrification AS Electrification,
			Active,  
			Created_By As CreatedBy,  
			Created_On As CreatedOn,  
			Updated_By AS UpdatedBy,  
			Last_Updated AS LastUpdated
		FROM OXO_Programme_Engine
		WHERE Programme_Id = @_prog_Id
		AND Active = 1
		ORDER BY Size, Cylinder, Fuel_Type Desc, [Power] ; 	
	
		-- set 3 all transmissions - multiple records	  
		SELECT 
			Id AS Id,
			Programme_Id  AS ProgrammeId,  
			Type  AS Type,  
			Drivetrain  AS Drivetrain,  
			Active,  
			Created_By AS CreatedBy,  
			Created_On AS CreatedOn,  
			Updated_By AS UpdatedBy,  
			Last_Updated AS LastUpdated
		FROM OXO_Programme_Transmission
		WHERE Programme_Id = @_prog_Id
		AND Active = 1
		ORDER BY Drivetrain, Type; 
				
		-- set 4 all trims - multiple records
		SELECT 
			Id AS Id,
			Programme_Id  AS ProgrammeId,  
			Abbreviation AS Abbreviation,
			Name AS Name,  
			Level  AS Level,
			DPCK AS DPCK,  
			Active,  
			Display_Order AS DisplayOrder,
			Created_By AS CreatedBy,  
			Created_On AS CreatedOn,  
			Updated_By AS UpdatedBy,  
			Last_Updated AS LastUpdated 
		FROM OXO_Programme_Trim
		WHERE Programme_Id = @_prog_Id
		AND Active = 1    
		ORDER By Display_Order, Level;
	END
	ELSE
	BEGIN
		-- This should return 4 resultsets	
		-- set 1 all bodies - multiple records	   	
		SELECT 
		Id  AS Id,
		Programme_Id  AS ProgrammeId,  
		Shape  AS Shape,  
		Doors  AS Doors,  
		Wheelbase  AS Wheelbase,  
		Active,  
	    Created_By AS CreatedBy,  
		Created_On AS CreatedOn,  
		Updated_By AS UpdatedBy,  
		Last_Updated  AS LastUpdated  
		FROM OXO_Archived_Programme_Body
		WHERE Programme_Id = @_prog_Id
		AND Doc_Id = @p_doc_id
		AND Active = 1;
		
		-- set 2 all engines - multiple records	  
		SELECT 
			Id AS Id,
			Programme_Id  AS ProgrammeId,  
			Size  AS Size,  
			Cylinder  AS Cylinder,  
			Turbo  AS Turbo,  
			Fuel_Type  AS FuelType,  
			[Power]  AS [Power],  
			Electrification AS Electrification,
			Active,  
			Created_By As CreatedBy,  
			Created_On As CreatedOn,  
			Updated_By AS UpdatedBy,  
			Last_Updated AS LastUpdated
		FROM OXO_Archived_Programme_Engine
		WHERE Programme_Id = @_prog_Id
		AND Doc_Id = @p_doc_id
		AND Active = 1
		ORDER BY Size, Cylinder, Fuel_Type Desc, [Power] ; 	
	
		-- set 3 all transmissions - multiple records	  
		SELECT 
			Id AS Id,
			Programme_Id  AS ProgrammeId,  
			Type  AS Type,  
			Drivetrain  AS Drivetrain,  
			Active,  
			Created_By AS CreatedBy,  
			Created_On AS CreatedOn,  
			Updated_By AS UpdatedBy,  
			Last_Updated AS LastUpdated
		FROM OXO_Archived_Programme_Transmission
		WHERE Programme_Id = @_prog_Id
		AND Doc_Id = @p_doc_id
		AND Active = 1
		ORDER BY Drivetrain, Type; 
				
		-- set 4 all trims - multiple records
		SELECT 
			Id AS Id,
			Programme_Id  AS ProgrammeId,  
			Abbreviation AS Abbreviation,
			Name AS Name,  
			Level  AS Level,
			DPCK AS DPCK,  
			Active,  
			Display_Order AS DisplayOrder,
			Created_By AS CreatedBy,  
			Created_On AS CreatedOn,  
			Updated_By AS UpdatedBy,  
			Last_Updated AS LastUpdated 
		FROM OXO_Archived_Programme_Trim
		WHERE Programme_Id = @_prog_Id
		AND Doc_Id = @p_doc_id
		AND Active = 1    
		ORDER By Display_Order, Level;
	
	END

