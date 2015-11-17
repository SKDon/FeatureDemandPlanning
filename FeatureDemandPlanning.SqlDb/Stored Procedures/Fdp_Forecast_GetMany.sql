CREATE PROCEDURE [dbo].[Fdp_Forecast_GetMany]
	  @ForecastId			INT = NULL
	, @FilterMessage		NVARCHAR(50)	= NULL
	-- TODO - Implement permissions over which forecasts can be viewed
	, @CDSId				NVARCHAR(16)	= NULL
	, @PageIndex			INT				= NULL
	, @PageSize				INT				= NULL
	, @SortIndex			INT				= 0
	, @SortDirection		VARCHAR(5)		= 'DESC'
	, @TotalPages			INT OUTPUT
	, @TotalRecords			INT OUTPUT
	, @TotalDisplayRecords  INT OUTPUT
AS
	SET NOCOUNT ON;
	
	IF @PageIndex IS NULL 
		SET @PageIndex = 1;
	
	DECLARE @MinIndex AS INT;
	DECLARE @MaxIndex AS INT;
	DECLARE @PageRecords AS TABLE
	(
		  RowIndex INT IDENTITY(1,1)
		, ForecastId INT
	);
	INSERT INTO @PageRecords 
	(
		E.ForecastId
	)
	SELECT F.Id
	FROM Fdp_Forecast_VW AS F
	WHERE
	(@ForecastId IS NULL OR F.Id = @ForecastId)
	AND
	(ISNULL(@FilterMessage, '') = '' OR F.FullDescription LIKE '%' + @FilterMessage + '%')
	ORDER BY	
		CASE @SortDirection
		WHEN 'ASC' THEN
			CASE ISNULL(@SortIndex, 0)
				-- First sort looks a little odd, as it's a different type to the rest of the dynamic sort
				-- columns, we get a conversion error. The padding is so sorting a number as a string will
				-- work correctly
				WHEN 0 THEN RIGHT('000000' + CAST(Id AS NVARCHAR(10)), 6)
				WHEN 1 THEN CreatedBy
				WHEN 2 THEN Code
				WHEN 3 THEN [Description]
				WHEN 4 THEN ModelYear
				WHEN 5 THEN Gateway
			END
		END ASC,
		CASE @SortDirection
		WHEN 'DESC' THEN
			CASE ISNULL(@SortIndex, 0)
				WHEN 0 THEN RIGHT('000000' + CAST(Id AS NVARCHAR(10)), 6)
				WHEN 1 THEN CreatedBy
				WHEN 2 THEN Code
				WHEN 3 THEN [Description]
				WHEN 4 THEN ModelYear
				WHEN 5 THEN Gateway
			END	
		END DESC
	
	SELECT @TotalRecords = COUNT(1) FROM @PageRecords;

	IF ISNULL(@PageSize, 0) = 0
		SET @PageSize = @TotalRecords;
	
	SET @TotalPages = CEILING(@TotalRecords / CAST(@PageSize AS DECIMAL));
	SET @MinIndex = ((@PageIndex - 1) * @PageSize) + 1;
	SET @MaxIndex = @MinIndex + (@PageSize - 1);
	
	SELECT @TotalDisplayRecords = COUNT(1) FROM @PageRecords WHERE RowIndex BETWEEN @MinIndex AND @MaxIndex;
	
	SELECT 
		  F.Id AS ForecastId
		, F.CreatedOn
		, F.CreatedBy
		, F.ProgrammeId
		, F.Code
		, F.[Description] AS CarLine
		, F.ModelYear
		, F.Gateway
		
	FROM @PageRecords		AS P
	JOIN Fdp_Forecast_VW	AS F	ON	P.ForecastId = F.Id
									AND P.RowIndex BETWEEN @MinIndex AND @MaxIndex;

