CREATE PROCEDURE [OXO_ChangeDiary_Delete] 
  @p_Id int,
  @p_prog_Id int
AS
	
	DELETE       	     
    FROM dbo.OXO_Change_Diary
	WHERE Id = @p_Id
	AND Programme_Id = @p_prog_Id;

