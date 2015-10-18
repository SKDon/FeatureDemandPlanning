CREATE PROCEDURE [OXO_OXODoc_ValidateEmptyCells]
  @p_doc_id int,
  @p_prog_id int,
  @p_mode nvarchar(2),
  @p_object_id int,
  @rec_count int OUTPUT
AS

	DECLARE @p_Empty_Rule_Id INT;
	
	SELECT @p_Empty_Rule_Id = Id 
	FROM OXO_Programme_Rule 
	WHERE Rule_Group = 'GEN'
	AND ISNULL(Active,0) = 1;
	
	IF @p_Empty_Rule_Id IS NOT NULL
	BEGIN
		-- clear out any existing results for this doc / prog
		DELETE FROM OXO_programme_Rule_Result
		WHERE OXO_Doc_Id = @p_doc_id
		AND Programme_Id = @p_prog_id
		AND Rule_Id = @p_Empty_Rule_Id;
		
		-- Find FBM features with empty cells
		EXEC dbo.OXO_OXODoc_FBMValidateEmptyCells @p_doc_id, @p_prog_id, @p_mode, @p_object_id, @p_Empty_Rule_Id;		 			
		-- Find PCK features with empty cells
		EXEC dbo.OXO_OXODoc_PCKValidateEmptyCells @p_doc_id, @p_prog_id, @p_mode, @p_object_id, @p_Empty_Rule_Id;
		-- Find FPS features with empty cells
		EXEC dbo.OXO_OXODoc_FPSValidateEmptyCells @p_doc_id, @p_prog_id, @p_mode, @p_object_id, @p_Empty_Rule_Id;
	
	
		-- Find GSF features with empty cells only if mode is g
		IF (@p_mode = 'g') 
		BEGIN
			EXEC dbo.OXO_OXODoc_GSFValidateEmptyCells @p_doc_id, @p_prog_id, @p_Empty_Rule_Id;
		END;
	
		SELECT @rec_count = COUNT(*)
		FROM OXO_Programme_Rule_Result
		WHERE OXO_Doc_Id = @p_doc_id
		AND Programme_Id = @p_prog_id
		AND Rule_Result = 0
		AND Rule_Id = @p_Empty_Rule_Id;

		-- Need to add in the ticks
		WITH SET_A AS
		(
			SELECT Model_ID 
			FROM dbo.FN_SPLIT_MODEL_IDS(dbo.OXO_ModelIdString_Get(@p_doc_id, @p_mode, @p_object_id))
		),
		SET_B AS
		(
			SELECT Model_ID
			FROM OXO_programme_Rule_Result RR
			WHERE RR.OXO_Doc_Id = @p_doc_id
			AND RR.Programme_Id = @p_prog_id
			AND RR.Object_Level = @p_mode
			AND RR.Object_Id = @p_object_id
			AND RR.Rule_Id = @p_Empty_Rule_Id
			AND RR.Rule_Result = 0
		)
		INSERT INTO OXO_programme_Rule_Result (
			  OXO_Doc_Id, Programme_Id, Object_Level, Object_Id, Rule_Id, 
			  Model_Id, Result_Info, Rule_Result, Created_By, Created_On)
		SELECT @p_doc_id, @p_prog_id, @p_mode, @p_object_id, @p_Empty_Rule_Id, A.Model_Id, 
			  'Empty cells check: All cells populated', 1, 'system', GETDATE()
			  
		FROM SET_A A
		LEFT OUTER JOIN SET_B B
		ON A.Model_Id = B.Model_Id
		WHERE B.Model_ID IS NULL;
			
	END
	ELSE
		SELECT @rec_count = 0



