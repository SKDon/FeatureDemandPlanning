CREATE PROCEDURE [dbo].[OXO_OXODoc_ValidateEFGs] 
  @p_doc_id int,
  @p_prog_id int,
  @rec_count int OUTPUT
AS

	DECLARE @p_EFG_Rule_Id INT;
	
	SELECT @p_EFG_Rule_Id = Id 
	FROM OXO_Programme_Rule 
	WHERE Rule_Group = 'EFG';
	
	IF @p_EFG_Rule_Id IS NOT NULL
	BEGIN
		-- Step 1 - clear out any existing results for this doc / prog
		DELETE FROM OXO_programme_Rule_Result
		WHERE OXO_Doc_Id = @p_doc_id
		AND Programme_Id = @p_prog_id
		AND Rule_Id = @p_EFG_Rule_Id;
		
		-- Step two - do positive test for EFGs that have 1 option and 1 option only selected
		WITH SET_A AS
		(
			SELECT COUNT(*) AS RecCount, 
				   Feat_EFG, 
				   Model_id, 
				   CASE WHEN Market_group_Id IS NOT NULL THEN 'mg'
						WHEN Market_Id = -1 THEN 'g'
						ELSE 'm' END AS Object_Level,
				   ISNULL(Market_group_Id, Market_Id) AS Object_Id
			FROM OXO_Item_Data_FBM D
			INNER JOIN OXO_Feature_Ext F
			ON D.Feature_Id = F.ID
			WHERE OXO_Doc_id = @p_doc_id
			AND Feat_EFG IS NOT NULL
			AND OXO_Code = 'S' 
			GROUP BY Feat_EFG, Market_group_Id, Market_Id, Model_id
			HAVING COUNT(*) = 1
		)	
		INSERT INTO OXO_programme_Rule_Result (
			  OXO_Doc_Id, Programme_Id, Object_Level, Object_Id, Rule_Id, 
			  Model_Id, Result_Info, Rule_Result, Created_By, Created_On)
		SELECT @p_doc_id, @p_prog_id, Object_Level, Object_Id, @p_EFG_Rule_Id, 	
			   Model_Id,Feat_EFG, 1, 'system', GETDATE()
		FROM SET_A;		    
		      	      
		-- Step three - do negative test for EFGs that have 0 option or more than 1 option selected	
		WITH SET_A AS
		(
			SELECT COUNT(*) AS RecCount, 
				   Feat_EFG, 
				   Model_id, 
				   CASE WHEN Market_group_Id IS NOT NULL THEN 'mg'
						WHEN Market_Id = -1 THEN 'g'
						ELSE 'm' END AS Object_Level,
				   ISNULL(Market_group_Id, Market_Id) AS Object_Id
			FROM OXO_Item_Data_FBM D
			INNER JOIN OXO_Feature_Ext F
			ON D.Feature_Id = F.ID
			WHERE OXO_Doc_id = @p_doc_id
			AND F.Feat_EFG IS NOT NULL
			AND OXO_Code = 'S' 
			GROUP BY Feat_EFG, Market_group_Id, Market_Id, Model_id
			HAVING COUNT(*) = 1
					
		), SET_B AS
		(
			SELECT DISTINCT Feat_EFG, Model_id, 
				   CASE WHEN Market_group_Id IS NOT NULL THEN 'mg'
						WHEN Market_Id = -1 THEN 'g'
						ELSE 'm' END AS Object_Level,
					ISNULL(Market_group_Id, Market_Id) AS Object_Id    
			FROM OXO_Item_Data_FBM D
			INNER JOIN OXO_Feature_Ext F
			ON D.Feature_Id = F.ID
			WHERE OXO_Doc_id = @p_doc_id
			and Feat_EFG IS NOT NULL	
		)
		INSERT INTO OXO_programme_Rule_Result (
			  OXO_Doc_Id, Programme_Id, Object_Level, Object_Id, Rule_Id, 
			  Model_Id, Result_Info, Rule_Result, Created_By, Created_On)
		SELECT @p_doc_id, @p_prog_id, Object_Level, Object_Id, @p_EFG_Rule_Id, 	
			   Model_Id, Feat_EFG, 0, 'system', GETDATE()
		FROM SET_B B
		WHERE NOT EXISTS
		(
		   SELECT 1 FROM SET_A A
		   WHERE A.Feat_EFG = B.Feat_EFG
		   AND A.Model_id  = B.Model_id
		   AND A.Object_Level = B.Object_Level
		   AND A.Object_Id = B.Object_Id
		)
		
		SELECT @rec_count = COUNT(*)
		FROM OXO_Programme_Rule_Result
		WHERE OXO_Doc_Id = @p_doc_id
		AND Programme_Id = @p_prog_id
		AND Rule_Result = 0
		AND Rule_Id = @p_EFG_Rule_Id
	END
	ELSE
		SELECT @rec_count = 0

