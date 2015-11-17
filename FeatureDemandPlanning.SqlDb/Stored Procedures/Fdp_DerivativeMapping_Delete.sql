CREATE PROCEDURE [dbo].[Fdp_DerivativeMapping_Delete]
	  @FdpDerivativeMappingId INT
	, @CDSId NVARCHAR(16)
AS
	SET NOCOUNT ON;
	
	UPDATE Fdp_DerivativeMapping SET 
		  IsActive = 0
		, UpdatedOn = GETDATE()
		, UpdatedBy = @CDSId 
	WHERE
	FdpDerivativeMappingId = @FdpDerivativeMappingId;
	
	EXEC Fdp_DerivativeMapping_Get @FdpDerivativeMappingId;