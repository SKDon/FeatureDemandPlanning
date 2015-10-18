
CREATE PROCEDURE [dbo].[OXO_Market_Delete] 
  @p_Id int
AS
	
  DELETE 
  FROM dbo.OXO_Master_Country 
  WHERE Id = @p_Id;



