
CREATE PROCEDURE [dbo].[OXO_Programme_Rule_Delete] 
  @p_Id int
AS
	
  DELETE 
  FROM dbo.OXO_Programme_Rule 
  WHERE Id = @p_Id;



