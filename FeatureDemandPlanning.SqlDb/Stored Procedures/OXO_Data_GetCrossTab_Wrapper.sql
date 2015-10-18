CREATE PROCEDURE [dbo].[OXO_Data_GetCrossTab_Wrapper] 
  @p_make nvarchar(50),
  @p_doc_id int,
  @p_prog_id int,
  @p_section nvarchar(50),
  @p_mode nvarchar(50),
  @p_object_id int,
  @p_model_ids nvarchar(MAX),
  @p_export bit = 0
AS

  DECLARE @p_archived BIT;
  	
  SELECT @p_archived = Archived 
  FROM OXO_Doc 
  WHERE Id = @p_doc_id	
  AND Programme_Id = @p_prog_id;
   	
  IF ISNULL(@p_archived, 0) = 0
	EXEC dbo.OXO_Data_GetCrossTab @p_make,@p_doc_id,@p_prog_id,@p_section,@p_mode,@p_object_id,@p_model_ids, @p_export;
  ELSE
	EXEC dbo.OXO_Data_GetCrossTab_Archived @p_make,@p_doc_id,@p_prog_id,@p_section,@p_mode,@p_object_id,@p_model_ids, @p_export;

