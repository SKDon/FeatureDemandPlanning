CREATE PROCEDURE [dbo].[Fdp_TrimMapping_GetMany]
	  @CarLine					NVARCHAR(10)	= NULL
	, @ModelYear				NVARCHAR(10)	= NULL
	, @Gateway					NVARCHAR(16)	= NULL
	, @DPCK						NVARCHAR(20)	= NULL
	, @IncludeAllTrim			BIT = 0
	, @OxoTrimOnly				BIT = 0
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
		  RowIndex			INT IDENTITY(1, 1)
		, CreatedOn			DATETIME
		, CreatedBy			NVARCHAR(16)
		, DocumentId		INT
		, ImportTrim		NVARCHAR(1000) NULL
		, DPCK				NVARCHAR(1000) NULL
		, ProgrammeId		INT
		, Gateway			NVARCHAR(200)
		, TrimId			INT
		, Name				NVARCHAR(2000) 
		, [Level]			NVARCHAR(2000)
		, IsMappedTrim		BIT
		, UpdatedOn			DATETIME NULL
		, UpdatedBy			NVARCHAR(16) NULL
		, FdpTrimMappingId	INT NULL
	);
	INSERT INTO @PageRecords 
	(
		  CreatedOn			
		, CreatedBy			
		, DocumentId		
		, ImportTrim		
		, DPCK		
		, ProgrammeId		
		, Gateway			
		, TrimId
		, Name
		, [Level]
		, IsMappedTrim		
		, UpdatedOn			
		, UpdatedBy			
		, FdpTrimMappingId	
	)
	SELECT
		  T.CreatedOn
		, T.CreatedBy
		, T.DocumentId 
		, T.ImportTrim
		, T.DPCK
		, T.ProgrammeId
		, T.Gateway
		, T.TrimId
		, T.MappedTrim
		, T.[Level]
		, T.IsMappedTrim
		, T.UpdatedOn
		, T.UpdatedBy
		, T.FdpTrimMappingId
	FROM
	Fdp_TrimMapping_VW			AS T
	JOIN OXO_Programme_VW		AS P ON T.ProgrammeId = P.Id
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
		(@IncludeAllTrim = 1)
	)
	AND
	(
		(@OxoTrimOnly = 0)
		OR
		(@OxoTrimOnly = 1 AND T.IsMappedTrim = 0)
	)
	AND
	(@DPCK IS NULL OR (T.DPCK = @DPCK OR T.DPCK IS NULL))
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
		  T.CreatedOn
		, T.CreatedBy
		, T.FdpTrimMappingId
		, T.ImportTrim
		, T.DPCK
		, T.DocumentId
		, T.ProgrammeId
		, T.Gateway
		, T.TrimId
		, T.Name
		, T.[Level]
		, T.IsMappedTrim
		, T.UpdatedOn
		, T.UpdatedBy

	FROM @PageRecords				AS T
	WHERE T.RowIndex BETWEEN @MinIndex AND @MaxIndex;