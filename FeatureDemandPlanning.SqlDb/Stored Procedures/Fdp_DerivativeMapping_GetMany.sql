CREATE PROCEDURE [dbo].[Fdp_DerivativeMapping_GetMany]
	  @CarLine					NVARCHAR(10)	= NULL
	, @ModelYear				NVARCHAR(10)	= NULL
	, @Gateway					NVARCHAR(16)	= NULL
	, @DocumentId				INT				= NULL
	, @IncludeAllDerivatives	BIT = 0
	, @OxoDerivativesOnly		BIT = 0
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
	
	IF ISNULL(@PageIndex, 0) = 0 
		SET @PageIndex = 1;
	
	DECLARE @MinIndex AS INT;
	DECLARE @MaxIndex AS INT;
	DECLARE @PageRecords AS TABLE
	(
		  RowIndex INT IDENTITY(1, 1)
		, CreatedOn		DATETIME
		, CreatedBy		NVARCHAR(16)
		, DocumentId	INT
		, ImportDerivativeCode NVARCHAR(20) NULL
		, MappedDerivativeCode NVARCHAR(20) NULL
		, ProgrammeId INT
		, Gateway NVARCHAR(200)
		, BodyId	INT
		, EngineId	INT
		, TransmissionId INT
		, IsMappedDerivative BIT
		, UpdatedOn DATETIME NULL
		, UpdatedBy NVARCHAR(16) NULL
		, FdpDerivativeMappingId INT NULL
	);
	INSERT INTO @PageRecords 
	(
		  CreatedOn
		, CreatedBy
		, DocumentId
		, ImportDerivativeCode
		, MappedDerivativeCode
		, ProgrammeId
		, Gateway
		, BodyId
		, EngineId
		, TransmissionId
		, IsMappedDerivative
		, UpdatedOn
		, UpdatedBy
		, FdpDerivativeMappingId
	)
	SELECT
		  D.CreatedOn
		, D.CreatedBy
		, D.DocumentId 
		, D.ImportDerivativeCode
		, D.MappedDerivativeCode
		, D.ProgrammeId
		, D.Gateway
		, D.BodyId
		, D.EngineId
		, D.TransmissionId
		, D.IsMappedDerivative
		, D.UpdatedOn
		, D.UpdatedBy
		, D.FdpDerivativeMappingId
	FROM
	Fdp_DerivativeMapping_VW AS D
	JOIN OXO_Programme_VW	 AS P ON D.ProgrammeId = P.Id
	WHERE
	(@CarLine IS NULL OR P.VehicleName = @CarLine)
	AND
	(@ModelYear IS NULL OR P.ModelYear = @ModelYear)
	AND
	(@Gateway IS NULL OR D.Gateway = @Gateway)
	AND
	(@DocumentId IS NULL OR D.DocumentId = @DocumentId)
	AND
	(
		(@IncludeAllDerivatives = 0 AND D.IsMappedDerivative = 1)
		OR
		(@IncludeAllDerivatives = 1)
	)
	AND
	(
		(@OxoDerivativesOnly = 0)
		OR
		(@OxoDerivativesOnly = 1 AND D.IsMappedDerivative = 0)
	)
	ORDER BY
	P.VehicleName, P.ModelYear, D.Gateway
	
	SELECT @TotalRecords = COUNT(1) FROM @PageRecords;
	SELECT @TotalDisplayRecords = @TotalRecords;
	
	IF ISNULL(@PageSize, 0) = 0
		SET @PageSize = @TotalRecords;
	
	SET @TotalPages = CEILING(@TotalRecords / CAST(@PageSize AS DECIMAL));
	SET @MinIndex = ((@PageIndex - 1) * @PageSize) + 1;
	SET @MaxIndex = @MinIndex + (@PageSize - 1);

	SELECT DISTINCT
		  D.CreatedOn
		, D.CreatedBy
		, D.FdpDerivativeMappingId
		, D.ImportDerivativeCode
		, D.MappedDerivativeCode AS DerivativeCode
		, D.DocumentId
		, D.ProgrammeId
		, D.Gateway
		, D.BodyId
		, D.EngineId
		, D.TransmissionId
		, D.IsMappedDerivative
		, D.UpdatedOn
		, D.UpdatedBy

	FROM @PageRecords				AS D
	WHERE D.RowIndex BETWEEN @MinIndex AND @MaxIndex;