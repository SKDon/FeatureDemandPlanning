
CREATE PROCEDURE [dbo].[OXO_Vehicle_Delete] 
  @p_Id int
AS
	
  DELETE 
  FROM dbo.OXO_Vehicle 
  WHERE Id = @p_Id;



