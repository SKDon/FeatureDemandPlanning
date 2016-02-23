CREATE PROCEDURE [dbo].[Fdp_User_Get]
	  @CDSId NVARCHAR(16)
AS
	SET NOCOUNT ON;
	
	SELECT 
		  U.FdpUserId
		, U.CDSId
		, U.FullName
		, U.Mail
		, U.IsActive
		, CAST(CASE WHEN M.FdpUserRoleMappingId IS NOT NULL THEN 1 ELSE 0 END AS BIT) AS IsAdmin
		, dbo.fn_Fdp_UserProgrammes_GetMany(U.CDSId) AS Programmes
		, dbo.fn_Fdp_UserMarkets_GetMany(U.CDSId) AS Markets
		, dbo.fn_Fdp_UserRoles_GetMany(U.CDSId) AS Roles
		, U.CreatedOn
		, U.CreatedBy
		, U.UpdatedOn
		, U.UpdatedBy
		
	FROM Fdp_User AS U
	LEFT JOIN Fdp_UserRoleMapping AS M ON   U.FdpUserId = M.FdpUserId
										AND M.FdpUserRoleId = 5
										AND M.IsActive = 1
	WHERE
	U.CDSId = @CDSId;