CREATE PROCEDURE [dbo].[OXO_OXODoc_FBMValidateEmptyCells]
  @p_doc_id int,
  @p_prog_id int,
  @p_rule_id int
AS
  
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
		FROM OXO_Item_Data_FBM
		WHERE Market_Id = -1
		AND OXO_Doc_Id = @p_doc_id
		AND OXO_Code IS NOT NULL
		AND Active = 1
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
	SELECT @p_doc_id, @p_prog_id, 'g', -1, @p_Rule_Id, C.ModelId, 
	      'FBM: ' + CAST(diff AS NVARCHAR(6)), 0, 'system', GETDATE()
	FROM SET_C C
	WHERE Diff > 0

