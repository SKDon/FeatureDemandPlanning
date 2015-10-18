CREATE PROCEDURE [OXO_ExportRequest_Delete] 
  @p_Id int
AS
	
  DELETE 
  FROM dbo.OXO_Export_Queue 
  WHERE Id = @p_Id;