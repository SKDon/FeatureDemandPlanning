
CREATE PROCEDURE [dbo].[OXO_Feature_Delete] 
  @p_Id int
AS
	
  DELETE 
  FROM dbo.OXO_Feature_Ext 
  WHERE Id = @p_Id;



