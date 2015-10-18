CREATE PROCEDURE [OXO_ProgrammeFeatureComment_Save] 
   @p_progid  int,
   @p_docid  int,   
   @p_featureid  int,  
   @p_comment  nvarchar(2000),
   @p_CDSID nvarchar(10)
AS

  DECLARE @p_archived BIT;
  	
  SELECT @p_archived = Archived
  FROM OXO_Doc 
  WHERE Id = @p_docid	
  AND Programme_Id = @p_progid;
	
  IF ISNULL(@p_archived, 0) = 0 	  
  BEGIN
	UPDATE OXO_Programme_Feature_Link 
	  SET Comment = @p_comment,
		  CDSID = @p_CDSID
	WHERE Programme_Id = @p_progid
	  AND Feature_Id =  @p_featureid;
	  
	UPDATE OXO_Pack_Feature_Link 
	  SET Comment = @p_comment,
		  CDSID = @p_CDSID
	WHERE Programme_Id = @p_progid
	  AND Feature_Id =  @p_featureid;
  
  END               
  ELSE
  BEGIN
    UPDATE OXO_Archived_Programme_Feature_Link 
      SET Comment = @p_comment,
          CDSID = @p_CDSID
    WHERE Programme_Id = @p_progid
      AND Feature_Id =  @p_featureid
      AND Doc_Id = @p_docid;
    
    UPDATE OXO_Archived_Pack_Feature_Link 
      SET Comment = @p_comment,
          CDSID = @p_CDSID
    WHERE Programme_Id = @p_progid
      AND Feature_Id =  @p_featureid
      AND Doc_Id = @p_docid;  
      
  END

