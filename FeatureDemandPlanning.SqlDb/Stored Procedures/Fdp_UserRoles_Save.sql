CREATE PROCEDURE [dbo].[Fdp_UserRoles_Save]
	  @CDSId		NVARCHAR(16)
	, @RoleIds	NVARCHAR(MAX)
	, @CreatorCDSID NVARCHAR(16)
AS
	SET NOCOUNT ON;
	
	DECLARE @FdpUserId AS INT;
	SELECT TOP 1 @FdpUserId = FdpUserId FROM Fdp_User WHERE CDSId = @CDSId;
	
	DECLARE @Role AS TABLE
	(
		  FdpUserId			INT
		, FdpUserRoleId		INT
	)
	INSERT INTO @Role
	(
		  FdpUserId
		, FdpUserRoleId
	)
	SELECT
		  @FdpUserId AS FdpUserId
		, CAST(strval AS INT) AS FdpUserRoleId
	FROM dbo.FN_SPLIT(@RoleIds, N',')
	
	SELECT FdpUserId, FdpUserRoleId
	FROM @Role
	
	MERGE INTO Fdp_UserRoleMapping AS TARGET
	USING (
		SELECT FdpUserId, FdpUserRoleId
		FROM @Role
		GROUP BY
		FdpUserId, FdpUserRoleId
	) 
	AS SOURCE	ON	TARGET.FdpUserId		= SOURCE.FdpUserId
				AND TARGET.FdpUserRoleId	= SOURCE.FdpUserRoleId
				AND TARGET.IsActive			= 1
				
	WHEN MATCHED THEN
		
		UPDATE SET FdpUserRoleId = SOURCE.FdpUserRoleId
		
	WHEN NOT MATCHED BY TARGET THEN
	
		INSERT (FdpUserId, FdpUserRoleId, IsActive) 
		VALUES (FdpUserId, FdpUserRoleId, 1)
		
	WHEN NOT MATCHED BY SOURCE THEN
	
		DELETE;
	
	EXEC Fdp_UserRole_GetMany @CDSId = @CDSId;