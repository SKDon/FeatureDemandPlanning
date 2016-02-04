CREATE PROCEDURE [dbo].[Fdp_User_SetIsAdmin]
	  @CDSId			NVARCHAR(16)
	, @IsAdmin			BIT
	, @UpdatedByCDSId	NVARCHAR(16)
AS
	SET NOCOUNT ON;
	
	DECLARE @FdpUserId INT;
	SELECT TOP 1 @FdpUserId FROM Fdp_User WHERE CDSId = @CDSId;
	
	IF @FdpUserId IS NOT NULL
	BEGIN
		UPDATE Fdp_User SET 
		    IsAdmin = @IsAdmin
		  , UpdatedBy = @UpdatedByCDSId
		  , UpdatedOn = GETDATE()
		WHERE
		CDSId = @CDSId;
		
		-- As the IsAdmin flag above is no longer really used in favour of roles, we need to insert role information
		IF @IsAdmin = 1 AND NOT EXISTS(SELECT TOP 1 1 FROM Fdp_UserRoleMapping WHERE FdpUserId = @FdpUserId AND FdpUserRoleId = 5 AND IsActive = 1)
		BEGIN
			INSERT INTO Fdp_UserRoleMapping (FdpUserId, FdpUserRoleId)
			VALUES (@FdpUserId, 5)
		END
		ELSE
		BEGIN
			UPDATE Fdp_UserRoleMapping SET IsActive = 0 WHERE FdpUserId = @FdpUserId AND FdpUserRoleId = 5
		END
			
		EXEC Fdp_User_Get @CDSId = @CDSId;
	END