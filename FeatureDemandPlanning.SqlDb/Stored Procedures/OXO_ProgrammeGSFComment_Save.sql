

CREATE PROCEDURE [dbo].[OXO_ProgrammeGSFComment_Save] 
   @p_progid  int,
   @p_docid int,
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
    UPDATE OXO_Programme_GSF_Link 
    SET Comment = @p_comment,
	   CDSID = @p_CDSID
    WHERE Programme_Id = @p_progid
    AND Feature_Id =  @p_featureid;
  ELSE
    UPDATE OXO_Archived_Programme_GSF_Link 
      SET Comment = @p_comment,
          CDSID = @p_CDSID
    WHERE Programme_Id = @p_progid
      AND Feature_Id =  @p_featureid
      AND Doc_Id = @p_docid

