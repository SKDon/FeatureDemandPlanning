-- To deploy, set the parameters below and uncomment the transaction commit statement

BEGIN TRANSACTION

DECLARE @AdminCDSId AS NVARCHAR(16) = 'bweston2'
DECLARE @AdminName  AS NVARCHAR(100) = 'Blake Weston'
DECLARE @AdminMail  AS NVARCHAR(200) = 'bweston2@jaguarlandrover.com'
DECLARE @FdpUserId AS INT

IF NOT EXISTS(SELECT TOP 1 1 FROM Fdp_User WHERE CDSId = @AdminCDSId)
BEGIN
	INSERT INTO Fdp_User
	(
		  CDSId
		, FullName
		, Mail
		, IsActive
		, IsAdmin
		, CreatedOn
		, CreatedBy
	)
	VALUES
	(
		  @AdminCDSId
		, @AdminName
		, @AdminMail
		, 1
		, 1
		, GETDATE()
		, 'system'
	)
	
	SET @FdpUserId = SCOPE_IDENTITY();
	
	INSERT INTO Fdp_UserRoleMapping
	(
		  FdpUserId
		, FdpUserRoleId
		, IsActive
	)
	VALUES
	(
		  @FdpUserId
		, 1
		, 1
	)
	
	INSERT INTO Fdp_UserRoleMapping
	(
		  FdpUserId
		, FdpUserRoleId
		, IsActive
	)
	VALUES
	(
		  @FdpUserId
		, 5
		, 1
	)
	
	INSERT INTO Fdp_UserRoleMapping
	(
		  FdpUserId
		, FdpUserRoleId
		, IsActive
	)
	VALUES
	(
		  @FdpUserId
		, 3
		, 1
	)
	
	INSERT INTO Fdp_UserRoleMapping
	(
		  FdpUserId
		, FdpUserRoleId
		, IsActive
	)
	VALUES
	(
		  @FdpUserId
		, 6
		, 1
	)
	
	INSERT INTO Fdp_UserRoleMapping
	(
		  FdpUserId
		, FdpUserRoleId
		, IsActive
	)
	VALUES
	(
		  @FdpUserId
		, 7
		, 1
	)
	
	INSERT INTO Fdp_UserRoleMapping
	(
		  FdpUserId
		, FdpUserRoleId
		, IsActive
	)
	VALUES
	(
		  @FdpUserId
		, 8
		, 1
	)
END

ROLLBACK TRANSACTION
--COMMIT TRANSACTION


