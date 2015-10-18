CREATE PROCEDURE [OXO_Doc_Clone_Gateway_Models] 
   @p_doc_id  int, 
   @p_prog_id  int, 
   @p_new_doc_id  int,    
   @p_clone_by nvarchar(50)
AS
BEGIN

	
	DECLARE @p_archived BIT;
	SELECT @p_archived = Archived 
	FROM OXO_Doc 
	WHERE Id = @p_doc_id	
	AND Programme_Id = @p_prog_id;

	IF (ISNULL(@p_archived, 0) = 0)
	BEGIN
		-- Get the body
		INSERT INTO OXO_Archived_Programme_Body (Doc_Id, Programme_Id, Shape, Doors, Wheelbase, Clone_Id, Created_By, Created_On, Updated_By, Last_Updated)
		SELECT Distinct @p_new_doc_id, @p_prog_id, Shape, Doors, Wheelbase, Id, 
			   @p_clone_by, GetDate(), @p_clone_by, GetDate()   
		FROM OXO_Programme_Body
		WHERE Programme_Id = @p_prog_id;
		
		-- Get the Engine
		INSERT INTO OXO_Archived_Programme_Engine (Doc_Id, Programme_Id, Size, Cylinder, Turbo, Fuel_Type, Power, Electrification, 
										  Clone_Id, Created_By, Created_On, Updated_By, Last_Updated)
		SELECT Distinct @p_new_doc_id, @p_prog_id, Size, Cylinder, Turbo, Fuel_Type, Power, Electrification, Id,
							@p_clone_by, GetDate(), @p_clone_by, GetDate()	
		FROM OXO_Programme_Engine
		WHERE Programme_Id = @p_prog_id;
		
		-- Get the Transmission	
		INSERT INTO OXO_Archived_Programme_Transmission (Doc_Id, Programme_Id, Type, DriveTrain, Clone_Id, 
												Created_By, Created_On, Updated_By, Last_Updated)
		SELECT Distinct @p_new_doc_id, @p_prog_id, Type, DriveTrain, Id,
							@p_clone_by, GetDate(), @p_clone_by, GetDate()	
		FROM OXO_Programme_Transmission
		WHERE Programme_Id = @p_prog_id;
		
		-- Get the Trim
		INSERT INTO OXO_Archived_Programme_Trim (Doc_Id, Programme_Id, Name, Abbreviation, Level, Display_Order, Clone_Id, 
												Created_By, Created_On, Updated_By, Last_Updated)
		SELECT Distinct @p_new_doc_id, @p_prog_id, Name, Abbreviation, Level, Display_Order, Id,
							@p_clone_by, GetDate(), @p_clone_by, GetDate()	
		FROM OXO_Programme_Trim
		WHERE Programme_Id = @p_prog_id;
		

		INSERT INTO OXO_Archived_Programme_Model (Doc_Id, Programme_Id, Body_Id, Engine_Id, 
										 Transmission_Id, Trim_Id, Active, CoA, Clone_Id,
										 Created_By, Created_On, Updated_By, Last_Updated) 
		SELECT Distinct @p_new_doc_id, @p_prog_id,  B.Id, E.Id, T.Id, TM.Id, M.Active, CoA , M.Id,
			   @p_clone_by, GetDate(),@p_clone_by, GetDate()	
		FROM  OXO_Programme_Model M
		INNER JOIN OXO_Archived_Programme_Body B 
		ON M.Body_Id = B.Clone_Id
		AND B.Doc_Id = @p_new_doc_id
		INNER JOIN OXO_Archived_Programme_Engine E 
		ON M.Engine_Id = E.Clone_Id
		AND E.Doc_Id = @p_new_doc_id
		INNER JOIN OXO_Archived_Programme_Transmission T 
		ON M.Transmission_Id = T.Clone_Id
		AND T.Doc_Id = @p_new_doc_id
		INNER JOIN OXO_Archived_Programme_Trim TM 
		ON M.Trim_Id = TM.Clone_Id
		AND TM.Doc_Id = @p_new_doc_id
		WHERE M.Programme_Id = @p_prog_id;
	END
	ELSE
	BEGIN
			-- Get the body
		INSERT INTO OXO_Archived_Programme_Body (Doc_Id, Programme_Id, Shape, Doors, Wheelbase, Clone_Id, Created_By, Created_On, Updated_By, Last_Updated)
		SELECT Distinct @p_new_doc_id, @p_prog_id, Shape, Doors, Wheelbase, Id, 
			   @p_clone_by, GetDate(), @p_clone_by, GetDate()   
		FROM OXO_Archived_Programme_Body
		WHERE Programme_Id = @p_prog_id
		AND Doc_Id = @p_doc_id;
				
		-- Get the Engine
		INSERT INTO OXO_Archived_Programme_Engine (Doc_Id, Programme_Id, Size, Cylinder, Turbo, Fuel_Type, Power, Electrification, 
										  Clone_Id, Created_By, Created_On, Updated_By, Last_Updated)
		SELECT Distinct @p_new_doc_id, @p_prog_id, Size, Cylinder, Turbo, Fuel_Type, Power, Electrification, Id,
							@p_clone_by, GetDate(), @p_clone_by, GetDate()	
		FROM OXO_Archived_Programme_Engine
		WHERE Programme_Id = @p_prog_id
		AND Doc_Id = @p_doc_id;
		
		-- Get the Transmission	
		INSERT INTO OXO_Archived_Programme_Transmission (Doc_Id, Programme_Id, Type, DriveTrain, Clone_Id, 
												Created_By, Created_On, Updated_By, Last_Updated)
		SELECT Distinct @p_new_doc_id, @p_prog_id, Type, DriveTrain, Id,
							@p_clone_by, GetDate(), @p_clone_by, GetDate()	
		FROM OXO_Archived_Programme_Transmission
		WHERE Programme_Id = @p_prog_id
		AND Doc_Id = @p_doc_id;
		
		-- Get the Trim
		INSERT INTO OXO_Archived_Programme_Trim (Doc_Id, Programme_Id, Name, Abbreviation, Level, Display_Order, Clone_Id, 
												Created_By, Created_On, Updated_By, Last_Updated)
		SELECT Distinct @p_new_doc_id, @p_prog_id, Name, Abbreviation, Level, Display_Order, Id,
							@p_clone_by, GetDate(), @p_clone_by, GetDate()	
		FROM OXO_Archived_Programme_Trim
		WHERE Programme_Id = @p_prog_id
		AND Doc_Id = @p_doc_id;

		INSERT INTO OXO_Archived_Programme_Model (Doc_Id, Programme_Id, Body_Id, Engine_Id, 
										 Transmission_Id, Trim_Id, Active, CoA, Clone_Id,
										 Created_By, Created_On, Updated_By, Last_Updated) 
		SELECT Distinct @p_new_doc_id, @p_prog_id,  B.Id, E.Id, T.Id, TM.Id, M.Active, CoA , M.Id,
			   @p_clone_by, GetDate(),@p_clone_by, GetDate()	
		FROM  OXO_Archived_Programme_Model M
		INNER JOIN OXO_Archived_Programme_Body B 
		ON M.Body_Id = B.Clone_Id
		AND B.Doc_Id = @p_new_doc_id
		INNER JOIN OXO_Archived_Programme_Engine E 
		ON M.Engine_Id = E.Clone_Id
		AND E.Doc_Id = @p_new_doc_id
		INNER JOIN OXO_Archived_Programme_Transmission T 
		ON M.Transmission_Id = T.Clone_Id
		AND T.Doc_Id = @p_new_doc_id
		INNER JOIN OXO_Archived_Programme_Trim TM 
		ON M.Trim_Id = TM.Clone_Id
		AND TM.Doc_Id = @p_new_doc_id
		WHERE M.Programme_Id = @p_prog_id
		AND M.Doc_Id = @p_doc_id;

	
	END 
	
END

