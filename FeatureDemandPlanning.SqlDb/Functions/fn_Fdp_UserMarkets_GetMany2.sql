CREATE FUNCTION [dbo].[fn_Fdp_UserMarkets_GetMany2]
(
	@CDSId NVARCHAR(16)
)
RETURNS 
@Market TABLE 
(
	  MarketId			INT
	, Name				NVARCHAR(50)
	, MarketGroupId		INT NULL
	, FdpUserActionId	INT
)
AS
BEGIN
	INSERT INTO @Market
	(
		  MarketId
		, Name
		, MarketGroupId
		, FdpUserActionId
	)
	-- Permissions that have been defined individually
	SELECT
		  M1.MarketId
		, MK.Market_Name
		, MK.Market_Group_Id
		, M1.FdpUserActionId
	FROM
	Fdp_User						AS U
	JOIN 
	(
		-- Ensure if we have both view and edit permission, the edit permission takes precedence
		SELECT M.FdpUserId, M.MarketId, MAX(FdpUserActionId) AS FdpUserActionId
		FROM
		Fdp_UserMarketMapping	AS M
		GROUP BY
		M.FdpUserId, M.MarketId
	)
	AS M								ON	U.FdpUserId			= M.FdpUserId
	JOIN Fdp_UserMarketMapping AS M1	ON	M.FdpUserId			= M1.FdpUserId
										AND M.MarketId			= M1.MarketId
										AND M.FdpUserActionId	= M1.FdpUserActionId 
	JOIN OXO_Market_Group_Market_VW AS MK	ON M1.MarketId	= MK.Market_Id
	WHERE
	U.CDSId = @CDSId;

	INSERT INTO @Market
	(
		  MarketId
		, Name
		, MarketGroupId
		, FdpUserActionId
	)
	-- Permissions that have been defined with an "All Markets" role and haven't been individually expressed
	SELECT
		  M.Market_Id
		, M.Market_Name
		, M.Market_Group_Id
		, CASE
			WHEN R1.FdpUserRoleMappingId IS NOT NULL THEN 2 -- Edit
			ELSE 1 -- View
		  END
	FROM
	Fdp_User AS U
	CROSS APPLY OXO_Market_Group_Market_VW	AS M
	JOIN Fdp_UserRoleMapping		AS R	ON	U.FdpUserId			= R.FdpUserId
											AND R.IsActive			= 1
											AND R.FdpUserRoleId		= 7 -- All Markets
	LEFT JOIN Fdp_UserRoleMapping	AS R1	ON	U.FdpUserId			= R1.FdpUserId
											AND R1.IsActive			= 1
											AND R1.FdpUserRoleId	= 3 -- Editor
	LEFT JOIN @Market				AS M1	ON	M.Market_Id			= M1.MarketId
	WHERE
	U.CDSId = @CDSId
	AND
	M1.MarketId IS NULL -- We haven't already defined the market manually
	
	RETURN 
END