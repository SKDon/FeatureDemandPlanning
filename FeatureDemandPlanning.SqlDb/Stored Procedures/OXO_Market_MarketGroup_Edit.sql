CREATE PROCEDURE [dbo].[OXO_Market_MarketGroup_Edit] 
  @p_New_GroupId int,
  @p_Old_GroupId int,
  @p_MarketId int,
  @p_Sub_Group_Id nvarchar(500)
AS
	
  UPDATE dbo.OXO_Master_MarketGroup_Market_Link
  SET Market_Group_Id = @p_New_GroupId,
	  Sub_Region = @p_Sub_Group_Id 
  WHERE Market_Group_Id = @p_Old_GroupId
  AND Country_Id = @p_MarketId;

