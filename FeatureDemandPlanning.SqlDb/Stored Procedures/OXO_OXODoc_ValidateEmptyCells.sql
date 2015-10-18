
CREATE PROCEDURE [dbo].[OXO_OXODoc_ValidateEmptyCells]
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
		
		-- Find FBM features with empty cells
		EXEC dbo.OXO_OXODoc_FBMValidateEmptyCells @p_doc_id, @p_prog_id, @p_Empty_Rule_Id;		 			
		-- Find GSF features with empty cells
		EXEC dbo.OXO_OXODoc_GSFValidateEmptyCells @p_doc_id, @p_prog_id, @p_Empty_Rule_Id;
		-- Find PCK features with empty cells
		EXEC dbo.OXO_OXODoc_PCKValidateEmptyCells @p_doc_id, @p_prog_id, @p_Empty_Rule_Id;
		-- Find FPS features with empty cells
		

		SELECT @rec_count = COUNT(*)
		FROM OXO_Programme_Rule_Result
		WHERE OXO_Doc_Id = @p_doc_id
		AND Programme_Id = @p_prog_id
		AND Rule_Result = 0
		AND Rule_Id = @p_Empty_Rule_Id
		
		
	END
	ELSE
		SELECT @rec_count = 0



