
CREATE PROCEDURE [dbo].[Fdp_Market_AvailableGetMany]
	@CDSId NVARCHAR(16)
AS
	SET NOCOUNT ON

	;WITH AvailableMarkets AS
	(
		SELECT U.FdpUserId, M.MarketId
		FROM
		Fdp_User AS U
		JOIN Fdp_UserMarketMapping AS M ON	U.FdpUserId = M.FdpUserId
										AND M.IsActive = 1
		WHERE
		U.CDSId = @CDSId
		GROUP BY
		U.FdpUserId, M.MarketId
	)
	, AllMarkets AS 
	(
		SELECT U.FdpUserId, CAST(1 AS BIT) AS AllMarkets
		FROM
		Fdp_User AS U
		JOIN Fdp_UserRoleMapping AS R	ON	U.FdpUserId		= R.FdpUserId
										AND R.IsActive		= 1
										AND R.FdpUserRoleId = 7 -- All Markets
		WHERE
		U.CDSId = @CDSId
	)
	SELECT 
		M.Id					AS Id,
		M.Name					AS Name,  
		M.WHD					AS WHD,
		ISNULL(M.PAR_X, '')		AS PAR_X,  
		ISNULL(M.PAR_L, '')		AS PAR_L,  
		ISNULL(M.Territory, '')	AS Territory,  
		ISNULL(M.WERSCode, '')	AS WERSCode,  
		ISNULL(M.Brand, '')		AS Brand,  
		M.Active				AS Active,  
		M.Created_By			AS Created_By,  
		M.Created_On			AS Created_On,  
		M.Updated_By			AS Updated_By,  
		M.Last_Updated			AS Last_Updated,
		ISNULL(G.Group_Name, '')	AS GroupName    
	FROM OXO_Master_Market			AS M
	LEFT JOIN OXO_Master_MarketGroup_Market_Link AS L ON M.Id				= L.Country_Id
	LEFT JOIN OXO_Master_MarketGroup				AS G ON L.Market_Group_Id	= G.Id
	CROSS APPLY AllMarkets AS A
	LEFT JOIN AvailableMarkets AS A1 ON M.Id = A1.MarketId
	WHERE
	M.Active = 1
	AND
	(
		A.AllMarkets = 1
		OR
		A1.MarketId IS NOT NULL
	)
	ORDER BY
	M.Name;