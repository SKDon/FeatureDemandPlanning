CREATE PROCEDURE [dbo].[Fdp_SpecialFeatureMapping_Copy] 
	  @FdpSpecialFeatureMappingId	INT = NULL
	, @SourceDocumentId				INT = NULL
	, @TargetDocumentId				INT
	, @CDSId						NVARCHAR(16)
AS
	SET NOCOUNT ON;
	
	DECLARE @ProgrammeId AS INT;
	DECLARE @Gateway AS NVARCHAR(100);
	
	SELECT TOP 1 @ProgrammeId = Programme_Id, @Gateway = Gateway
	FROM
	OXO_Doc
	WHERE
	Id = @TargetDocumentId;
	
	INSERT INTO Fdp_SpecialFeature
	(
		  CreatedBy
		, DocumentId
		, ProgrammeId
		, Gateway
		, FeatureCode
		, FdpSpecialFeatureTypeId
	)
	SELECT 
		  @CDSId
		, @TargetDocumentId
		, @ProgrammeId
		, @Gateway
		, S.FeatureCode
		, S.FdpSpecialFeatureTypeId
	FROM
	Fdp_SpecialFeature				AS S 
	LEFT JOIN Fdp_SpecialFeature	AS EXISTING ON	S.FeatureCode		= EXISTING.FeatureCode
												AND EXISTING.IsActive	= 1
												AND EXISTING.DocumentId = @TargetDocumentId
	WHERE
	(@FdpSpecialFeatureMappingId IS NULL OR S.FdpSpecialFeatureId = @FdpSpecialFeatureMappingId)
	AND
	(@SourceDocumentId IS NULL OR S.DocumentId = @SourceDocumentId)
	AND 
	EXISTING.FdpSpecialFeatureId IS NULL
	AND
	S.IsActive = 1