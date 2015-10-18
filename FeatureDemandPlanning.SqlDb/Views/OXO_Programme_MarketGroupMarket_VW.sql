CREATE VIEW [dbo].[OXO_Programme_MarketGroupMarket_VW]
AS

    SELECT V.Name, V.AKA, P.Model_Year, P.ID AS Programme_Id, 
		   PMG.Id AS Market_Group_Id,
		   PMG.Group_Name AS Market_Group_Name,
		   V.Make AS Make,
		   PMG.Display_Order, 
		   MK.Id AS Market_Id,
		   MK.Name AS Market_Name,
		   CASE WHEN V.Make = 'Jaguar' THEN MK.PAR_X
		   ELSE MK.PAR_L END AS PAR,
		   MK.WHD,
		   ISNULL(PMGM.Sub_Region, '') AS SubRegion,
		   CASE WHEN PMGM.Sub_Region = 'NSC' THEN 1
		   ELSE 10 END  AS SubRegionOrder		   		
    FROM dbo.OXO_Vehicle V
    INNER JOIN dbo.OXO_Programme P
    ON V.ID = P.Vehicle_Id
    INNER JOIN dbo.OXO_Programme_MarketGroup  PMG
    ON P.ID = PMG.Programme_Id
    INNER JOIN dbo.OXO_Programme_MarketGroup_Market_Link  PMGM
    ON PMG.Id = PMGM.Market_Group_Id
    INNER JOIN dbo.OXO_Master_Market MK
    ON MK.Id = PMGM.Country_Id;

