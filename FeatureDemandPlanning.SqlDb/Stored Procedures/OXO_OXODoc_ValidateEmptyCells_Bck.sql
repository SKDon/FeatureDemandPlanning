CREATE PROCEDURE [dbo].[OXO_OXODoc_ValidateEmptyCells_Bck]
  @p_doc_id int,
  @p_prog_id int,
  @rec_count int OUTPUT
AS

	DECLARE @p_Empty_Rule_Id INT;
	
	SELECT @p_Empty_Rule_Id = Id 
	FROM OXO_Programme_Rule 
	WHERE Rule_Group = 'GEN';
	
	IF @p_Empty_Rule_Id IS NOT NULL
	BEGIN
		-- clear out any existing results for this doc / prog
		DELETE FROM OXO_programme_Rule_Result
		WHERE OXO_Doc_Id = @p_doc_id
		AND Programme_Id = @p_prog_id
		AND Rule_Id = @p_Empty_Rule_Id;
		
		-- find features with empty cells
		WITH SET_A AS
		(
			SELECT COUNT(*) AS RecCount, PM.ID AS ModelId
			FROM OXO_Programme_Model PM
			CROSS JOIN OXO_Programme_Feature_Link FL
			WHERE PM.Programme_Id = @p_prog_id
			AND PM.Active = 1
			AND FL.Programme_Id = @p_prog_id
			GROUP BY  PM.ID
		),
		SET_B AS
		(
			SELECT COUNT(*) AS RecCount, Model_Id AS ModelId
			FROM OXO_Item_Data
			WHERE SECTION = 'FBM'
			AND Market_Id = -1
			AND OXO_Doc_Id = @p_doc_id
			AND OXO_Code IS NOT NULL
			GROUP BY Model_Id
		)
				
		INSERT INTO OXO_programme_Rule_Result (
			  OXO_Doc_Id, Programme_Id, Object_Level, Object_Id, Rule_Id, 
			  Model_Id, Result_Info, Rule_Result, Created_By, Created_On)
		SELECT @p_doc_id, @p_prog_id, 'g', -1, @p_Empty_Rule_Id, 	
			   A.ModelId,'FBM: ' + CAST((A.RecCount - ISNULL(B.RecCount,0)) AS NVARCHAR(6)) + ' empty cell(s).', 
			   0, 'system', GETDATE()
		FROM SET_A A 
		INNER JOIN SET_B B
		ON A.ModelId = B.ModelId
		AND (A.RecCount - ISNULL(B.RecCount,0)) > 0;
		
		
		-- find GSF features with empty cells
		WITH SET_X AS
		(
			SELECT COUNT(*) AS RecCount, PM.ID AS ModelId
			FROM OXO_Programme_Model PM
			CROSS JOIN OXO_Programme_GSF_Link FL
			WHERE PM.Programme_Id = @p_prog_id
			AND PM.Active = 1
			AND FL.Programme_Id = @p_prog_id
			GROUP BY  PM.ID
		),
		SET_Y AS
		(
			SELECT COUNT(*) AS RecCount, Model_Id AS ModelId
			FROM OXO_Item_Data
			WHERE SECTION = 'GSF'
			AND Market_Id = -1
			AND OXO_Doc_Id = @p_doc_id
			AND OXO_Code IS NOT NULL
			GROUP BY Model_Id
		)
				
		INSERT INTO OXO_programme_Rule_Result (
			  OXO_Doc_Id, Programme_Id, Object_Level, Object_Id, Rule_Id, 
			  Model_Id, Result_Info, Rule_Result, Created_By, Created_On)
		SELECT @p_doc_id, @p_prog_id, 'g', -1, @p_Empty_Rule_Id, 	
			   X.ModelId,'GSF: ' + CAST((X.RecCount - ISNULL(Y.RecCount,0)) AS NVARCHAR(6)) + ' empty cell(s).', 
			   0, 'system', GETDATE()
		FROM SET_X X 
		INNER JOIN SET_Y Y
		ON X.ModelId = Y.ModelId
		AND (X.RecCount - ISNULL(Y.RecCount,0)) > 0;
		
		SELECT @rec_count = COUNT(*)
		FROM OXO_Programme_Rule_Result
		WHERE OXO_Doc_Id = @p_doc_id
		AND Programme_Id = @p_prog_id
		AND Rule_Result = 0
		AND Rule_Id = @p_Empty_Rule_Id
		
		
	END
	ELSE
		SELECT @rec_count = 0