CREATE PROCEDURE [dbo].[Fdp_UserRole_GetMany]
	  @CDSId NVARCHAR(16)
AS
	SET NOCOUNT ON;

	SELECT 1 AS FdpUserRoleId, N'Administrator' AS [Role], N'The user is an administrator and can perform all functions within the system' AS [Description]