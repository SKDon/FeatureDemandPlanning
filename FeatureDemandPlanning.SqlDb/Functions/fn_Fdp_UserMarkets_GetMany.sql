CREATE FUNCTION [dbo].[fn_Fdp_UserMarkets_GetMany]
(
	@CDSId NVARCHAR(16)
)
RETURNS NVARCHAR(MAX)
AS
BEGIN
	
	DECLARE @Markets AS NVARCHAR(MAX)
	
	SELECT @Markets = COALESCE(@Markets + ', ', '') + O.Market_Name + ' (' + A.[Action] + ')'
	FROM
	Fdp_User						AS U
	JOIN 
	(
		SELECT FdpUserId, MarketId, MAX(FdpUserActionId) AS FdpUserActionId
		FROM
		Fdp_UserMarketMapping AS M
		WHERE
		M.IsActive = 1
		GROUP BY
		M.FdpUserId, M.MarketId
	)								AS M	ON	U.FdpUserId			= M.FdpUserId
	JOIN OXO_Market_Group_Market_VW	AS O	ON	M.MarketId			= O.Market_Id
	JOIN Fdp_UserAction				AS A	ON	M.FdpUserActionId	= A.FdpUserActionId
	WHERE
	U.CDSId = @CDSId
	
	RETURN @Markets
   
END