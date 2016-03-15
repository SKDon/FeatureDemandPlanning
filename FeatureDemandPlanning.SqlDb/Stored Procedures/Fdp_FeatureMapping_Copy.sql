CREATE PROCEDURE [dbo].[Fdp_FeatureMapping_Copy] 
	  @FdpFeatureMappingId	INT = NULL
	, @SourceDocumentId		INT = NULL
	, @TargetDocumentId		INT
	, @CDSId NVARCHAR(16)
AS
	SET NOCOUNT ON;
	
	DECLARE @ProgrammeId AS INT;
	DECLARE @Gateway AS NVARCHAR(100);
	
	SELECT TOP 1 @ProgrammeId = Programme_Id, @Gateway = Gateway
	FROM
	OXO_Doc
	WHERE
	Id = @TargetDocumentId;
	
	INSERT INTO Fdp_FeatureMapping
	(
		  CreatedBy
		, DocumentId
		, ProgrammeId
		, Gateway
		, ImportFeatureCode
		, FeatureId
		, FeaturePackId
	)
	SELECT 
		  @CDSId
		, @TargetDocumentId
		, @ProgrammeId
		, @Gateway
		, M.ImportFeatureCode
		, M.FeatureId
		, M.FeaturePackId
	FROM
	Fdp_FeatureMapping				AS M
	LEFT JOIN Fdp_FeatureMapping	AS EXISTING ON  M.ImportFeatureCode	= EXISTING.ImportFeatureCode
												AND M.FeatureId			= EXISTING.FeatureId
												AND EXISTING.DocumentId = @TargetDocumentId
	WHERE
	(@FdpFeatureMappingId IS NULL OR M.FdpFeatureMappingId = @FdpFeatureMappingId)
	AND
	(@SourceDocumentId IS NULL OR M.DocumentId = @SourceDocumentId)
	AND 
	EXISTING.FdpFeatureMappingId IS NULL
	AND
	M.IsActive = 1
	
	UNION
	
	SELECT 
		  @CDSId
		, @TargetDocumentId
		, @ProgrammeId
		, @Gateway
		, M.ImportFeatureCode
		, M.FeatureId
		, M.FeaturePackId
	FROM
	Fdp_FeatureMapping				AS M 
	LEFT JOIN Fdp_FeatureMapping	AS EXISTING ON  M.ImportFeatureCode	= EXISTING.ImportFeatureCode
												AND M.FeaturePackId		= EXISTING.FeaturePackId
												AND EXISTING.DocumentId = @TargetDocumentId
	WHERE
	(@FdpFeatureMappingId IS NULL OR M.FdpFeatureMappingId = @FdpFeatureMappingId)
	AND
	(@SourceDocumentId IS NULL OR M.DocumentId = @SourceDocumentId)
	AND 
	EXISTING.FdpFeatureMappingId IS NULL
	AND
	M.IsActive = 1