
CREATE PROCEDURE [dbo].[OXO_Permission_Delete] 
  @p_Id int
AS
	
  DELETE 
  FROM dbo.OXO_Permission 
  WHERE Id = @p_Id;



