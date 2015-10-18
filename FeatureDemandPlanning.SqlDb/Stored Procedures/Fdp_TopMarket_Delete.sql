
CREATE PROCEDURE [dbo].[Fdp_TopMarket_Delete]
	  @MarketId		INT
	, @CdsId		NVARCHAR(16)
AS
	SET NOCOUNT ON;
	
	IF NOT EXISTS(SELECT TOP 1 1 FROM Fdp_TopMarket WHERE MarketId = @MarketId AND IsActive = 1)
		RAISERROR(N'Top market does not exist', 16, 1);
		
	UPDATE Fdp_TopMarket SET IsActive = 0 WHERE MarketId = @MarketId;
	
	SELECT TOP 1 Id
		, Name
		, WHD
		, PAR_X  
		, PAR_L  
		, Territory  
		, WERSCode  
		, Brand  
		, Active
		, Created_By 
		, Created_On 
		, Updated_By 
		, Last_Updated
		, TopMarketCreatedOn
		, TopMarketCreatedBy
		
	FROM Fdp_TopMarket_VW
	WHERE
	(@MarketId IS NULL OR Id = @MarketId)
	ORDER BY
	Name;


