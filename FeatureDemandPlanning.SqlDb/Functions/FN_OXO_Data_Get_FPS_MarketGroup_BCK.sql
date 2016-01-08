CREATE FUNCTION [dbo].[FN_OXO_Data_Get_FPS_MarketGroup_BCK] 
(
  @p_doc_id INT,
  @p_marketgroup_id INT,
  @p_model_ids NVARCHAR(MAX)
)
RETURNS TABLE
AS
RETURN 
(
	WITH Models AS
	(
		SELECT Model_Id FROM dbo.FN_SPLIT_MODEL_IDS(@p_model_ids)
	),
	Generic AS
	(
		SELECT OD.Feature_Id, OD.Pack_Id, OD.Model_Id, OD.OXO_Code AS OXO_Code 
		FROM OXO_Item_Data_FPS OD WITH(NOLOCK) 
		INNER JOIN Models M WITH(NOLOCK) 
		ON OD.Model_Id = M.Model_Id
		WHERE OD.OXO_Doc_Id = @p_doc_id
		AND OD.Market_Id = -1
		AND OD.Active = 1
	),
	MKGroup AS
	(
		SELECT OD.Feature_Id, OD.Pack_Id, OD.Model_Id, OD.OXO_Code AS OXO_Code 
		FROM OXO_Item_Data_FPS OD WITH(NOLOCK) 
		INNER JOIN Models M WITH(NOLOCK) 
		ON OD.Model_Id = M.Model_Id
		WHERE OD.OXO_Doc_Id = @p_doc_id
		AND OD.Market_Group_Id = @p_marketgroup_id
		AND OD.Active = 1
	)
	SELECT G.Feature_Id, G.Pack_Id, G.Model_Id, ISNULL(M.OXO_Code, G.OXO_Code + '*') AS OXO_Code
	FROM Generic G
	LEFT OUTER JOIN MKGroup M
	ON G.Feature_Id = M.Feature_Id
	AND G.Pack_Id = M.Pack_Id
	AND G.Model_Id = M.Model_Id		

)