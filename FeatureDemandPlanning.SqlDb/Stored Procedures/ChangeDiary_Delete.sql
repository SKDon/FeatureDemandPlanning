CREATE PROCEDURE [dbo].[ChangeDiary_Delete] 
  @p_Id int
AS
	
  DELETE 
  FROM dbo.OXO_Change_Diary 
  WHERE Id = @p_Id;

