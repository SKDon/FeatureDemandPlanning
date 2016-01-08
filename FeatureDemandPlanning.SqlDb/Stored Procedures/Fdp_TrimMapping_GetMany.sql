CREATE PROCEDURE [dbo].[Fdp_TrimMapping_GetMany]
	  @CarLine					NVARCHAR(10)	= NULL
	, @ModelYear				NVARCHAR(10)	= NULL
	, @Gateway					NVARCHAR(16)	= NULL
	, @DerivativeCode			NVARCHAR(20)	= NULL
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
		, MappedTrim NVARCHAR(1000)
		, ProgrammeId INT
		, Gateway NVARCHAR(200)
	);
	INSERT INTO @PageRecords (Trim, MappedTrim, ProgrammeId, Gateway)
	SELECT T.ImportTrim, T.MappedTrim, T.ProgrammeId, T.Gateway
	FROM
	Fdp_TrimMapping_VW AS T
	JOIN OXO_Programme_VW	 AS P ON T.ProgrammeId = P.Id
	LEFT JOIN OXO_Programme_Model AS M ON P.Id  = M.Programme_Id
										AND M.Active = 1
	WHERE
	(@CarLine IS NULL OR P.VehicleName = @CarLine)
	AND
	(@ModelYear IS NULL OR P.ModelYear = @ModelYear)
	AND
	(@Gateway IS NULL OR T.Gateway = @Gateway)
	AND
	(
		(
			@IncludeAllTrim = 0 
			AND
			M.Trim_Id = T.TrimId
			AND
			(@DerivativeCode IS NULL OR M.BMC = @DerivativeCode)
			AND
			T.IsMappedTrim = 0
		)
		OR
		(@IncludeAllTrim = 1)
	)
	AND
	(@DerivativeCode IS NULL OR (T.BMC = @DerivativeCode OR T.BMC IS NULL))
	AND
	T.IsActive = 1;
	
	SELECT @TotalRecords = COUNT(1) FROM @PageRecords;
	SELECT @TotalDisplayRecords = @TotalRecords;
	
	IF ISNULL(@PageSize, 0) = 0
		SET @PageSize = @TotalRecords;
	
	SET @TotalPages = CEILING(@TotalRecords / CAST(@PageSize AS DECIMAL));
	SET @MinIndex = ((@PageIndex - 1) * @PageSize) + 1;
	SET @MaxIndex = @MinIndex + (@PageSize - 1);

	SELECT DISTINCT
		  T.TrimId
		, T.FdpTrimId
		, T.FdpTrimMappingId
		, T.CreatedOn
		, T.CreatedBy
		, T.ImportTrim
		, T.MappedTrim AS Name
		, T.ProgrammeId
		, T.Gateway
		, T.BMC
		, T.[Level]
		, T.DPCK
		, T.IsFdpTrim
		, T.UpdatedOn
		, T.UpdatedBy

	FROM @PageRecords				AS P
	JOIN Fdp_TrimMapping_VW	AS T	ON	P.Trim = T.ImportTrim
									AND P.ProgrammeId = T.ProgrammeId
									AND P.Gateway = T.Gateway
									AND P.MappedTrim = T.MappedTrim
									AND P.RowIndex BETWEEN @MinIndex AND @MaxIndex
									AND T.IsActive = 1;