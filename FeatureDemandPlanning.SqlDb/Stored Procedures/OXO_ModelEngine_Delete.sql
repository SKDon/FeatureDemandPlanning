

CREATE PROCEDURE [dbo].[OXO_ModelEngine_Delete] 
  @p_Id int
AS
	
  DELETE 
  FROM dbo.OXO_Programme_Engine 
  WHERE Id = @p_Id;



