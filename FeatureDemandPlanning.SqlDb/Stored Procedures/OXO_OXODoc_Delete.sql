
CREATE PROCEDURE [dbo].[OXO_OXODoc_Delete] 
  @p_Id int
AS
	
  DELETE 
  FROM dbo.OXO_Doc 
  WHERE Id = @p_Id;



