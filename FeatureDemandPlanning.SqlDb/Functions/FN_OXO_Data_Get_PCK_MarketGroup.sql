CREATE FUNCTION [FN_OXO_Data_Get_PCK_MarketGroup] 
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
	(		SELECT OD.Pack_Id AS Pack_Id, OD.Model_Id AS Model_Id, OD.OXO_Code AS OXO_Code 
		FROM OXO_Item_Data_PCK OD WITH(NOLOCK) 
		INNER JOIN Models M WITH(NOLOCK) 
		ON OD.Model_Id = M.Model_Id 
		WHERE OD.OXO_Doc_Id = @p_doc_id
		AND OD.Market_Id = -1
		AND OD.Active = 1
	),
	MKGroup AS
	(
		SELECT OD.Pack_Id AS Pack_Id, OD.Model_Id AS Model_Id, OD.OXO_Code AS OXO_Code 
		FROM OXO_Item_Data_PCK OD WITH(NOLOCK) 
		INNER JOIN Models M WITH(NOLOCK) 
		ON OD.Model_Id = M.Model_Id 
		WHERE OD.OXO_Doc_Id = @p_doc_id
		AND OD.Market_Group_Id = @p_marketgroup_id
		AND OD.Active = 1
	),
	Combine AS
	(
		SELECT Pack_Id, Model_Id FROM Generic
		UNION
		SELECT Pack_Id, Model_Id FROM MKGroup
	)
	SELECT 0 as Feature_Id, C.Pack_Id, C.Model_Id, ISNULL(M.OXO_Code, G.OXO_Code + '*') AS OXO_Code
	FROM Combine C
	LEFT OUTER JOIN Generic G
	ON C.Pack_Id = G.Pack_Id
	AND C.Model_Id = G.Model_Id
	LEFT OUTER JOIN MKGroup M
	ON C.Pack_Id = M.Pack_Id
	AND C.Model_Id = M.Model_Id
)
