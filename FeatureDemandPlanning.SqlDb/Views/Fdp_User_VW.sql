
CREATE VIEW [dbo].[Fdp_User_VW] AS
	
	SELECT
		  U.FdpUserId
		, U.CreatedOn
		, U.CreatedBy
		, U.CDSId
		, U.FullName
		, U.IsActive
		, CAST(CASE WHEN M.FdpUserRoleMappingId IS NOT NULL THEN 1 ELSE 0 END AS BIT) AS IsAdmin
		, dbo.fn_Fdp_UserProgrammes_GetMany(U.CDSId) AS Programmes
		, dbo.fn_Fdp_UserRoles_GetMany(U.CDSId) AS Roles
		, dbo.fn_Fdp_UserMarkets_GetMany(U.CDSId) AS Markets
		, U.UpdatedOn
		, U.UpdatedBy
	FROM
	Fdp_User AS U
	LEFT JOIN Fdp_UserRoleMapping AS M ON U.FdpUserId = M.FdpUserId
										AND M.IsActive = 1
										AND M.FdpUserRoleId = 5