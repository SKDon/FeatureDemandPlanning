CREATE PROCEDURE [dbo].[Fdp_TrimMapping_Copy] 
	  @FdpTrimMappingId		INT = NULL
	, @SourceDocumentId		INT = NULL
	, @TargetDocumentId		INT
	, @CDSId				NVARCHAR(16)
AS
	SET NOCOUNT ON;
	
	DECLARE @ProgrammeId AS INT;
	DECLARE @Gateway AS NVARCHAR(100);
	
	SELECT TOP 1 @ProgrammeId = Programme_Id, @Gateway = Gateway
	FROM
	OXO_Doc
	WHERE
	Id = @TargetDocumentId;

	INSERT INTO Fdp_TrimMapping
	(
		  CreatedBy
		, DocumentId
		, ProgrammeId
		, Gateway
		, ImportTrim
		, BMC
		, TrimId
	)
	SELECT 
		  @CDSId
		, @TargetDocumentId
		, @ProgrammeId
		, @Gateway
		, M.ImportTrim
		, M.BMC
		, M.TrimId
	FROM
	Fdp_TrimMapping				AS M 
	LEFT JOIN Fdp_TrimMapping	AS EXISTING ON M.ImportTrim	= EXISTING.ImportTrim
											AND M.TrimId			= EXISTING.TrimId
											AND M.BMC				= EXISTING.BMC
											AND EXISTING.IsActive	= 1
											AND EXISTING.DocumentId = @TargetDocumentId				
	WHERE
	(@FdpTrimMappingId IS NULL OR M.FdpTrimMappingId = @FdpTrimMappingId)
	AND
	(@SourceDocumentId IS NULL OR M.DocumentId = @SourceDocumentId)
	AND 
	EXISTING.FdpTrimMappingId IS NULL
	AND
	M.IsActive = 1