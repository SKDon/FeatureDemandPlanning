
CREATE PROCEDURE [dbo].[OXO_Programme_MarketGroup_Delete] 
  @p_Id int
AS
	
  DELETE 
  FROM dbo.OXO_Programme_MarketGroup_Market_Link
  WHERE Market_Group_Id = @p_Id;
  	
  DELETE 
  FROM dbo.OXO_Programme_MarketGroup 
  WHERE Id = @p_Id;



