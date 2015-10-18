
CREATE PROCEDURE [dbo].[Fdp_TopMarket_GetMany]
	@MarketId INT = NULL
AS
	SET NOCOUNT ON;
	
	SELECT Id
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
	AND
	Active = 1
	ORDER BY
	Name;
	
	
