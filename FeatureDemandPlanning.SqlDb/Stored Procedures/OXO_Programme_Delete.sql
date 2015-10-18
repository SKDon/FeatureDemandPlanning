
CREATE PROCEDURE [dbo].[OXO_Programme_Delete] 
  @p_Id int
AS
	
  DELETE 
  FROM dbo.OXO_Programme 
  WHERE Id = @p_Id;



