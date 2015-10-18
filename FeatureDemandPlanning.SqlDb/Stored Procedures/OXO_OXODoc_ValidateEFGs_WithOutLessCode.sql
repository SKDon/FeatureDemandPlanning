CREATE PROCEDURE [dbo].[OXO_OXODoc_ValidateEFGs_WithOutLessCode] 
  @p_doc_id int,
  @p_prog_id int,
  @p_mode nvarchar(2),
  @p_object_id int,
  @rec_count int OUTPUT
AS

	DECLARE @_EFG_Rule_Id INT;
	DECLARE @_model_ids NVARCHAR(4000);
	
	SELECT @_EFG_Rule_Id = Id 
	FROM OXO_Programme_Rule 
	WHERE Rule_Group = 'EFG'
	AND ISNULL(Active,0) = 1;
	
	IF @_EFG_Rule_Id IS NOT NULL
	BEGIN
		-- Step 1 - clear out any existing results for this doc / prog
		DELETE FROM OXO_programme_Rule_Result
		WHERE OXO_Doc_Id = @p_doc_id
		AND Programme_Id = @p_prog_id
		AND Rule_Id = @_EFG_Rule_Id;
	
		-- Step 2 - determine what model ids we need to worry about
		SET @_model_ids = dbo.OXO_ModelIdString_Get(@p_doc_id, @p_mode, @p_object_id);
		
		-- Step three - do negative test for EFGs that have 1 option and 1 option only selected
		-- need to split by level and call the right function
		IF (@p_mode = 'g')
		BEGIN
					
			WITH SET_A AS
			(
				SELECT COUNT(*) AS RecCount, 
					   Feat_EFG, 
					   EFG_Desc,
					   Model_id, 
					   @p_mode AS Object_Level,
					   @p_object_id AS Object_Id
				FROM FN_OXO_Data_Get_FBM_Global(@p_doc_id, @_model_ids) D
				INNER JOIN OXO_Feature_Ext F
				ON D.Feature_Id = F.ID
				LEFT OUTER JOIN OXO_Exclusive_Feature_Group EFG
				ON F.Feat_EFG = EFG.EFG_Code
				WHERE F.Feat_EFG IS NOT NULL
				AND OXO_Code = 'S' 
				GROUP BY Feat_EFG, EFG_Desc, Model_Id
				HAVING COUNT(*) > 1
						
			)
			INSERT INTO OXO_programme_Rule_Result (
				  OXO_Doc_Id, Programme_Id, Object_Level, Object_Id, Rule_Id, 
				  Model_Id, Result_Info, Rule_Result, Created_By, Created_On)
			SELECT @p_doc_id, @p_prog_id, Object_Level, Object_Id, @_EFG_Rule_Id, 	
				   Model_Id, EFG_Desc, 0, 'system', GETDATE()
			FROM SET_A;
		
		END
		
		IF (@p_mode = 'mg')
		BEGIN
			
			WITH SET_A AS
			(
				SELECT COUNT(*) AS RecCount, 
					   Feat_EFG, 
					   EFG_Desc,
					   Model_id, 
					   @p_mode AS Object_Level,
					   @p_object_id AS Object_Id
				FROM FN_OXO_Data_Get_FBM_MarketGroup(@p_doc_id, @p_object_id, @_model_ids) D
				INNER JOIN OXO_Feature_Ext F
				ON D.Feature_Id = F.ID
				LEFT OUTER JOIN OXO_Exclusive_Feature_Group EFG
				ON F.Feat_EFG = EFG.EFG_Code
				WHERE F.Feat_EFG IS NOT NULL
				AND OXO_Code LIKE 'S%'
				GROUP BY Feat_EFG, EFG_Desc, Model_Id
				HAVING COUNT(*) > 1
						
			)
			INSERT INTO OXO_programme_Rule_Result (
				  OXO_Doc_Id, Programme_Id, Object_Level, Object_Id, Rule_Id, 
				  Model_Id, Result_Info, Rule_Result, Created_By, Created_On)
			SELECT @p_doc_id, @p_prog_id, Object_Level, Object_Id, @_EFG_Rule_Id, 	
				   Model_Id, EFG_Desc, 0, 'system', GETDATE()
			FROM SET_A;				
		END
		
		IF (@p_mode = 'm')
		BEGIN
			
			-- need to get the market_group_Id here
			DECLARE @_market_group_id INT;
			
			SELECT @_market_group_id = Market_Group_Id 
			FROM OXO_Programme_MarketGroup_Market_LInk
			WHERE Programme_Id = @p_prog_id
			AND Country_Id = @p_object_id;
			
			WITH SET_A AS
			(
				SELECT COUNT(*) AS RecCount, 
					   Feat_EFG, 
					   EFG_Desc,
					   Model_id, 
					   @p_mode AS Object_Level,
					   @p_object_id AS Object_Id
				FROM FN_OXO_Data_Get_FBM_Market(@p_doc_id, @_market_group_id, @p_object_id, @_model_ids) D
				INNER JOIN OXO_Feature_Ext F
				ON D.Feature_Id = F.ID
				LEFT OUTER JOIN OXO_Exclusive_Feature_Group EFG
				ON F.Feat_EFG = EFG.EFG_Code
				WHERE F.Feat_EFG IS NOT NULL
				AND OXO_Code LIKE 'S%'
				GROUP BY Feat_EFG, EFG_Desc, Model_Id
				HAVING COUNT(*) > 1
						
			)
			INSERT INTO OXO_programme_Rule_Result (
				  OXO_Doc_Id, Programme_Id, Object_Level, Object_Id, Rule_Id, 
				  Model_Id, Result_Info, Rule_Result, Created_By, Created_On)
			SELECT @p_doc_id, @p_prog_id, Object_Level, Object_Id, @_EFG_Rule_Id, 	
				   Model_Id, EFG_Desc, 0, 'system', GETDATE()
			FROM SET_A;										
		END
		
		SELECT @rec_count = COUNT(*)
		FROM OXO_Programme_Rule_Result
		WHERE OXO_Doc_Id = @p_doc_id
		AND Programme_Id = @p_prog_id
		AND Rule_Result = 0
		AND Rule_Id = @_EFG_Rule_Id;
		
		
		-- Step four - Now check if any negative test has failed. If none. 
		-- Insert tick as a positive response.	
				
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
			AND RR.Rule_Id = @_EFG_Rule_Id
			AND RR.Rule_Result = 0
		)
		INSERT INTO OXO_programme_Rule_Result (
			  OXO_Doc_Id, Programme_Id, Object_Level, Object_Id, Rule_Id, 
			  Model_Id, Result_Info, Rule_Result, Created_By, Created_On)
		SELECT @p_doc_id, @p_prog_id, @p_mode, @p_object_id, @_EFG_Rule_Id, A.Model_Id, 
			  'EFG check: All EFGs checked successfully.', 1, 'system', GETDATE()			  
		FROM SET_A A
		LEFT OUTER JOIN SET_B B
		ON A.Model_Id = B.Model_Id
		WHERE B.Model_ID IS NULL;
		
		
	END
	ELSE
		SELECT @rec_count = 0