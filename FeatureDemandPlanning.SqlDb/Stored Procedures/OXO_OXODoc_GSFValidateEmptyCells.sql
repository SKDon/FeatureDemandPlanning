CREATE PROCEDURE [OXO_OXODoc_GSFValidateEmptyCells]
  @p_doc_id int,
  @p_prog_id int,
  @p_rule_id int
AS
  
	DECLARE @_archived BIT;

	SELECT @_archived = Archived FROM OXO_Doc WHERE Id = @p_doc_id and Programme_Id = @p_prog_id;
	
	IF (ISNULL(@_archived,0) = 0)
	BEGIN
  		-- find features with empty cells
		WITH SET_A AS
		(
			SELECT
				MIN(M.Id) AS ModelId,
				ISNULL(M.Doors,'') + ' ' + ISNULL(M.Wheelbase, '') + ' ' + ISNULL(M.Shape,'') AS GSFBody,
				ISNULL(M.Size,'') + ' ' + ISNULL(M.Cylinder,'') + ' ' + ISNULL(M.Turbo,'') + ' ' + ISNULL(M.Power,'') + ' ' + ISNULL(M.Drivetrain,'') AS GSFEngine,
				ISNULL(M.Doors,'') + ' ' + ISNULL(M.Wheelbase,'') + ' #' + ISNULL(M.Shape,'') + ' #' + ISNULL(M.Size,'') + ' ' + ISNULL(M.Cylinder,'') + ' ' + ISNULL(M.Turbo,'') + ' #' + ISNULL(M.Power,'') + ' ' + ISNULL(M.Drivetrain,'') AS GSFNameWithBr,
				M.BMC
				FROM dbo.FN_Programme_Models_Get(@p_prog_id, @p_doc_id) M
				WHERE M.Programme_Id = @p_prog_id   
				GROUP BY M.Size,
						 ISNULL(M.Doors,'') + ' ' + ISNULL(M.Wheelbase,'') + ' ' + ISNULL(M.Shape,''),
						 ISNULL(M.Size, '') + ' ' + ISNULL(M.Cylinder, '') + ' ' + ISNULL(M.Turbo, '') + ' ' + ISNULL(M.Power,'') + ' ' + ISNULL(M.Drivetrain,''),
						 ISNULL(M.Doors,'') + ' ' + ISNULL(M.Wheelbase,'') + ' #' + ISNULL(M.Shape,'') + ' #' + ISNULL(M.Size,'') + ' ' + ISNULL(M.Cylinder,'') + ' ' + ISNULL(M.Turbo,'') + ' #' + ISNULL(M.Power,'') + ' ' + ISNULL(M.Drivetrain,''),
						 M.BMC
		),
		SET_B AS
		(
			SELECT COUNT(*) AS RecCount, PM.ModelId AS ModelId
			FROM SET_A PM
			CROSS JOIN OXO_Programme_GSF_Link FL
			WHERE  FL.Programme_Id = @p_prog_id
			GROUP BY  PM.ModelId
		),
		SET_C AS
		(
			SELECT COUNT(*) AS RecCount, Model_Id AS ModelId
			FROM OXO_Item_Data_GSF
			WHERE OXO_Doc_Id = @p_doc_id
			AND OXO_Code IS NOT NULL
			AND Active = 1
			GROUP BY Model_Id
		),	
		SET_D AS
		(
			SELECT B.ModelId, B.RecCount - ISNULL(C.RecCount,0) Diff
			FROM SET_B B 
			LEFT OUTER JOIN SET_C C
			ON B.ModelId = C.ModelId
		)			
		INSERT INTO OXO_programme_Rule_Result (
			  OXO_Doc_Id, Programme_Id, Object_Level, Object_Id, Rule_Id, 
			  Model_Id, Result_Info, Rule_Result, Created_By, Created_On)
		SELECT @p_doc_id, @p_prog_id, 'g', -1, @p_Rule_Id, D.ModelId, 
			  'Global Standard Feature Section: ' + CAST(diff AS NVARCHAR(6)), 0, 'system', GETDATE()
		FROM SET_D D
		WHERE Diff > 0
	END
	ELSE
	BEGIN
  		-- find features with empty cells
		WITH SET_A AS
		(
			SELECT
				MIN(M.Id) AS ModelId,
				ISNULL(M.Doors,'') + ' ' + ISNULL(M.Wheelbase, '') + ' ' + ISNULL(M.Shape,'') AS GSFBody,
				ISNULL(M.Size,'') + ' ' + ISNULL(M.Cylinder,'') + ' ' + ISNULL(M.Turbo,'') + ' ' + ISNULL(M.Power,'') + ' ' + ISNULL(M.Drivetrain,'') AS GSFEngine,
				ISNULL(M.Doors,'') + ' ' + ISNULL(M.Wheelbase,'') + ' #' + ISNULL(M.Shape,'') + ' #' + ISNULL(M.Size,'') + ' ' + ISNULL(M.Cylinder,'') + ' ' + ISNULL(M.Turbo,'') + ' #' + ISNULL(M.Power,'') + ' ' + ISNULL(M.Drivetrain,'') AS GSFNameWithBr,
				M.BMC
				FROM dbo.FN_Programme_Models_Get(@p_prog_id, @p_doc_id) M
				WHERE M.Programme_Id = @p_prog_id   
				GROUP BY M.Size,
						 ISNULL(M.Doors,'') + ' ' + ISNULL(M.Wheelbase,'') + ' ' + ISNULL(M.Shape,''),
						 ISNULL(M.Size, '') + ' ' + ISNULL(M.Cylinder, '') + ' ' + ISNULL(M.Turbo, '') + ' ' + ISNULL(M.Power,'') + ' ' + ISNULL(M.Drivetrain,''),
						 ISNULL(M.Doors,'') + ' ' + ISNULL(M.Wheelbase,'') + ' #' + ISNULL(M.Shape,'') + ' #' + ISNULL(M.Size,'') + ' ' + ISNULL(M.Cylinder,'') + ' ' + ISNULL(M.Turbo,'') + ' #' + ISNULL(M.Power,'') + ' ' + ISNULL(M.Drivetrain,''),
						 M.BMC
		),
		SET_B AS
		(
			SELECT COUNT(*) AS RecCount, PM.ModelId AS ModelId
			FROM SET_A PM
			CROSS JOIN OXO_Archived_Programme_GSF_Link FL
			WHERE  FL.Programme_Id = @p_prog_id
			GROUP BY  PM.ModelId
		),
		SET_C AS
		(
			SELECT COUNT(*) AS RecCount, Model_Id AS ModelId
			FROM OXO_Item_Data_GSF
			WHERE OXO_Doc_Id = @p_doc_id
			AND OXO_Code IS NOT NULL
			AND Active = 1
			GROUP BY Model_Id
		),	
		SET_D AS
		(
			SELECT B.ModelId, B.RecCount - ISNULL(C.RecCount,0) Diff
			FROM SET_B B 
			LEFT OUTER JOIN SET_C C
			ON B.ModelId = C.ModelId
		)			
		INSERT INTO OXO_programme_Rule_Result (
			  OXO_Doc_Id, Programme_Id, Object_Level, Object_Id, Rule_Id, 
			  Model_Id, Result_Info, Rule_Result, Created_By, Created_On)
		SELECT @p_doc_id, @p_prog_id, 'g', -1, @p_Rule_Id, D.ModelId, 
			  'Global Standard Feature Section: ' + CAST(diff AS NVARCHAR(6)), 0, 'system', GETDATE()
		FROM SET_D D
		WHERE Diff > 0
	END

