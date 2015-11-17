CREATE PROCEDURE [dbo].[Fdp_User_SetIsAdmin]
	  @CDSId			NVARCHAR(16)
	, @IsAdmin			BIT
	, @UpdatedByCDSId	NVARCHAR(16)
AS
	SET NOCOUNT ON;
	
	IF EXISTS(SELECT TOP 1 1 FROM Fdp_User WHERE CDSId = @CDSId)
	BEGIN
		UPDATE Fdp_User SET 
		    IsAdmin = @IsAdmin
		  , UpdatedBy = @UpdatedByCDSId
		  , UpdatedOn = GETDATE()
		WHERE
		CDSId = @CDSId;
		
		EXEC Fdp_User_Get @CDSId = @CDSId;
	END