CREATE PROCEDURE [OXO_Market_MarketGroup_GetMany]
AS
	
	SELECT OXO_Master_MarketGroup.Display_Order AS DisplayOrder, OXO_Master_MarketGroup.Id AS GroupId, 
           OXO_Master_MarketGroup.Group_Name AS GroupName, 
           OXO_Master_Market.Id, OXO_Master_Market.Name, OXO_Master_Market.WHD, 
           ISNULL(OXO_Master_Market.PAR_X, '') AS PAR_X, ISNULL(OXO_Master_Market.PAR_L, '') AS PAR_L, ISNULL(OXO_Master_Market.Territory, '') 
           AS Territory, ISNULL(OXO_Master_Market.WERSCode, '') AS WERSCode, ISNULL(OXO_Master_Market.Brand, '') AS Brand, OXO_Master_Market.Active,
           OXO_Master_Market.Created_By, OXO_Master_Market.Created_On, OXO_Master_Market.Updated_By, OXO_Master_Market.Last_Updated,
           ISNULL(OXO_Master_MarketGroup_Market_Link.Sub_Region, '') AS SubRegion,
           CASE WHEN OXO_Master_MarketGroup_Market_Link.Sub_Region = 'NSC' THEN 1
                ELSE 10 END AS SubRegionOrder
           
	FROM OXO_Master_Market INNER JOIN
		OXO_Master_MarketGroup_Market_Link ON OXO_Master_Market.Id = OXO_Master_MarketGroup_Market_Link.Country_Id 
		RIGHT OUTER JOIN
		OXO_Master_MarketGroup ON OXO_Master_MarketGroup_Market_Link.Market_Group_Id = OXO_Master_MarketGroup.Id
	ORDER BY DisplayOrder, SubRegion, OXO_Master_Market.Name;

