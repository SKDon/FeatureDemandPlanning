CREATE PROCEDURE [dbo].[Fdp_Derivative_GetMany] 
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
		, FdpDerivativeId INT
	);
	INSERT INTO @PageRecords (FdpDerivativeId)
	SELECT D.FdpDerivativeId
	FROM
	Fdp_Derivative AS D
	JOIN OXO_Programme_VW	 AS P ON D.ProgrammeId = P.Id
	WHERE
	(@CarLine IS NULL OR P.VehicleName = @CarLine)
	AND
	(@ModelYear IS NULL OR P.ModelYear = @ModelYear)
	AND
	(@Gateway IS NULL OR D.Gateway = @Gateway)
	AND
	D.IsActive = 1
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
		  D.FdpDerivativeId
		, D.ProgrammeId
		, D.Gateway
		, D.DerivativeCode
		, D.BodyId
		, D.EngineId
		, D.TransmissionId
		, D.CreatedOn
		, D.CreatedBy
		, D.UpdatedOn
		, D.UpdatedBy
		, D.IsActive

	FROM @PageRecords		AS P
	JOIN Fdp_Derivative		AS D	ON	P.FdpDerivativeId = D.FdpDerivativeId
									AND P.RowIndex BETWEEN @MinIndex AND @MaxIndex;