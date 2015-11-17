CREATE PROCEDURE [dbo].[Fdp_MarketMapping_GetMany]
	  @ProgrammeId		INT = NULL
	, @Gateway			INT = NULL
	, @IsGlobalMapping	BIT = 0
	, @CDSId			NVARCHAR(16) = NULL
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
		
	FROM Fdp_MarketMapping AS MAP
	JOIN OXO_Master_Market AS M	ON MAP.MappedMarketId = M.Id
	WHERE
	(@ProgrammeId IS NULL OR MAP.ProgrammeId = @ProgrammeId)
	AND
	(@Gateway IS NULL OR MAP.Gateway = @Gateway)
	AND
	(@IsGlobalMapping IS NULL OR MAP.IsGlobalMapping = @IsGlobalMapping)
	AND
	MAP.IsActive = 1
	--AND
	-- (@CDSId IS NULL)
	ORDER BY
	ImportMarket, MarketName;