CREATE PROCEDURE [dbo].[Fdp_TrimMapping_GetMany]
	  @CarLine					NVARCHAR(10)	= NULL
	, @ModelYear				NVARCHAR(10)	= NULL
	, @Gateway					NVARCHAR(16)	= NULL
	, @IncludeAllTrim			BIT = 0
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
		, Trim NVARCHAR(1000)
	);
	INSERT INTO @PageRecords (Trim)
	SELECT T.ImportTrim
	FROM
	Fdp_TrimMapping_VW AS T
	JOIN OXO_Programme_VW	 AS P ON T.ProgrammeId = P.Id
	WHERE
	(@CarLine IS NULL OR P.VehicleName = @CarLine)
	AND
	(@ModelYear IS NULL OR P.ModelYear = @ModelYear)
	AND
	(@Gateway IS NULL OR T.Gateway = @Gateway)
	AND
	(
		(@IncludeAllTrim = 0 AND T.IsMappedTrim = 1)
		OR
		(@IncludeAllTrim = 1 AND T.IsMappedTrim = 0)
	)
	
	SELECT @TotalRecords = COUNT(1) FROM @PageRecords;
	SELECT @TotalDisplayRecords = @TotalRecords;
	
	IF ISNULL(@PageSize, 0) = 0
		SET @PageSize = @TotalRecords;
	
	SET @TotalPages = CEILING(@TotalRecords / CAST(@PageSize AS DECIMAL));
	SET @MinIndex = ((@PageIndex - 1) * @PageSize) + 1;
	SET @MaxIndex = @MinIndex + (@PageSize - 1);

	SELECT DISTINCT
		  T.CreatedOn
		, T.CreatedBy
		, T.FdpTrimMappingId
		, T.ImportTrim
		, T.MappedTrim AS Name
		, T.ProgrammeId
		, T.Gateway
		, T.[Level]
		, T.DPCK
		, T.UpdatedOn
		, T.UpdatedBy

	FROM @PageRecords				AS P
	JOIN Fdp_TrimMapping_VW	AS T	ON	P.Trim = T.ImportTrim
									AND P.RowIndex BETWEEN @MinIndex AND @MaxIndex;