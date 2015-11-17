CREATE PROCEDURE [dbo].[Fdp_MarketMapping_Get]
	@FdpMarketMappingId INT
AS
	SET NOCOUNT ON;
	
	SELECT 
		  MAP.FdpMarketMappingId
		, MAP.CreatedOn
		, MAP.CreatedBy
		, MAP.ProgrammeId
		, MAP.Gateway
		, MAP.IsGlobalMapping
		, MAP.ImportMarket
		, M.Id						AS MappedMarketId
		, M.Name					AS MarketName
		, MAP.IsActive
		, MAP.UpdatedOn
		, MAP.UpdatedBy
		
	FROM Fdp_MarketMapping AS MAP
	JOIN OXO_Master_Market AS M	ON MAP.MappedMarketId = M.Id
	WHERE
	MAP.FdpMarketMappingId = @FdpMarketMappingId;