CREATE PROCEDURE [dbo].[Fdp_Feature_GetMany] 
	  @CarLine				NVARCHAR(10)	= NULL
	, @ModelYear			NVARCHAR(10)	= NULL
	, @Gateway				NVARCHAR(100)	= NULL
	
	, @CDSId				NVARCHAR(16)
	, @FilterMessage		NVARCHAR(50)	= NULL
	, @PageIndex			INT				= NULL
	, @PageSize				INT				= 10
	, @SortIndex			INT				= 1
	, @SortDirection		VARCHAR(5)		= 'ASC'
	, @TotalPages			INT OUTPUT
	, @TotalRecords			INT OUTPUT
	, @TotalDisplayRecords	INT OUTPUT
AS
	SET NOCOUNT ON;
	
	IF @PageIndex IS NULL 
		SET @PageIndex = 1;
	
	DECLARE @MinIndex AS INT;
	DECLARE @MaxIndex AS INT;
	DECLARE @PageRecords AS TABLE
	(
		  RowIndex INT IDENTITY(1, 1)
		, FdpFeatureId INT
	);
	INSERT INTO @PageRecords (FdpFeatureId)
	SELECT F.FdpFeatureId
	FROM
	Fdp_Feature AS F
	JOIN OXO_Programme_VW	 AS P ON F.ProgrammeId = P.Id
	WHERE
	(@CarLine IS NULL OR P.VehicleName = @CarLine)
	AND
	(@ModelYear IS NULL OR P.ModelYear = @ModelYear)
	AND
	(@Gateway IS NULL OR F.Gateway = @Gateway)
	AND
	F.IsActive = 1
	--ORDER BY
	--	CASE @SortDirection
	--		WHEN 'ASC' THEN
	--			CASE ISNULL(@SortIndex, 0)
	--				WHEN 1 THEN U.CDSId
	--				WHEN 2 THEN FullName
	--				WHEN 3 THEN CAST(IsActive AS NVARCHAR(1))
	--				WHEN 4 THEN CAST(IsAdmin AS NVARCHAR(1))
	--				ELSE U.CDSId
	--			END
	--	END ASC,
	--	CASE @SortDirection
	--		WHEN 'DESC' THEN
	--			CASE ISNULL(@SortIndex, 0)
	--				WHEN 1 THEN U.CDSId
	--				WHEN 2 THEN FullName
	--				WHEN 3 THEN CAST(IsActive AS NVARCHAR(1))
	--				WHEN 4 THEN CAST(IsAdmin AS NVARCHAR(1))
	--				ELSE U.CDSId
	--			END	
	--	END DESC
		
	SELECT @TotalRecords = COUNT(1) FROM @PageRecords;
	SELECT @TotalDisplayRecords = @TotalRecords;
	
	IF ISNULL(@PageSize, 0) = 0
		SET @PageSize = @TotalRecords;
	
	SET @TotalPages = CEILING(@TotalRecords / CAST(@PageSize AS DECIMAL));
	SET @MinIndex = ((@PageIndex - 1) * @PageSize) + 1;
	SET @MaxIndex = @MinIndex + (@PageSize - 1);

	SELECT 
		  F.FdpFeatureId
		, F.ProgrammeId
		, F.Gateway
		, F.FeatureCode
		, F.FeatureDescription AS [Description]
		, F.CreatedOn
		, F.CreatedBy
		, F.UpdatedOn
		, F.UpdatedBy
		, F.IsActive

	FROM @PageRecords		AS P
	JOIN Fdp_Feature		AS F	ON	P.FdpFeatureId = F.FdpFeatureId
									AND P.RowIndex BETWEEN @MinIndex AND @MaxIndex;