CREATE PROCEDURE [dbo].[Fdp_FeatureMapping_GetMany]
	  @CarLine					NVARCHAR(10)	= NULL
	, @ModelYear				NVARCHAR(10)	= NULL
	, @Gateway					NVARCHAR(16)	= NULL
	, @IncludeAllFeatures		BIT = 0
	, @OxoFeaturesOnly			BIT = 0
	, @CDSId					NVARCHAR(16)
	, @FilterMessage			NVARCHAR(50)	= NULL
	, @PageIndex				INT				= NULL
	, @PageSize					INT				= 10
	, @SortIndex				INT				= 1
	, @SortDirection			VARCHAR(5)		= 'ASC'
	, @Filter					NVARCHAR(MAX)	= NULL
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
		, CreatedOn		DATETIME
		, CreatedBy		NVARCHAR(16)
		, ImportFeatureCode NVARCHAR(20) NULL
		, MappedFeatureCode NVARCHAR(20) NULL
		, DocumentId INT
		, ProgrammeId INT
		, Gateway NVARCHAR(200)
		, [Description]	NVARCHAR(2000)
		, IsMappedFeature BIT
		, UpdatedOn DATETIME NULL
		, UpdatedBy NVARCHAR(16) NULL
		, FdpFeatureMappingId INT NULL
		, IsPack BIT
		, FeatureId INT NULL
		, FeaturePackId INT NULL
	);
	INSERT INTO @PageRecords 
	(
		  CreatedOn
		, CreatedBy
		, ImportFeatureCode
		, MappedFeatureCode
		, DocumentId
		, ProgrammeId
		, Gateway
		, [Description]
		, IsMappedFeature
		, UpdatedOn
		, UpdatedBy
		, FdpFeatureMappingId
		, IsPack
		, FeatureId
		, FeaturePackId
	)
	SELECT
		  F.CreatedOn
		, F.CreatedBy
		, F.ImportFeatureCode
		, F.MappedFeatureCode
		, F.DocumentId
		, F.ProgrammeId
		, F.Gateway
		, ISNULL(F.BrandDescription, F.[Description])
		, F.IsMappedFeature
		, F.UpdatedOn
		, F.UpdatedBy
		, F.FdpFeatureMappingId
		, CAST(CASE WHEN F.FeaturePackId IS NOT NULL AND F.FeatureId IS NULL THEN 1 ELSE 0 END AS BIT) AS IsPack
		, F.FeatureId
		, F.FeaturePackId
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
		(@IncludeAllFeatures = 1)
	)
	AND
	(
		(@OxoFeaturesOnly = 0)
		OR
		(@OxoFeaturesOnly = 1 AND F.IsMappedFeature = 0)
	)
	AND
	(@Filter IS NULL OR F.MappedFeatureCode LIKE '%' + @Filter + '%' OR ISNULL(F.BrandDescription, F.[Description]) LIKE '%' + @Filter + '%')
	ORDER BY MappedFeatureCode
	
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
		, F.DocumentId
		, F.ProgrammeId
		, F.Gateway
		, F.[Description]
		, F.IsMappedFeature
		, F.UpdatedOn
		, F.UpdatedBy
		, F.IsPack
		, F.FeatureId
		, F.FeaturePackId

	FROM @PageRecords				AS F
	WHERE F.RowIndex BETWEEN @MinIndex AND @MaxIndex;