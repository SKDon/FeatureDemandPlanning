CREATE PROCEDURE [OXO_Programme_File_Delete] 
  @p_Id int
AS
	
  DELETE 
  FROM dbo.OXO_Programme_File 
  WHERE Id = @p_Id;

