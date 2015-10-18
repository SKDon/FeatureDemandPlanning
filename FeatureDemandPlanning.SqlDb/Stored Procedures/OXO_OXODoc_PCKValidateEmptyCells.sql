CREATE PROCEDURE [OXO_OXODoc_PCKValidateEmptyCells]
  @p_doc_id int,
  @p_prog_id int,
  @p_mode nvarchar(2),
  @p_object_id int,
  @p_rule_id int
AS

DECLARE @_model_id NVARCHAR(4000);
DECLARE @_archived BIT;

SELECT @_archived = Archived FROM OXO_Doc WHERE Id = @p_doc_id and Programme_Id = @p_prog_id;

IF (ISNULL(@_archived ,0) = 0)
BEGIN
	IF (@p_mode = 'm')
	BEGIN
		SET @_model_id = dbo.OXO_ModelIdString_Get(@p_doc_id, @p_mode, @p_object_id);
		
		-- find PCK features with empty cells
		WITH SET_A AS
		(
			SELECT COUNT(*) AS RecCount, PM.ID AS ModelId
			FROM OXO_Programme_Model PM
			INNER JOIN dbo.FN_SPLIT_MODEL_IDS(@_model_Id) MI
			ON PM.Id = MI.Model_Id
			CROSS JOIN OXO_Programme_Pack PK
			WHERE PM.Programme_Id = @p_prog_id
			AND PM.Active = 1
			AND PK.Programme_Id = @p_prog_id		
			GROUP BY  PM.ID
		),
		SET_B AS
		(
			SELECT COUNT(*) AS RecCount, Model_Id AS ModelId
			FROM dbo.FN_OXO_Data_Get_PCK_Market(@p_doc_id, null, @p_object_id, @_model_id)
			WHERE OXO_Code IS NOT NULL					-- market_group_id
			GROUP BY Model_Id
		),
		SET_C AS
		(
			SELECT A.ModelId, A.RecCount - ISNULL(B.RecCount,0) Diff
			FROM SET_A A 
			LEFT OUTER JOIN SET_B B
			ON A.ModelId = B.ModelId
		)		
  		INSERT INTO OXO_programme_Rule_Result (
			  OXO_Doc_Id, Programme_Id, Object_Level, Object_Id, Rule_Id, 
			  Model_Id, Result_Info, Rule_Result, Created_By, Created_On)
		SELECT @p_doc_id, @p_prog_id, @p_mode, @p_object_id, @p_Rule_Id, C.ModelId, 
			  'Pack Header Section: ' + CAST(diff AS NVARCHAR(6)), 0, 'system', GETDATE()
		FROM SET_C C
		WHERE Diff > 0
	END
	ELSE IF (@p_mode = 'mg')
	BEGIN
		SET @_model_id = dbo.OXO_ModelIdString_Get(@p_doc_id, @p_mode, @p_object_id);
		
		WITH SET_A AS
		(
			SELECT COUNT(*) AS RecCount, PM.ID AS ModelId
			FROM OXO_Programme_Model PM
			INNER JOIN dbo.FN_SPLIT_MODEL_IDS(@_model_Id) MI
			ON PM.Id = MI.Model_Id
			CROSS JOIN OXO_Programme_Pack PK
			WHERE PM.Programme_Id = @p_prog_id
			AND PM.Active = 1
			AND PK.Programme_Id = @p_prog_id
			GROUP BY  PM.ID
		),
		SET_B AS
		(
			SELECT COUNT(*) AS RecCount, Model_Id AS ModelId
			FROM dbo.FN_OXO_Data_Get_PCK_MarketGroup(@p_doc_id, @p_object_id, @_model_id)
			WHERE OXO_Code IS NOT NULL
			GROUP BY Model_Id
		),
		SET_C AS
		(
			SELECT A.ModelId, A.RecCount - ISNULL(B.RecCount,0) Diff
			FROM SET_A A 
			LEFT OUTER JOIN SET_B B
			ON A.ModelId = B.ModelId
		)		
  		INSERT INTO OXO_programme_Rule_Result (
			  OXO_Doc_Id, Programme_Id, Object_Level, Object_Id, Rule_Id, 
			  Model_Id, Result_Info, Rule_Result, Created_By, Created_On)
		SELECT @p_doc_id, @p_prog_id, @p_mode, @p_object_id, @p_Rule_Id, C.ModelId, 
			  'Pack Header Section: ' + CAST(diff AS NVARCHAR(6)), 0, 'system', GETDATE()
		FROM SET_C C
		WHERE Diff > 0
	END
	ELSE
	BEGIN
		SET @_model_id = dbo.OXO_ModelIdString_Get(@p_doc_id, @p_mode, @p_object_id);
		
		WITH SET_A AS
		(
			SELECT COUNT(*) AS RecCount, PM.ID AS ModelId
			FROM OXO_Programme_Model PM
			INNER JOIN dbo.FN_SPLIT_MODEL_IDS(@_model_Id) MI
			ON PM.Id = MI.Model_Id
			CROSS JOIN OXO_Programme_Pack PK
			WHERE PM.Programme_Id = @p_prog_id
			AND PM.Active = 1
			AND PK.Programme_Id = @p_prog_id
			GROUP BY  PM.ID
		),
		SET_B AS
		(
			SELECT COUNT(*) AS RecCount, Model_Id AS ModelId
			FROM dbo.FN_OXO_Data_Get_PCK_Global(@p_doc_id, @_model_id)
			WHERE OXO_Code IS NOT NULL
			GROUP BY Model_Id
		),
		SET_C AS
		(
			SELECT A.ModelId, A.RecCount - ISNULL(B.RecCount,0) Diff
			FROM SET_A A 
			LEFT OUTER JOIN SET_B B
			ON A.ModelId = B.ModelId
		)		
  		INSERT INTO OXO_programme_Rule_Result (
			  OXO_Doc_Id, Programme_Id, Object_Level, Object_Id, Rule_Id, 
			  Model_Id, Result_Info, Rule_Result, Created_By, Created_On)
		SELECT @p_doc_id, @p_prog_id, @p_mode, @p_object_id, @p_Rule_Id, C.ModelId, 
			  'Pack Header Section: ' + CAST(diff AS NVARCHAR(6)), 0, 'system', GETDATE()
		FROM SET_C C
		WHERE Diff > 0
	END
END
ELSE
BEGIN
	IF (@p_mode = 'm')
	BEGIN
		SET @_model_id = dbo.OXO_ModelIdString_Get(@p_doc_id, @p_mode, @p_object_id);
		
		-- find PCK features with empty cells
		WITH SET_A AS
		(
			SELECT COUNT(*) AS RecCount, PM.ID AS ModelId
			FROM OXO_Archived_Programme_Model PM
			INNER JOIN dbo.FN_SPLIT_MODEL_IDS(@_model_Id) MI
			ON PM.Id = MI.Model_Id
			CROSS JOIN OXO_Archived_Programme_Pack PK
			WHERE PM.Programme_Id = @p_prog_id
			AND PM.Doc_Id = @p_doc_id
			AND PM.Active = 1
			AND PK.Programme_Id = @p_prog_id	
			AND PK.Doc_Id = @p_doc_id	
			GROUP BY  PM.ID
		),
		SET_B AS
		(
			SELECT COUNT(*) AS RecCount, Model_Id AS ModelId
			FROM dbo.FN_OXO_Data_Get_PCK_Market(@p_doc_id, null, @p_object_id, @_model_id)
			WHERE OXO_Code IS NOT NULL					-- market_group_id
			GROUP BY Model_Id
		),
		SET_C AS
		(
			SELECT A.ModelId, A.RecCount - ISNULL(B.RecCount,0) Diff
			FROM SET_A A 
			LEFT OUTER JOIN SET_B B
			ON A.ModelId = B.ModelId
		)		
  		INSERT INTO OXO_programme_Rule_Result (
			  OXO_Doc_Id, Programme_Id, Object_Level, Object_Id, Rule_Id, 
			  Model_Id, Result_Info, Rule_Result, Created_By, Created_On)
		SELECT @p_doc_id, @p_prog_id, @p_mode, @p_object_id, @p_Rule_Id, C.ModelId, 
			  'Pack Header Section: ' + CAST(diff AS NVARCHAR(6)), 0, 'system', GETDATE()
		FROM SET_C C
		WHERE Diff > 0
	END
	ELSE IF (@p_mode = 'mg')
	BEGIN
		SET @_model_id = dbo.OXO_ModelIdString_Get(@p_doc_id, @p_mode, @p_object_id);
		
		WITH SET_A AS
		(
			SELECT COUNT(*) AS RecCount, PM.ID AS ModelId
			FROM OXO_Archived_Programme_Model PM
			INNER JOIN dbo.FN_SPLIT_MODEL_IDS(@_model_Id) MI
			ON PM.Id = MI.Model_Id
			CROSS JOIN OXO_Archived_Programme_Pack PK
			WHERE PM.Programme_Id = @p_prog_id
			AND PM.Doc_Id = @p_doc_id
			AND PM.Active = 1
			AND PK.Programme_Id = @p_prog_id
			AND PK.Doc_Id = @p_doc_id
			GROUP BY  PM.ID
		),
		SET_B AS
		(
			SELECT COUNT(*) AS RecCount, Model_Id AS ModelId
			FROM dbo.FN_OXO_Data_Get_PCK_MarketGroup(@p_doc_id, @p_object_id, @_model_id)
			WHERE OXO_Code IS NOT NULL
			GROUP BY Model_Id
		),
		SET_C AS
		(
			SELECT A.ModelId, A.RecCount - ISNULL(B.RecCount,0) Diff
			FROM SET_A A 
			LEFT OUTER JOIN SET_B B
			ON A.ModelId = B.ModelId
		)		
  		INSERT INTO OXO_programme_Rule_Result (
			  OXO_Doc_Id, Programme_Id, Object_Level, Object_Id, Rule_Id, 
			  Model_Id, Result_Info, Rule_Result, Created_By, Created_On)
		SELECT @p_doc_id, @p_prog_id, @p_mode, @p_object_id, @p_Rule_Id, C.ModelId, 
			  'Pack Header Section: ' + CAST(diff AS NVARCHAR(6)), 0, 'system', GETDATE()
		FROM SET_C C
		WHERE Diff > 0
	END
	ELSE
	BEGIN
		SET @_model_id = dbo.OXO_ModelIdString_Get(@p_doc_id, @p_mode, @p_object_id);
		
		WITH SET_A AS
		(
			SELECT COUNT(*) AS RecCount, PM.ID AS ModelId
			FROM OXO_Archived_Programme_Model PM
			INNER JOIN dbo.FN_SPLIT_MODEL_IDS(@_model_Id) MI
			ON PM.Id = MI.Model_Id
			CROSS JOIN OXO_Archived_Programme_Pack PK
			WHERE PM.Programme_Id = @p_prog_id
			AND PM.Doc_Id = @p_doc_id
			AND PM.Active = 1
			AND PK.Programme_Id = @p_prog_id
			AND PK.Doc_Id = @p_doc_id
			GROUP BY  PM.ID
		),
		SET_B AS
		(
			SELECT COUNT(*) AS RecCount, Model_Id AS ModelId
			FROM dbo.FN_OXO_Data_Get_PCK_Global(@p_doc_id, @_model_id)
			WHERE OXO_Code IS NOT NULL
			GROUP BY Model_Id
		),
		SET_C AS
		(
			SELECT A.ModelId, A.RecCount - ISNULL(B.RecCount,0) Diff
			FROM SET_A A 
			LEFT OUTER JOIN SET_B B
			ON A.ModelId = B.ModelId
		)		
  		INSERT INTO OXO_programme_Rule_Result (
			  OXO_Doc_Id, Programme_Id, Object_Level, Object_Id, Rule_Id, 
			  Model_Id, Result_Info, Rule_Result, Created_By, Created_On)
		SELECT @p_doc_id, @p_prog_id, @p_mode, @p_object_id, @p_Rule_Id, C.ModelId, 
			  'Pack Header Section: ' + CAST(diff AS NVARCHAR(6)), 0, 'system', GETDATE()
		FROM SET_C C
		WHERE Diff > 0
	END
END

