CREATE PROCEDURE [dbo].[Fdp_FeatureMapping_GetMany]
	  @CarLine					NVARCHAR(10)	= NULL
	, @ModelYear				NVARCHAR(10)	= NULL
	, @Gateway					NVARCHAR(16)	= NULL
	, @IncludeAllFeatures		BIT = 0
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
		, FeatureCode NVARCHAR(20)
	);
	INSERT INTO @PageRecords (FeatureCode)
	SELECT F.ImportFeatureCode
	FROM
	Fdp_FeatureMapping_VW AS F
	JOIN OXO_Programme_VW	 AS P ON F.ProgrammeId = P.Id
	WHERE
	(@CarLine IS NULL OR P.VehicleName = @CarLine)
	AND
	(@ModelYear IS NULL OR P.ModelYear = @ModelYear)
	AND
	(@Gateway IS NULL OR F.Gateway = @Gateway)
	AND
	(
		(@IncludeAllFeatures = 0 AND F.IsMappedFeature = 1)
		OR
		(@IncludeAllFeatures = 1 AND F.IsMappedFeature = 0)
	)
	AND
	F.IsMappedFeature = 1;
	
	SELECT @TotalRecords = COUNT(1) FROM @PageRecords;
	SELECT @TotalDisplayRecords = @TotalRecords;
	
	IF ISNULL(@PageSize, 0) = 0
		SET @PageSize = @TotalRecords;
	
	SET @TotalPages = CEILING(@TotalRecords / CAST(@PageSize AS DECIMAL));
	SET @MinIndex = ((@PageIndex - 1) * @PageSize) + 1;
	SET @MaxIndex = @MinIndex + (@PageSize - 1);

	SELECT DISTINCT
		  F.CreatedOn
		, F.CreatedBy
		, F.FdpFeatureMappingId
		, F.ImportFeatureCode
		, F.MappedFeatureCode AS FeatureCode
		, F.ProgrammeId
		, F.Gateway
		, F.[Description]
		, F.IsMappedFeature
		, F.UpdatedOn
		, F.UpdatedBy

	FROM @PageRecords				AS P
	JOIN Fdp_FeatureMapping_VW		AS F	ON	P.FeatureCode = F.ImportFeatureCode
											AND P.RowIndex BETWEEN @MinIndex AND @MaxIndex;