CREATE FUNCTION [dbo].[fn_Fdp_UserRoles_GetMany]
(
	@CDSId NVARCHAR(16)
)
RETURNS NVARCHAR(MAX)
AS
BEGIN
	
	DECLARE @Roles AS NVARCHAR(MAX)
	
	SELECT @Roles = COALESCE(@Roles + ', ', '') + R1.[Role]
	FROM
	Fdp_User						AS U
	JOIN Fdp_UserRoleMapping		AS R	ON	U.FdpUserId			= R.FdpUserId
											AND R.IsActive			= 1
	JOIN Fdp_UserRole				AS R1	ON	R.FdpUserRoleId		= R1.FdpUserRoleId
	WHERE
	U.CDSId = @CDSId
	
	RETURN @Roles
   
END