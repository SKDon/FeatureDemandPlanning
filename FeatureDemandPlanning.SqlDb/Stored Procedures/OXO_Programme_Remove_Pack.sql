CREATE PROCEDURE [dbo].[OXO_Programme_Remove_Pack] 
  @p_prog_id int,
  @p_doc_id int,
  @p_pack_id int
AS

  -- need to detect if this is archieve	
  DECLARE @p_archived BIT;
  	
  SELECT @p_archived = Archived 
  FROM OXO_Doc 
  WHERE Id = @p_doc_id	
  AND Programme_Id = @p_prog_id;	
	
  IF (ISNULL(@p_archived,0) = 0)
    BEGIN
	  DELETE 
	  FROM OXO_Pack_Feature_Link
	  WHERE Programme_Id = @p_prog_id		
	  AND Pack_Id = @p_pack_id; 
	  
	  DELETE 
	  FROM dbo.OXO_Programme_Pack
	  WHERE id = @p_pack_id
	  AND Programme_Id = @p_prog_id;
	END  
  ELSE	
    BEGIN
	  DELETE 
	  FROM OXO_Archived_Pack_Feature_Link
	  WHERE Programme_Id = @p_prog_id	
	  AND doc_id = 	@p_doc_id
	  AND Pack_Id = @p_pack_id; 
	  
	  DELETE 
	  FROM dbo.OXO_Archived_Programme_Pack
	  WHERE id = @p_pack_id
	  and doc_id = @p_doc_id
	  AND Programme_Id = @p_prog_id;
	END  
 
  UPDATE T1
  SET T1.Active = 0
  FROM dbo.OXO_Item_Data_PCK AS T1
  INNER JOIN dbo.OXO_Doc AS T2
  ON T1.OXO_Doc_Id = T2.Id
  WHERE T2.Id = @p_doc_id
  AND T2.Programme_Id = @p_prog_id
  AND T1.Pack_Id = @p_pack_id;
  
  UPDATE T1
  SET T1.Active = 0
  FROM dbo.OXO_Item_Data_FPS AS T1
  INNER JOIN dbo.OXO_Doc AS T2
  ON T1.OXO_Doc_Id = T2.Id
  WHERE T2.Id = @p_doc_id
  AND T2.Programme_Id = @p_prog_id
  AND T1.Pack_Id = @p_pack_id;

