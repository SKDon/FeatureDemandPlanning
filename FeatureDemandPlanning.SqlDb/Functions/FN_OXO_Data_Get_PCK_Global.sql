CREATE FUNCTION [FN_OXO_Data_Get_PCK_Global] 
(
  @p_doc_id INT,
  @p_model_ids NVARCHAR(MAX)
)
RETURNS TABLE
AS
RETURN 
(
	WITH Models AS
	(
		SELECT Model_Id FROM dbo.FN_SPLIT_MODEL_IDS(@p_model_ids)	
	)
	SELECT 0 AS Feature_Id, OD.Pack_Id AS Pack_Id, OD.Model_Id AS Model_Id, OD.OXO_Code AS OXO_Code 
	FROM OXO_Item_Data_PCK OD WITH(NOLOCK) 
	INNER JOIN Models M WITH(NOLOCK) 
	ON OD.Model_Id = M.Model_Id 
	WHERE OD.OXO_Doc_Id = @p_doc_id
	AND OD.Market_Id = -1
	AND OD.Active = 1
)
