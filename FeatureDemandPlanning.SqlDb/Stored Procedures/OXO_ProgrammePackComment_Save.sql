CREATE PROCEDURE [OXO_ProgrammePackComment_Save] 
   @p_progid  int,
   @p_docid  int,   
   @p_packid  int,  
   @p_comment  nvarchar(2000),
   @p_CDSID nvarchar(10)
AS

  DECLARE @p_archived BIT;
  	
  SELECT @p_archived = Archived
  FROM OXO_Doc 
  WHERE Id = @p_docid	
  AND Programme_Id = @p_progid;
	
  IF ISNULL(@p_archived, 0) = 0 	  
    UPDATE OXO_Programme_Pack
      SET Extra_Info = @p_comment,
          Updated_By = @p_CDSID,
          Last_Updated = GetDate()
    WHERE Programme_Id = @p_progid
      AND Id =  @p_packid
  ELSE
    UPDATE OXO_Archived_Programme_Pack
      SET Extra_Info = @p_comment,
          Updated_By = @p_CDSID,
          Last_Updated = GetDate()
    WHERE Programme_Id = @p_progid
      AND Id =  @p_packid
      AND Doc_Id = @p_docid