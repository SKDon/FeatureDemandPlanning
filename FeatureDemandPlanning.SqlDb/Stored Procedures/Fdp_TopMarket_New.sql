
CREATE PROCEDURE [dbo].[Fdp_TopMarket_New]
	  @MarketId		INT
	, @CdsId		NVARCHAR(16)
	, @TopMarketId	INT OUTPUT
AS
	SET NOCOUNT ON;
	
	IF EXISTS(SELECT TOP 1 1 FROM Fdp_TopMarket WHERE MarketId = @MarketId AND IsActive = 1)
		RAISERROR(N'Top market already exists', 16, 1)
		
	INSERT INTO Fdp_TopMarket 
	(
		  MarketId
		, CreatedBy
	)
	VALUES
	(
		  @MarketId
		, @CdsId
	);
	
	SET @TopMarketId = SCOPE_IDENTITY();
	
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

