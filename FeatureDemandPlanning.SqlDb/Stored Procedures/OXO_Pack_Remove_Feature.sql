CREATE PROCEDURE [OXO_Pack_Remove_Feature] 
  @p_prog_id int,
  @p_doc_id int,
  @p_pack_id int,
  @p_feat_id int,
  @p_cdsid nvarchar(10),
  @p_changeset_id int
AS
	
  DECLARE @p_archived BIT;
   	
  SELECT @p_archived = Archived 
  FROM OXO_Doc 
  WHERE Id = @p_doc_id	
  AND Programme_Id = @p_prog_id;
  	
  IF ISNULL(@p_archived, 0) = 0
  BEGIN 	
	  UPDATE dbo.OXO_Pack_Feature_Link
	  SET CDSID = @p_cdsid,
		  ChangeSet_Id = @p_changeset_id  
	  WHERE Programme_Id = @p_prog_id
	  AND Pack_Id = @p_pack_id
	  AND Feature_Id = @p_feat_id; 	
		  
	  DELETE 
	  FROM dbo.OXO_Pack_Feature_Link
	  WHERE programme_Id =  @p_prog_id
	  AND Pack_Id = @p_pack_id
	  AND Feature_Id = @p_feat_id;
  END 
  ELSE
  BEGIN
	  UPDATE dbo.OXO_Archived_Pack_Feature_Link
	  SET CDSID = @p_cdsid,
		  ChangeSet_Id = @p_changeset_id  
	  WHERE programme_Id =  @p_prog_id
	  AND Pack_Id = @p_pack_id
	  AND Feature_Id = @p_feat_id
	  AND Doc_id = @p_doc_id;
  
  	  DELETE 
	  FROM dbo.OXO_Archived_Pack_Feature_Link
	  WHERE programme_Id =  @p_prog_id
	  AND Pack_Id = @p_pack_id
	  AND Feature_Id = @p_feat_id
	  AND Doc_id = @p_doc_id;
  END
  	
  UPDATE T1
  SET T1.Active = 0
  FROM dbo.OXO_Item_Data_FPS AS T1
  INNER JOIN dbo.OXO_Doc AS T2
  ON T1.OXO_Doc_Id = T2.Id
  WHERE T1.OXO_Doc_Id = @p_doc_id 
  AND T2.Programme_Id = @p_prog_id
  AND T1.Pack_Id = @p_pack_id
  AND T1.Feature_Id = @p_feat_id;

