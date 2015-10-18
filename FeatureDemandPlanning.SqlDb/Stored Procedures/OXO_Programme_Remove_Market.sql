CREATE PROCEDURE [dbo].[OXO_Programme_Remove_Market] 
  @p_prog_id int,
  @p_market_id int
AS
	
  DELETE 
  FROM dbo.OXO_Programme_MarketGroup_Market_Link
  WHERE Programme_Id = @p_prog_id
  AND Country_Id = @p_market_id;

  UPDATE T1
  SET T1.Active = 0
  FROM dbo.OXO_Item_Data_MBM AS T1
  INNER JOIN dbo.OXO_Doc AS T2
  ON T1.OXO_Doc_Id = T2.Id
  WHERE T2.Programme_Id = @p_prog_id
  AND T1.Market_Id = @p_market_id;
  
  UPDATE T1
  SET T1.Active = 0
  FROM dbo.OXO_Item_Data_FBM AS T1
  INNER JOIN dbo.OXO_Doc AS T2
  ON T1.OXO_Doc_Id = T2.Id
  WHERE T2.Programme_Id = @p_prog_id
  AND T1.Market_Id = @p_market_id;
  
  UPDATE T1
  SET T1.Active = 0
  FROM dbo.OXO_Item_Data_PCK AS T1
  INNER JOIN dbo.OXO_Doc AS T2
  ON T1.OXO_Doc_Id = T2.Id
  WHERE T2.Programme_Id = @p_prog_id
  AND T1.Market_Id = @p_market_id;
  
  UPDATE T1
  SET T1.Active = 0
  FROM dbo.OXO_Item_Data_FPS AS T1
  INNER JOIN dbo.OXO_Doc AS T2
  ON T1.OXO_Doc_Id = T2.Id
  WHERE T2.Programme_Id = @p_prog_id
  AND T1.Market_Id = @p_market_id;

