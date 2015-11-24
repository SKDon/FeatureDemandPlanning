CREATE PROCEDURE [dbo].[Fdp_DerivativeMapping_GetMany]
	  @CarLine					NVARCHAR(10)	= NULL
	, @ModelYear				NVARCHAR(10)	= NULL
	, @Gateway					NVARCHAR(16)	= NULL
	, @IncludeAllDerivatives	BIT = 0
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
		, DerivativeCode NVARCHAR(20)
		, MappedDerivativeCode NVARCHAR(20)
		, ProgrammeId INT
		, Gateway NVARCHAR(200)
	);
	INSERT INTO @PageRecords (DerivativeCode, MappedDerivativeCode, ProgrammeId, Gateway)
	SELECT 
		  D.ImportDerivativeCode
		, D.MappedDerivativeCode
		, D.ProgrammeId
		, D.Gateway
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
	(
		(@IncludeAllDerivatives = 0 AND D.IsMappedDerivative = 1)
		OR
		(@IncludeAllDerivatives = 1)
	)
	
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
		, D.ProgrammeId
		, D.Gateway
		, D.BodyId
		, D.EngineId
		, D.TransmissionId
		, D.IsMappedDerivative
		, D.UpdatedOn
		, D.UpdatedBy

	FROM @PageRecords				AS P
	JOIN Fdp_DerivativeMapping_VW	AS D	ON	P.DerivativeCode = D.ImportDerivativeCode
											AND P.MappedDerivativeCode = D.MappedDerivativeCode
											AND P.ProgrammeId = D.ProgrammeId
											AND P.Gateway = D.Gateway
											AND P.RowIndex BETWEEN @MinIndex AND @MaxIndex;