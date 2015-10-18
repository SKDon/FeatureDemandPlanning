
CREATE PROCEDURE [dbo].[OXO_Pack_Delete] 
  @p_ID int
AS

  DELETE  
  FROM dbo.OXO_Pack_Feature_Link
  WHERE Pack_Id = @p_ID;
   		
  DELETE 
  FROM dbo.OXO_Programme_Pack
  WHERE ID = @p_ID;



