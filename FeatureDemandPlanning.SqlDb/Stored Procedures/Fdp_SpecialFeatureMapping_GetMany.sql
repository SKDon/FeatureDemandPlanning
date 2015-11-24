CREATE PROCEDURE [dbo].[Fdp_SpecialFeatureMapping_GetMany] 
	  @CarLine					NVARCHAR(10)	= NULL
	, @ModelYear				NVARCHAR(10)	= NULL
	, @Gateway					NVARCHAR(16)	= NULL
	, @IncludeAllFeatures		BIT = 1
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
		, FdpSpecialFeatureMappingId INT
	);
	INSERT INTO @PageRecords (FdpSpecialFeatureMappingId)
	SELECT S.FdpSpecialFeatureMappingId
	FROM
	Fdp_SpecialFeatureMapping_VW AS S
	JOIN OXO_Programme_VW	 AS P ON S.ProgrammeId = P.Id
	WHERE
	(@CarLine IS NULL OR P.VehicleName = @CarLine)
	AND
	(@ModelYear IS NULL OR P.ModelYear = @ModelYear)
	AND
	(@Gateway IS NULL OR S.Gateway = @Gateway)
	AND
	S.IsActive = 1;
	
	SELECT @TotalRecords = COUNT(1) FROM @PageRecords;
	SELECT @TotalDisplayRecords = @TotalRecords;
	
	IF ISNULL(@PageSize, 0) = 0
		SET @PageSize = @TotalRecords;
	
	SET @TotalPages = CEILING(@TotalRecords / CAST(@PageSize AS DECIMAL));
	SET @MinIndex = ((@PageIndex - 1) * @PageSize) + 1;
	SET @MaxIndex = @MinIndex + (@PageSize - 1);

	SELECT DISTINCT
		  S.CreatedOn
		, S.CreatedBy
		, S.FdpSpecialFeatureMappingId
		, S.ImportFeatureCode
		, S.MappedFeatureCode		 AS FeatureCode
		, S.SpecialFeatureType
		, S.[Description]			
		, S.ProgrammeId
		, S.Gateway
		, S.IsMappedFeature
		, S.UpdatedOn
		, S.UpdatedBy

	FROM @PageRecords					AS P
	JOIN Fdp_SpecialFeatureMapping_VW	AS S	ON	P.FdpSpecialFeatureMappingId = S.FdpSpecialFeatureMappingId
												AND P.RowIndex BETWEEN @MinIndex AND @MaxIndex;