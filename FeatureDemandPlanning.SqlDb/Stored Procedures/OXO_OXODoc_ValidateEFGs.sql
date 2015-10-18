CREATE PROCEDURE [dbo].[OXO_OXODoc_ValidateEFGs] 
  @p_doc_id int,
  @p_prog_id int,
  @p_mode nvarchar(2),
  @p_object_id int,
  @rec_count int OUTPUT
AS

 EXEC dbo.OXO_OXODoc_ValidateEFGs_WithOutLessCode @p_doc_id, @p_prog_id, @p_mode, @p_object_id, @rec_count OUTPUT;

