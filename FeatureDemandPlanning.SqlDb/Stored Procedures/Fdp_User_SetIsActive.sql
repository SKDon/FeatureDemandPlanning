CREATE PROCEDURE [dbo].[Fdp_User_SetIsActive]
	  @CDSId			NVARCHAR(16)
	, @IsActive			BIT
	, @UpdatedByCDSId	NVARCHAR(16)
AS
	SET NOCOUNT ON;
	
	IF EXISTS(SELECT TOP 1 1 FROM Fdp_User WHERE CDSId = @CDSId)
	BEGIN
		UPDATE Fdp_User SET 
			  IsActive = @IsActive
			, UpdatedOn = GETDATE()
			, UpdatedBy = @UpdatedByCDSId
		WHERE
		CDSId = @CDSId;
		
		EXEC Fdp_User_Get @CDSId = @CDSId;
	END