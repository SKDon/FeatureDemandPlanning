CREATE PROCEDURE [OXO_Pack_Add_Feature] 
  @p_prog_id int,
  @p_doc_id int,
  @p_pack_id int,
  @p_feat_id int,
  @p_cdsid nvarchar(10),
  @p_changeset_id int
AS

  DECLARE @p_archived BIT;
  DECLARE @_count AS INT;
  DECLARE @_id INT;
  DECLARE @_comment NVARCHAR(2000);
  DECLARE @_ruleText NVARCHAR(2000);

  SELECT @p_archived = Archived 
  FROM OXO_Doc 
  WHERE Id = @p_doc_id	
  AND Programme_Id = @p_prog_id;
  
  IF ISNULL(@p_archived, 0) = 0
  BEGIN
	  SELECT @_count = COUNT(*)	
	  FROM dbo.OXO_Pack_Feature_Link
	  WHERE Pack_Id = @p_pack_id
	  AND Feature_Id = @p_feat_id;

	  IF (@_count = 0)
	  BEGIN 	
		
		INSERT INTO dbo.OXO_Pack_Feature_Link (Programme_Id, Pack_Id, Feature_Id, CDSID, ChangeSet_Id)
		VALUES (@p_prog_id, @p_pack_id, @p_feat_id, @p_cdsid, @p_changeset_id);
	 
		-- need to copy over any rule/info
		SET @_id = SCOPE_IDENTITY();
		SELECT @_comment = Comment, 
		       @_ruleText = Rule_Text
		FROM OXO_Programme_Feature_Link
		WHERE Programme_Id = @p_prog_id
		AND Feature_Id = @p_feat_id;
		
		UPDATE dbo.OXO_Pack_Feature_Link
		SET Comment = @_comment,
		    Rule_Text = @_ruleText
		WHERE Id = @_id;    
	 	
	 	--Need to sync up  the settings from main body feature setting
	 	-- either update or insert if no previous values
	 	
		UPDATE T1
		SET T1.Active = 1,
			T1.OXO_Code = CASE WHEN T3.OXO_Code IS NULL THEN T1.OXO_Code
			                   WHEN T3.OXO_Code IN ('S','NA','M') THEN 'NA'
			                   WHEN T3.OXO_Code IN ('O','(O)','P') THEN 'P'
			                   ELSE T1.OXO_Code END
		FROM dbo.OXO_Item_Data_FPS AS T1
		INNER JOIN dbo.OXO_Doc AS T2
		ON T1.OXO_Doc_Id = T2.Id
		INNER JOIN dbo.OXO_Item_Data_FBM T3
		ON T3.OXO_Doc_Id = T1.OXO_Doc_Id
		AND T3.Model_Id = T1.Model_Id
		AND T3.Feature_Id = T1.Feature_Id
		AND ISNULL(T3.Market_Id,0) = ISNULL(T1.Market_Id,0)
		AND ISNULL(T3.Market_Group_Id,0) = ISNULL(T1.Market_Group_Id,0)				
		WHERE T1.OXO_Doc_Id = @p_doc_id
		AND T2.Programme_Id = @p_prog_id
		AND T1.Pack_Id = @p_pack_id
		AND T1.Feature_Id = @p_feat_id
		
		
		INSERT INTO dbo.OXO_Item_Data_FPS (Section, OXO_Doc_Id, Model_Id, Pack_Id,
		            Feature_Id, Market_Group_Id, Market_Id, OXO_Code, Active,
		            Created_By, Created_On)               
		SELECT 'FPS', @p_doc_id, T1.Model_Id, @p_pack_id, T1.Feature_Id, T1.Market_Group_Id, T1.Market_Id,
		              CASE WHEN T1.OXO_Code IN ('S','NA','M') THEN 'NA'
		                   WHEN T1.OXO_Code IN ('O','(O)','P') THEN 'P'
		                   ELSE NULL END, 1, @p_cdsid, GetDate()
		FROM dbo.OXO_Item_Data_FBM T1
		LEFT JOIN dbo.OXO_Item_Data_FPS T2
		ON T2.OXO_Doc_Id = T1.OXO_Doc_Id
		AND T2.Model_Id = T1.Model_Id	
		AND T2.Feature_Id = T1.Feature_Id		
		AND ISNULL(T2.Market_Id,0) = ISNULL(T1.Market_Id,0)
		AND ISNULL(T2.Market_Group_Id,0) = ISNULL(T1.Market_Group_Id,0)
		AND T2.Pack_Id = @p_pack_id
		WHERE T1.OXO_Doc_Id = @p_doc_id
		AND T1.Feature_Id = @p_feat_id
		AND T2.Id IS NULL;
				
	  END
   END 
 ELSE
   BEGIN  
	  SELECT @_count = COUNT(*)	
	  FROM dbo.OXO_Archived_Pack_Feature_Link
	  WHERE Pack_Id = @p_pack_id
	  AND Feature_Id = @p_feat_id
	  AND Doc_Id = @p_doc_id;

	  IF (@_count = 0)
	  BEGIN 	
		
		INSERT INTO dbo.OXO_Archived_Pack_Feature_Link (Programme_Id, Doc_Id, Pack_Id, Feature_Id, CDSID, ChangeSet_Id)
		VALUES (@p_prog_id, @p_doc_id, @p_pack_id, @p_feat_id, @p_cdsid, @p_changeSet_id);

		-- need to copy over any rule/info		
		SET @_id = SCOPE_IDENTITY();
		
		SELECT @_comment = Comment, 
		       @_ruleText = Rule_Text
		FROM OXO_Archived_Programme_Feature_Link
		WHERE Programme_Id = @p_prog_id
		AND Doc_Id = @p_doc_id
		AND Feature_Id = @p_feat_id;
		
		UPDATE dbo.OXO_Archived_Pack_Feature_Link
		SET Comment = @_comment,
		    Rule_Text = @_ruleText
		WHERE Id = @_id;    
	 	
		UPDATE T1
		SET T1.Active = 1,
			T1.OXO_Code = CASE WHEN T3.OXO_Code IS NULL THEN T1.OXO_Code
			                   WHEN T3.OXO_Code IN ('S','NA','M') THEN 'NA'
			                   WHEN T3.OXO_Code IN ('O','(O)','P') THEN 'P'
			                   ELSE T1.OXO_Code END
		FROM dbo.OXO_Item_Data_FPS AS T1
		INNER JOIN dbo.OXO_Doc AS T2
		ON T1.OXO_Doc_Id = T2.Id
		INNER JOIN dbo.OXO_Item_Data_FBM T3
		ON T3.OXO_Doc_Id = T1.OXO_Doc_Id
		AND T3.Model_Id = T1.Model_Id
		AND T3.Feature_Id = T1.Feature_Id
		AND ISNULL(T3.Market_Id,0) = ISNULL(T1.Market_Id,0)
		AND ISNULL(T3.Market_Group_Id,0) = ISNULL(T1.Market_Group_Id,0)				
		WHERE T1.OXO_Doc_Id = @p_doc_id
		AND T2.Programme_Id = @p_prog_id
		AND T1.Pack_Id = @p_pack_id
		AND T1.Feature_Id = @p_feat_id
		
		INSERT INTO dbo.OXO_Item_Data_FPS (Section, OXO_Doc_Id, Model_Id, Pack_Id,
		            Feature_Id, Market_Group_Id, Market_Id, OXO_Code, Active,
		            Created_By, Created_On)               
		SELECT 'FPS', @p_doc_id, T1.Model_Id, @p_pack_id, T1.Feature_Id, T1.Market_Group_Id, T1.Market_Id,
		              CASE WHEN T1.OXO_Code IN ('S','NA','M') THEN 'NA'
		                   WHEN T1.OXO_Code IN ('O','(O)','P') THEN 'P'
		                   ELSE NULL END, 1, @p_cdsid, GetDate()
		FROM dbo.OXO_Item_Data_FBM T1
		LEFT JOIN dbo.OXO_Item_Data_FPS T2
		ON T2.OXO_Doc_Id = T1.OXO_Doc_Id
		AND T2.Model_Id = T1.Model_Id	
		AND T2.Feature_Id = T1.Feature_Id		
		AND ISNULL(T2.Market_Id,0) = ISNULL(T1.Market_Id,0)
		AND ISNULL(T2.Market_Group_Id,0) = ISNULL(T1.Market_Group_Id,0)
		AND T2.Pack_Id = @p_pack_id
		WHERE T1.OXO_Doc_Id = @p_doc_id
		AND T1.Feature_Id = @p_feat_id
		AND T2.Id IS NULL;
				
	  END
   END

