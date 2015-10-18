CREATE Procedure [OXO_Chain_Down_FBM_GetMany]
@p_doc_id int,
@p_prog_id int,
@p_model_id int,
@p_feature_id int,
@p_level nvarchar(10),
@p_object_id int=0
AS

  DECLARE @_generic_value NVARCHAR(10);
  DECLARE @_group_value NVARCHAR(10);
  
  SELECT @_generic_value = D.OXO_Code 	
  FROM OXO_Item_Data_FBM D WITH(NOLOCK)
  WHERE D.OXO_Doc_Id = @p_doc_id
  AND D.Model_Id = @p_model_id
  AND D.Feature_Id = @p_feature_id
  AND D.Market_Id = -1;
    
  IF @p_level = 'g'
  BEGIN 
  
	WITH SET_A AS
	(
		SELECT DISTINCT
			   G.Market_Group_Id, G.Market_Group_Name AS LevelName, 
			   COALESCE(D.OXO_Code, @_generic_value + '*', '')  AS OXOCode, 
			   G.Display_Order  
		FROM dbo.FN_Programme_Markets_Get(@p_prog_id, @p_doc_id) G
		LEFT JOIN OXO_Item_Data_FBM D WITH(NOLOCK)
		ON G.Market_Group_Id  = D.Market_Group_Id 
		AND D.Section = 'FBM'
		AND D.OXO_Doc_Id = @p_doc_id
		AND D.Feature_Id = @p_feature_id
		AND D.Model_Id = @p_model_id 
		AND D.Active = 1
		WHERE G.Programme_Id = @p_prog_id
	), SET_B AS
	(
		SELECT DISTINCT GG.Market_Group_Id 
		FROM OXO_ITEM_DATA_MBM MBM WITH(NOLOCK)
		INNER JOIN dbo.FN_Programme_Markets_Get(@p_prog_id, @p_doc_id) GG
		ON MBM.Market_Id = GG.Market_Id 
		WHERE Section = 'MBM'
		AND OXO_Doc_Id = @p_doc_id
		AND OXO_Code = 'Y'
		AND Model_Id = @p_model_id 
		AND GG.Market_Group_Id = MBM.Market_Group_Id
	)
	SELECT A.Market_Group_Id, A.LevelName, 
		   A.OXOCode, A.Display_Order  
	FROM SET_A A
	INNER JOIN SET_B B
	ON A.Market_Group_Id = B.Market_Group_Id
	ORDER BY A.Display_Order;
	
  END  
  
  IF @p_level = 'mg'
  BEGIN 
  
	SELECT @_group_value = D.OXO_Code 	
    FROM OXO_Item_Data_FBM D WITH(NOLOCK)
    WHERE D.Section = 'FBM'
    AND D.OXO_Doc_Id = @p_doc_id
    AND D.Model_Id = @p_model_id
    AND D.Feature_Id = @p_feature_id
    AND D.Market_Group_Id = @p_object_id    
    AND D.Active = 1;	
  
	SELECT DISTINCT
		   MGM.Market_Name AS LevelName,
	       COALESCE(D.OXO_Code, @_group_value + '**', @_generic_value + '*', '')  AS OXOCode  
	FROM dbo.FN_Programme_Markets_Get(@p_prog_id, @p_doc_id) MGM
	LEFT JOIN OXO_Item_Data_FBM D WITH(NOLOCK)
	ON MGM.Market_Id = D.Market_Id 
	AND D.Section = 'FBM'
	AND D.OXO_Doc_Id = @p_doc_id
	AND D.Feature_Id = @p_feature_id
	AND D.Model_Id = @p_model_id 
	AND Active = 1
	WHERE MGM.Programme_Id = @p_prog_id
	AND MGM.Market_Group_Id = @p_object_id
	AND EXISTS 
	(
		SELECT 1 FROM OXO_ITEM_DATA_MBM WITH(NOLOCK)
		WHERE Section = 'MBM'
		AND OXO_Doc_Id = @p_doc_id
		AND OXO_Code = 'Y'	
		AND Model_Id = @p_model_id 
		AND Market_Id = MGM.Market_Id
		AND Active = 1
		
	)	
	ORDER BY MGM.Market_Name;
  
  END