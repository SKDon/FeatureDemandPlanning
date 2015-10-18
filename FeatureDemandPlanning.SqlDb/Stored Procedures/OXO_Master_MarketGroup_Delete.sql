
CREATE PROCEDURE [dbo].[OXO_Master_MarketGroup_Delete] 
  @p_Id int
AS
	
  DELETE 
  FROM dbo.OXO_Master_MarketGroup 
  WHERE Id = @p_Id;



