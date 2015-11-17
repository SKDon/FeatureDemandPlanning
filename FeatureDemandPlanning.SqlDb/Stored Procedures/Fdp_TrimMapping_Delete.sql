CREATE PROCEDURE [dbo].[Fdp_TrimMapping_Delete]
	  @FdpTrimMappingId INT
	, @CDSId NVARCHAR(16)
AS
	SET NOCOUNT ON;
	
	UPDATE Fdp_TrimMapping SET 
		  IsActive = 0
		, UpdatedOn = GETDATE()
		, UpdatedBy = @CDSId 
	WHERE
	FdpTrimMappingId = @FdpTrimMappingId;
	
	EXEC Fdp_TrimMapping_Get @FdpTrimMappingId;