CREATE PROCEDURE [dbo].[Fdp_DerivativeMapping_Copy] 
	  @FdpDerivativeMappingId	INT = NULL
	, @SourceDocumentId			INT = NULL
	, @TargetDocumentId			INT
	, @CDSId					NVARCHAR(16)
AS
	SET NOCOUNT ON;
	
	DECLARE @ProgrammeId AS INT;
	DECLARE @Gateway AS NVARCHAR(100);
	
	SELECT TOP 1 @ProgrammeId = Programme_Id, @Gateway = Gateway
	FROM
	OXO_Doc
	WHERE
	Id = @TargetDocumentId;
	
	INSERT INTO Fdp_DerivativeMapping
	(
		  CreatedBy
		, DocumentId
		, ProgrammeId
		, Gateway
		, ImportDerivativeCode
		, DerivativeCode
		, BodyId
		, EngineId
		, TransmissionId
	)
	SELECT 
		  @CDSId
		, @TargetDocumentId
		, @ProgrammeId
		, @Gateway
		, M.ImportDerivativeCode
		, M.DerivativeCode
		, M.BodyId
		, M.EngineId
		, M.TransmissionId
	FROM
	Fdp_DerivativeMapping			AS M
	LEFT JOIN Fdp_DerivativeMapping	AS EXISTING ON	M.ImportDerivativeCode	= EXISTING.ImportDerivativeCode
												AND M.DerivativeCode		= EXISTING.DerivativeCode
												AND EXISTING.IsActive		= 1
												AND EXISTING.DocumentId = @TargetDocumentId
	WHERE
	(@FdpDerivativeMappingId IS NULL OR M.FdpDerivativeMappingId = @FdpDerivativeMappingId)
	AND
	(@SourceDocumentId IS NULL OR M.DocumentId = @SourceDocumentId)
	AND 
	EXISTING.FdpDerivativeMappingId IS NULL
	AND
	M.IsActive = 1