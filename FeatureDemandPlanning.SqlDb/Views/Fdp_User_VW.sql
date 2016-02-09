



CREATE VIEW [dbo].[Fdp_User_VW] AS
	
	SELECT
		  U.FdpUserId
		, U.CreatedOn
		, U.CreatedBy
		, U.CDSId
		, U.FullName
		, U.IsActive
		, CAST(CASE WHEN M.FdpUserRoleMappingId IS NOT NULL THEN 1 ELSE 0 END AS BIT) AS IsAdmin
		, CASE
			WHEN M3.FdpUserRoleMappingId IS NOT NULL
			THEN 'All ' +
				CASE
					WHEN M2.FdpUserRoleMappingId IS NOT NULL
					THEN '(Edit)'
					ELSE '(View)'
				END
			ELSE
				 dbo.fn_Fdp_UserProgrammes_GetMany(U.CDSId)
		  END 
		  AS Programmes
		, dbo.fn_Fdp_UserRoles_GetMany(U.CDSId) AS Roles
		, CASE 
			WHEN M1.FdpUserRoleMappingId IS NOT NULL
			THEN 
				'All ' + 
				CASE 
					WHEN M2.FdpUserRoleMappingId IS NOT NULL 
					THEN '(Edit)' 
					ELSE '(View)' 
				END 
			ELSE 
				dbo.fn_Fdp_UserMarkets_GetMany(U.CDSId) 
		  END 
		  AS Markets
		, U.UpdatedOn
		, U.UpdatedBy
		, M1.FdpUserRoleId AS AllMarkets
	FROM
	Fdp_User AS U
	LEFT JOIN Fdp_UserRoleMapping AS M ON U.FdpUserId = M.FdpUserId
										AND M.IsActive = 1
										AND M.FdpUserRoleId = 5 -- Admin
	LEFT JOIN Fdp_UserRoleMapping AS M1 ON U.FdpUserId = M1.FdpUserId
										AND M1.IsActive = 1
										AND M1.FdpUserRoleId = 7 -- All markets
	LEFT JOIN Fdp_UserRoleMapping AS M2 ON U.FdpUserId = M2.FdpUserId
										AND M2.IsActive = 1
										AND M2.FdpUserRoleId = 3 -- Editor
	LEFT JOIN Fdp_UserRoleMapping AS M3 ON U.FdpUserId = M3.FdpUserId
										AND M3.IsActive = 1
										AND M3.FdpUserRoleId = 8 -- All programmes