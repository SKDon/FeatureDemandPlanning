CREATE PROCEDURE [dbo].[Fdp_OxoDerivative_GetMany]
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
		, IsArchived BIT
		, UpdatedOn DATETIME NULL
		, UpdatedBy NVARCHAR(16) NULL
		, FdpDerivativeMappingId INT NULL
	);
	WITH DistinctDerivatives AS
	(
		SELECT D.Id AS DocumentId, M.BMC, M.Body_Id, M.Engine_Id, M.Transmission_Id
		FROM
		OXO_Doc							AS D
		JOIN OXO_Programme_VW			AS P	ON D.Programme_Id		= P.Id
												AND P.Active			= 1
		JOIN OXO_Programme_Model		AS M	ON P.Id					= M.Programme_Id
												AND M.Active			= 1
		JOIN OXO_Programme_Body			AS B	ON M.Body_Id			= B.Id
												AND B.Active			= 1
		JOIN OXO_Programme_Engine		AS E	ON	M.Engine_Id			= E.Id
												AND E.Active			= 1
		JOIN OXO_Programme_Transmission AS T	ON M.Transmission_Id	= T.Id
												AND T.Active			= 1
		WHERE
		ISNULL(D.Archived, 0) = 0
		GROUP BY
		D.Id, M.BMC, M.Body_Id, M.Engine_Id, M.Transmission_Id
		
		UNION
		
		SELECT D.Id AS DocumentId, M.BMC, M.Body_Id, M.Engine_Id, M.Transmission_Id
		FROM
		OXO_Doc									AS D
		JOIN OXO_Programme_VW					AS P	ON	D.Programme_Id		= P.Id
														AND P.Active			= 1
		JOIN OXO_Archived_Programme_Model		AS M	ON	D.Id				= M.Doc_Id
														AND M.Active			= 1
		JOIN OXO_Archived_Programme_Body		AS B	ON	D.Id				= B.Doc_Id
														AND M.Body_Id			= B.Id
														AND B.Active			= 1
		JOIN OXO_Archived_Programme_Engine		AS E	ON	D.Id				= E.Doc_Id
														AND M.Engine_Id			= E.Id
														AND E.Active			= 1
		JOIN OXO_Archived_Programme_Transmission AS T	ON	D.Id				= T.Doc_Id 
														AND M.Transmission_Id	= T.Id
														AND T.Active			= 1
		WHERE
		ISNULL(D.Archived, 1) = 1
		GROUP BY
		D.Id, M.BMC, M.Body_Id, M.Engine_Id, M.Transmission_Id
	)
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
		, IsArchived
		, UpdatedOn
		, UpdatedBy
		, FdpDerivativeMappingId
	)
	SELECT 
		  NULL
		, NULL
		, D.DocumentId
		, D.BMC AS ImportDerivativeCode
		, D.BMC AS MappedDerivativeCode
		, D1.Programme_Id AS ProgrammeId 
		, D1.Gateway
		, D.Body_Id AS BodyId
		, D.Engine_Id AS EngineId
		, D.Transmission_Id AS TransmissionId
		, CAST(0 AS BIT) AS IsMappedDerivative
		, ISNULL(D1.Archived, 0) AS IsArchived
		, NULL
		, NULL
		, CAST(NULL AS INT) AS FdpDerivativeMappingId
	FROM
	DistinctDerivatives		AS D
	JOIN OXO_Doc			AS D1	ON D.DocumentId = D1.Id
	JOIN OXO_Programme_VW	AS P	ON D1.Programme_Id = P.Id
	WHERE
	(@CarLine IS NULL OR P.VehicleName = @CarLine)
	AND
	(@ModelYear IS NULL OR P.ModelYear = @ModelYear)
	AND
	(@Gateway IS NULL OR D1.Gateway = @Gateway)
	AND
	(@DocumentId IS NULL OR D.DocumentId = @DocumentId)
	ORDER BY
	D.DocumentId, 
	P.VehicleName, 
	P.ModelYear, 
	D1.Gateway, 
	ISNULL(D.BMC, '00000'), 
	EngineId,
	BodyId, 
	TransmissionId

	SELECT @TotalRecords = COUNT(1) FROM @PageRecords;
	SELECT @TotalDisplayRecords = @TotalRecords;
	
	IF ISNULL(@PageSize, 0) = 0
		SET @PageSize = @TotalRecords;
		
	IF @PageSize = 0
		SET @PageSize = 100;
	
	SET @TotalPages = CEILING(@TotalRecords / CAST(@PageSize AS DECIMAL));
	SET @MinIndex = ((@PageIndex - 1) * @PageSize) + 1;
	SET @MaxIndex = @MinIndex + (@PageSize - 1);

	SELECT 
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
		, D.IsArchived
		, D.UpdatedOn
		, D.UpdatedBy

	FROM @PageRecords				AS D
	WHERE D.RowIndex BETWEEN @MinIndex AND @MaxIndex
	ORDER BY RowIndex;