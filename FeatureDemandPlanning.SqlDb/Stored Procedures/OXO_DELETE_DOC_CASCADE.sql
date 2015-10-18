CREATE PROCEDURE [dbo].[OXO_DELETE_DOC_CASCADE]
  @p_doc_id int
AS

	DELETE FROM OXO_Item_Data_Hist 
	WHERE Item_Id IN (SELECT ID FROM OXO_Item_Data WHERE OXO_Doc_ID = @p_doc_id)
	DELETE FROM OXO_Item_Data WHERE OXO_Doc_ID = @p_doc_id
	DELETE FROM OXO_Change_Set where OXO_Doc_Id = @p_doc_id
	DELETE FROM OXO_DOC WHERE Id = @p_doc_id

