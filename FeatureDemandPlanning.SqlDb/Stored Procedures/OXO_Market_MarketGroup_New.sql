CREATE PROCEDURE [dbo].[OXO_Market_MarketGroup_New] 
  @p_GroupId int,
  @p_MarketId int,
  @p_SubRegion nvarchar(500)
AS
	
  INSERT INTO dbo.OXO_Master_MarketGroup_Market_Link
  (
	Market_Group_Id,
	Country_Id,
	Sub_Region
  )
  VALUES
  (
	@p_GroupId,
	@p_MarketId,
	@p_SubRegion
  );

