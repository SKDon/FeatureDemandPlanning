

CREATE VIEW [dbo].[Fdp_MarketMapping_VW] AS
	
	SELECT 
		  STD.Name
		, STD.AKA
		, STD.Model_Year
		, STD.Programme_Id AS ProgrammeId
		, G.Gateway
		, STD.Market_Group_Id
		, STD.Market_Group_Name
		, STD.Make
		, STD.Display_Order
		, STD.Market_Id
		, STD.Market_Name
		, STD.PAR
		, STD.WHD
		, STD.SubRegion
		, STD.SubRegionOrder
		, CAST(0 AS BIT) AS IsMappedMarket
	FROM
	OXO_Programme_MarketGroupMarket_VW	AS STD
	JOIN Fdp_Gateways_VW				AS G	ON STD.Programme_Id = G.ProgrammeId
	
	UNION
	
	SELECT 
		  STD.Name
		, STD.AKA
		, STD.Model_Year
		, STD.Programme_Id AS ProgrammeId
		, G.Gateway
		, STD.Market_Group_Id
		, STD.Market_Group_Name
		, STD.Make
		, STD.Display_Order
		, STD.Market_Id
		, MAP.ImportMarket
		, STD.PAR
		, STD.WHD
		, STD.SubRegion
		, STD.SubRegionOrder
		, CAST(1 AS BIT) AS IsMappedMarket
	FROM
	OXO_Programme_MarketGroupMarket_VW	AS STD
	JOIN Fdp_Gateways_VW				AS G	ON STD.Programme_Id = G.ProgrammeId
	JOIN Fdp_MarketMapping				AS MAP	ON STD.Market_Id	= MAP.MappedMarketId
												AND 
												(
													MAP.IsGlobalMapping = 1
													OR
													(
														MAP.IsGlobalMapping = 0
														AND
														MAP.Gateway = G.Gateway
														AND
														MAP.ProgrammeId = STD.Programme_Id
													)
												)
												AND 
												MAP.IsActive	= 1