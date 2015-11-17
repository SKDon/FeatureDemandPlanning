CREATE PROCEDURE [dbo].[Fdp_Derivative_Delete]
	  @FdpDerivativeId  INT
	, @CDSId			NVARCHAR(16)
AS
	SET NOCOUNT ON;
	
	UPDATE Fdp_Derivative SET 
		  IsActive = 0
		, UpdatedOn = GETDATE()
		, UpdatedBy = @CDSId 
	WHERE
	FdpDerivativeId = @FdpDerivativeId;
	
	EXEC Fdp_Derivative_Get @FdpDerivativeId;