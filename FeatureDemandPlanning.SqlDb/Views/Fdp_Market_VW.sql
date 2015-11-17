
CREATE VIEW [dbo].[Fdp_Market_VW] AS
	
	SELECT 
		  STD.Name
		, STD.AKA
		, STD.Model_Year
		, STD.Programme_Id
		, STD.Market_Group_Id
		, STD.Market_Group_Name
		, STD.Make
		, STD.Display_Order
		, STD.Market_Id
		, LTRIM(RTRIM(
			CASE
				WHEN MAP.ImportMarket IS NOT NULL THEN MAP.ImportMarket
				ELSE STD.Market_Name
			END)) 
		  AS Market_Name
		, STD.PAR
		, STD.WHD
		, STD.SubRegion
		, STD.SubRegionOrder
	FROM
	OXO_Programme_MarketGroupMarket_VW AS STD
	LEFT JOIN 
	(
		SELECT 
			  M1.ImportMarket
			, M1.MappedMarketId
		FROM Fdp_MarketMapping AS M1
		JOIN
		(
			SELECT 
				  MAP1.ImportMarket
				, MAP1.FdpMarketMappingId
				, RANK() OVER (ORDER BY MAP1.FdpMarketMappingId DESC) AS Rk
			FROM
			Fdp_MarketMapping AS MAP1
		)
		AS M ON  M1.FdpMarketMappingId = M.FdpMarketMappingId 
			 AND M.Rk = 1
	)
	AS MAP ON STD.Market_Id = MAP.MappedMarketId