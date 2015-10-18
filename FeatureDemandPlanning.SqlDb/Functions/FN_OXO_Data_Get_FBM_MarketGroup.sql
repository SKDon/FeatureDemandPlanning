CREATE FUNCTION [FN_OXO_Data_Get_FBM_MarketGroup] 
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
		SELECT OD.Feature_Id, 0 AS Pack_Id, OD.Model_Id, OD.OXO_Code 
	    FROM OXO_Item_Data_FBM OD WITH(NOLOCK) 
	    INNER JOIN Models M WITH(NOLOCK)
	    ON OD.Model_Id = M.Model_Id
		WHERE OD.OXO_Doc_Id = @p_doc_id
		AND OD.Market_Id = -1
		AND OD.Active = 1
	),
	MkGroup AS
	(
		SELECT OD.Feature_Id, 0 AS Pack_Id, OD.Model_Id, OD.OXO_Code 
	    FROM OXO_Item_Data_FBM OD WITH(NOLOCK) 
	    INNER JOIN Models M WITH(NOLOCK)
	    ON OD.Model_Id = M.Model_Id
		WHERE OD.OXO_Doc_Id = @p_doc_id
		AND OD.Market_group_Id = @p_marketgroup_id
		AND OD.Active = 1	
	),
	Combine AS
	(
		SELECT Feature_Id, Model_Id FROM Generic
		UNION
		SELECT Feature_Id, Model_Id FROM MkGroup
	)
	
	SELECT C.Feature_Id, 
		   0 AS Pack_Id, 
	       C.Model_Id, 
	       ISNULL(M.OXO_Code, G.OXO_Code + '*') AS OXO_Code 
	FROM Combine C
	LEFT OUTER JOIN Generic G
	ON C.Model_Id = G.Model_Id
	AND C.Feature_Id = G.Feature_Id   
	LEFT OUTER JOIN MkGroup M
	ON C.Model_Id = M.Model_Id
	AND C.Feature_Id = M.Feature_Id   
)
