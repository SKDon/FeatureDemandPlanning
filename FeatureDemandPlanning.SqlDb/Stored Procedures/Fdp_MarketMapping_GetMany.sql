CREATE PROCEDURE [dbo].[Fdp_MarketMapping_GetMany]
	  @CarLine					NVARCHAR(10)	= NULL
	, @ModelYear				NVARCHAR(10)	= NULL
	, @Gateway					NVARCHAR(16)	= NULL
	, @IsGlobalMapping			BIT = 0
	, @CDSId					NVARCHAR(16)
	, @FilterMessage			NVARCHAR(50)	= NULL
	, @PageIndex				INT				= NULL
	, @PageSize					INT				= 10
	, @SortIndex				INT				= 1
	, @SortDirection			VARCHAR(5)		= 'ASC'
	, @TotalPages				INT OUTPUT
	, @TotalRecords				INT OUTPUT
	, @TotalDisplayRecords		INT OUTPUT
AS
	SET NOCOUNT ON;
	
	IF @PageIndex IS NULL 
		SET @PageIndex = 1;
	
	DECLARE @MinIndex AS INT;
	DECLARE @MaxIndex AS INT;
	DECLARE @PageRecords AS TABLE
	(
		  RowIndex INT IDENTITY(1, 1)
		, FdpMarketMappingId INT
	);
	INSERT INTO @PageRecords (FdpMarketMappingId)
	SELECT M.FdpMarketMappingId
	FROM
	Fdp_MarketMapping		AS M
	--JOIN OXO_Programme_VW	AS P ON M.ProgrammeId = P.Id
	--WHERE
	--(@CarLine IS NULL OR P.VehicleName = @CarLine)
	--AND
	--(@ModelYear IS NULL OR P.ModelYear = @ModelYear)
	--AND
	--(@Gateway IS NULL OR M.Gateway = @Gateway)
	--AND
	WHERE
	M.IsActive = 1
	
	SELECT @TotalRecords = COUNT(1) FROM @PageRecords;
	SELECT @TotalDisplayRecords = @TotalRecords;
	
	IF ISNULL(@PageSize, 0) = 0
		SET @PageSize = @TotalRecords;
	
	SET @TotalPages = CEILING(@TotalRecords / CAST(@PageSize AS DECIMAL));
	SET @MinIndex = ((@PageIndex - 1) * @PageSize) + 1;
	SET @MaxIndex = @MinIndex + (@PageSize - 1);

	SELECT DISTINCT
		  M.FdpMarketMappingId
		, M.CreatedOn
		, M.CreatedBy
		, M.ProgrammeId
		, M.Gateway
		, M.IsGlobalMapping
		, M.ImportMarket
		, M.MappedMarketId			AS MappedMarketId
		, MK.Market_Group_Name		AS GroupName
		, MK.Market_Name			AS Name

	FROM @PageRecords				AS P
	JOIN Fdp_MarketMapping			AS M	ON	P.FdpMarketMappingId = M.FdpMarketMappingId
											AND P.RowIndex BETWEEN @MinIndex AND @MaxIndex
	JOIN OXO_Market_Group_Market_VW	AS MK	ON	M.MappedMarketId = MK.Market_Id