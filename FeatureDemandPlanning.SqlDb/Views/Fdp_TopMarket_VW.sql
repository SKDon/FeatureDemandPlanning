


CREATE VIEW [dbo].[Fdp_TopMarket_VW] AS

	SELECT 
		  M.Id						AS Id
		, M.Name					AS Name
		, M.WHD						AS WHD
		, ISNULL(M.PAR_X, '')		AS PAR_X  
		, ISNULL(M.PAR_L, '')		AS PAR_L  
		, ISNULL(M.Territory, '')	AS Territory  
		, ISNULL(M.WERSCode, '')	AS WERSCode  
		, ISNULL(M.Brand, '')		AS Brand  
		, CAST(CASE 
			WHEN M.Active = 1 AND T.IsActive = 1 THEN 1
			ELSE 0
		  END AS BIT)				AS Active
		, M.Created_By				AS Created_By 
		, M.Created_On				AS Created_On 
		, M.Updated_By				AS Updated_By 
		, M.Last_Updated			AS Last_Updated
		, T.CreatedOn				AS TopMarketCreatedOn
		, T.CreatedBy				AS TopMarketCreatedBy
		
	FROM Fdp_TopMarket		AS T
	JOIN OXO_Master_Market	AS M ON T.MarketId = M.Id
	JOIN
	(
		SELECT MarketId, MAX(FdpTopMarketId) AS FdpTopMarketId
		FROM
		Fdp_TopMarket
		GROUP BY
		MarketId
	)
	AS LATEST ON T.FdpTopMarketId = LATEST.FdpTopMarketId
	WHERE
	M.Active = 1;





