CREATE PROCEDURE [OXO_Chain_Up_FBM_GetMany]
@p_doc_id int,
@p_prog_id int,
@p_model_id int,
@p_feature_id int,
@p_level nvarchar(10),
@p_object_id int=0

AS

  DECLARE @tempTab TABLE(Level nvarchar(20), Level_Name nvarchar(500), Level_Id int, 
                         Model_Id int, Feature_Id int, OXO_Code nvarchar(50));
  DECLARE @_generic_value NVARCHAR(10);
  DECLARE @_group_value NVARCHAR(10);
  DECLARE @_market_value NVARCHAR(10);
  
  -- Do generic 
    INSERT INTO @tempTab VALUES ('Generic', 'Global Generic', -1, @p_model_id, @p_feature_id, null);
    SELECT @_generic_value = ISNULL(D.OXO_Code, '') 	
    FROM  @tempTab T
    LEFT JOIN OXO_Item_Data_FBM D WITH(NOLOCK)
    ON T.Model_Id = D.Model_Id
    AND D.Section = 'FBM'	
    AND D.OXO_Doc_Id = @p_doc_id
    AND T.Feature_Id = D.Feature_Id
    AND D.Market_Id = -1       
    AND D.Active = 1	  
    WHERE T.Level = 'Generic';		 	 	 
    UPDATE @tempTab SET OXO_Code = @_generic_value WHERE Level = 'Generic';

  IF @p_level = 'mg'
  BEGIN
	INSERT INTO @tempTab 
		SELECT Top 1 'Group', Market_Group_Name, @p_object_id, @p_model_id, @p_feature_id, null
		FROM dbo.FN_Programme_Markets_Get(@p_prog_id, @p_doc_id) 
		WHERE Programme_Id = @p_prog_id
		AND Market_Group_Id = @p_object_id;	  
	 
	SELECT @_group_value = COALESCE(DG.OXO_Code, @_generic_value + '*', '') 	
		FROM  @tempTab T
		LEFT JOIN OXO_Item_Data_FBM DG WITH(NOLOCK)
		ON T.Model_Id = DG.Model_Id
		AND DG.Section = 'FBM'	
		AND DG.OXO_Doc_Id = @p_doc_id		
		AND T.Feature_Id = DG.Feature_Id
		AND DG.Market_Group_Id = T.Level_Id		
		AND DG.Active = 1	  
		AND T.Level = 'Group';
		
	UPDATE @tempTab SET OXO_Code = @_group_value WHERE Level = 'Group';	     
  END 
  
  IF (@p_level = 'm' )
  BEGIN
     INSERT INTO @tempTab 
		 SELECT Top 1 'Group', Market_Group_Name, Market_Group_Id, @p_model_id, @p_feature_id, null
		 FROM dbo.FN_Programme_Markets_Get(@p_prog_id, @p_doc_id)
		 WHERE Programme_Id = @p_prog_id
		 AND Market_Id = @p_object_id;	 
	 
	 SELECT @_group_value = DG.OXO_Code	
		FROM  @tempTab T
		LEFT JOIN OXO_Item_Data_FBM DG WITH(NOLOCK)
		ON T.Model_Id = DG.Model_Id
		AND DG.Section = 'FBM'	
		AND DG.OXO_Doc_Id = @p_doc_id
		AND T.Feature_Id = DG.Feature_Id
		AND DG.Market_Group_Id = T.Level_Id		
		AND DG.Active = 1	  
		AND T.Level = 'Group';
		
	UPDATE @tempTab SET OXO_Code = COALESCE(@_group_value, @_generic_value + '*', '') WHERE Level = 'Group';
	 
	INSERT INTO @tempTab 
		 SELECT Top 1 'Market', Market_Name, @p_object_id, @p_model_id, @p_feature_id, null
		 FROM dbo.FN_Programme_Markets_Get(@p_prog_id, @p_doc_id)
		 WHERE Programme_Id = @p_prog_id
		 AND Market_Id = @p_object_id;	 	
	 
	SELECT @_market_value = COALESCE(DM.OXO_Code, @_group_value + '**', @_generic_value + '*', '') 	
		FROM  @tempTab T
		LEFT JOIN OXO_Item_Data_FBM DM
		ON T.Model_Id = DM.Model_Id
		AND DM.Section = 'FBM'	
		AND DM.OXO_Doc_Id = @p_doc_id
		AND T.Feature_Id = DM.Feature_Id
		AND DM.Market_Id = T.Level_Id	
		AND DM.Active = 1	  
		AND T.Level = 'Market';

	UPDATE @tempTab SET OXO_Code = @_market_value WHERE Level = 'Market';
	
  END;

  SELECT T.Level, T.Level_Name AS LevelName, T.Model_Id as ModelId, 
         T.Feature_Id as FeatureId, T.OXO_Code AS OXOCode
  FROM @tempTab T