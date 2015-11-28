CREATE PROCEDURE [dbo].[Fdp_Trim_GetMany]
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
		, FdpTrimId INT
	);
	INSERT INTO @PageRecords (FdpTrimId)
	SELECT T.FdpTrimId
	FROM
	Fdp_Trim AS T
	JOIN OXO_Programme_VW	 AS P ON T.ProgrammeId = P.Id
	WHERE
	(@CarLine IS NULL OR P.VehicleName = @CarLine)
	AND
	(@ModelYear IS NULL OR P.ModelYear = @ModelYear)
	AND
	(@Gateway IS NULL OR T.Gateway = @Gateway)
	AND
	T.IsActive = 1
	
	SELECT @TotalRecords = COUNT(1) FROM @PageRecords;
	SELECT @TotalDisplayRecords = @TotalRecords;
	
	IF ISNULL(@PageSize, 0) = 0
		SET @PageSize = @TotalRecords;
	
	SET @TotalPages = CEILING(@TotalRecords / CAST(@PageSize AS DECIMAL));
	SET @MinIndex = ((@PageIndex - 1) * @PageSize) + 1;
	SET @MaxIndex = @MinIndex + (@PageSize - 1);

	SELECT 
		  T.FdpTrimId
		, T.ProgrammeId
		, T.Gateway
		, T.BMC
		, T.TrimName AS Name
		, T.TrimLevel AS [Level]
		, T.CreatedOn
		, T.CreatedBy
		, T.UpdatedOn
		, T.UpdatedBy
		, T.IsActive

	FROM @PageRecords		AS P
	JOIN Fdp_Trim			AS T	ON	P.FdpTrimId = T.FdpTrimId
									AND P.RowIndex BETWEEN @MinIndex AND @MaxIndex;