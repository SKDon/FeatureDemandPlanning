CREATE PROCEDURE [dbo].[Fdp_Feature_GetMany] 
	  @ProgrammeId	INT				= NULL
	, @Gateway		NVARCHAR(100)	= NULL
	, @CDSId		NVARCHAR(16)
AS
	SET NOCOUNT ON;

	SELECT 
		  FdpFeatureId
		, ProgrammeId
		, Gateway
		, FeatureCode
		, FeatureGroupId
		, FeatureDescription AS BrandDescription
		, CreatedOn
		, CreatedBy
		, UpdatedOn
		, UpdatedBy
		, IsActive

	FROM Fdp_Feature
	WHERE 
	(@ProgrammeId IS NULL OR ProgrammeId = @ProgrammeId)
	AND
	(@Gateway IS NULL OR Gateway = @Gateway)
	AND
	IsActive = 1;