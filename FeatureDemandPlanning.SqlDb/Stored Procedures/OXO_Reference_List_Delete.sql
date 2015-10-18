
CREATE PROCEDURE [dbo].[OXO_Reference_List_Delete] 
  @p_Id int
AS
	
  DELETE 
  FROM dbo.OXO_Reference_List 
  WHERE Id = @p_Id;



