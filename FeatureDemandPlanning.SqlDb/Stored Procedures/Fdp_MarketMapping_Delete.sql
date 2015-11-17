CREATE PROCEDURE dbo.Fdp_MarketMapping_Delete
	  @FdpMarketMappingId INT
	, @CDSId NVARCHAR(16)
AS
	SET NOCOUNT ON;
	
	UPDATE Fdp_MarketMapping SET 
		  IsActive = 0
		, UpdatedOn = GETDATE()
		, UpdatedBy = @CDSId 
	WHERE
	FdpMarketMappingId = @FdpMarketMappingId;
	
	EXEC Fdp_MarketMapping_Get @FdpMarketMappingId;