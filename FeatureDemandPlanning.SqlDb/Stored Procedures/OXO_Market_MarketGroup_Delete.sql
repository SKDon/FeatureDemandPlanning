CREATE PROCEDURE [dbo].[OXO_Market_MarketGroup_Delete] 
  @p_GroupId int,
  @p_MarketId int
AS
	
  DELETE 
  FROM dbo.OXO_Master_MarketGroup_Market_Link
  WHERE Market_Group_Id = @p_GroupId
  AND Country_Id = @p_MarketId;

