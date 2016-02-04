CREATE PROCEDURE [dbo].[Fdp_UserMarket_GetMany]
	  @CDSId NVARCHAR(16)
AS
	SET NOCOUNT ON;

	SELECT 
		  U.FdpUserId
		, M.MarketId
		, O.Market_Name AS Market
		, A.FdpUserActionId
		, A.[Action]
	FROM
	Fdp_User						AS U
	JOIN Fdp_UserMarketMapping		AS M	ON	U.FdpUserId		= M.FdpUserId
											AND M.IsActive		= 1
	JOIN OXO_Market_Group_Market_VW	AS O	ON	M.MarketId		= O.Market_Id
	JOIN Fdp_UserAction				AS A	ON	M.FdpUserActionId = A.FdpUserActionId
	WHERE
	U.CDSId = @CDSId