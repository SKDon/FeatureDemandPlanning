
CREATE PROCEDURE [dbo].[OXO_Programme_Rule_Result_Delete] 
  @p_Id int
AS
	
  DELETE 
  FROM dbo.OXO_Programme_Rule_Result 
  WHERE Id = @p_Id;



