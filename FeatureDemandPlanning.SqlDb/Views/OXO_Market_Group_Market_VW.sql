CREATE VIEW [OXO_Market_Group_Market_VW]
AS

    SELECT MG.Id AS Market_Group_Id,
		   MG.Group_Name AS Market_Group_Name,
		   MG.Make AS Make,
		   MG.Display_Order, 
		   MK.Id AS Market_Id,
		   MGM.Sub_Region,
		   MK.Name AS Market_Name,
		   CASE WHEN MG.Make = 'Jaguar' THEN MK.PAR_X
		   ELSE MK.PAR_L END AS PAR,
		   MK.WHD
		   		
    FROM dbo.OXO_Master_MarketGroup  MG
    INNER JOIN dbo.OXO_Master_MarketGroup_Market_Link  MGM
    ON MG.Id = MGM.Market_Group_Id
    INNER JOIN dbo.OXO_Master_Market MK
    ON MK.Id = MGM.Country_Id;

