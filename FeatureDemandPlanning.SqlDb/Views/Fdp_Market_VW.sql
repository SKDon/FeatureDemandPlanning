CREATE VIEW Fdp_Market_VW AS
	
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
			  MAP1.ImportMarket
			, MAX(MAP1.MappedMarket) AS MappedMarket
		FROM
		Fdp_MarketMapping AS MAP1
		GROUP BY
		MAP1.ImportMarket
	)
	AS MAP ON STD.Market_Name = MAP.MappedMarket