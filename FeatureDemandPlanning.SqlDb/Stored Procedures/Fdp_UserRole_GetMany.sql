CREATE PROCEDURE [dbo].[Fdp_UserRole_GetMany]
	  @CDSId NVARCHAR(16)
AS
	SET NOCOUNT ON;

	SELECT
		  U.FdpUserId 
		, R.FdpUserRoleId
		, R.[Role]
		, R.[Description]
	FROM
	Fdp_User					AS U
	JOIN Fdp_UserRoleMapping	AS M	ON	U.FdpUserId		= M.FdpUserId
										AND M.IsActive		= 1
	JOIN Fdp_UserRole			AS R	ON	M.FdpUserRoleId = R.FdpUserRoleId
	WHERE
	U.CDSId = @CDSId