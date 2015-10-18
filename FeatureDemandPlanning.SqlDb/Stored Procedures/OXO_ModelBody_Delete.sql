
CREATE PROCEDURE [dbo].[OXO_ModelBody_Delete] 
  @p_Id int
AS
	
  DELETE 
  FROM dbo.OXO_Programme_Body 
  WHERE Id = @p_Id;



