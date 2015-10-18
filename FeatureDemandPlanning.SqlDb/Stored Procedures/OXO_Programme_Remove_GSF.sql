CREATE PROCEDURE [dbo].[OXO_Programme_Remove_GSF] 
  @p_prog_id int,
  @p_doc_id int,
  @p_feat_id int,
  @p_cdsid nvarchar(10) = null,
  @p_changeset_id int
AS

  DECLARE @p_archived BIT;
  	
  SELECT @p_archived = Archived 
  FROM OXO_Doc 
  WHERE Id = @p_doc_id	
  AND Programme_Id = @p_prog_id;	
   
  IF ISNULL(@p_archived, 0) = 0
  BEGIN 
	  -- need to do an update before we can a delete 	
	  UPDATE dbo.OXO_Programme_GSF_Link
	  SET CDSID = @p_cdsid,
		  ChangeSet_Id = @p_changeset_id  
	  WHERE Programme_Id = @p_prog_id
	  AND Feature_Id = @p_feat_id; 	
		
	  DELETE 
	  FROM dbo.OXO_Programme_GSF_Link
	  WHERE Programme_Id = @p_prog_id
	  AND Feature_Id = @p_feat_id;
	  	  
  END
  ELSE
  BEGIN 
	  -- need to do an update before we can a delete 	
	  UPDATE dbo.OXO_Archived_Programme_GSF_Link
	  SET CDSID = @p_cdsid, 
		  ChangeSet_Id = @p_changeset_id  
	  WHERE Doc_Id = @p_doc_id 
	  AND Programme_Id = @p_prog_id
	  AND Feature_Id = @p_feat_id; 	
		
	  DELETE 
	  FROM dbo.OXO_Archived_Programme_GSF_Link
	  WHERE Doc_Id = @p_doc_id 
	  AND Programme_Id = @p_prog_id
	  AND Feature_Id = @p_feat_id;	  
  END 
  
  UPDATE T1
  SET T1.Active = 0
  FROM dbo.OXO_Item_Data_GSF AS T1
  INNER JOIN dbo.OXO_Doc AS T2
  ON T1.OXO_Doc_Id = T2.Id
  WHERE T1.OXO_Doc_Id = @p_doc_id 
  AND T2.Programme_Id = @p_prog_id
  AND T1.Feature_Id = @p_feat_id;

