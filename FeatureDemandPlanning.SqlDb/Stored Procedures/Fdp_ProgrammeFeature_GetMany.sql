CREATE PROCEDURE [dbo].[Fdp_ProgrammeFeature_GetMany]
	  @DocumentId INT
	, @FeatureId INT = NULL
	, @FdpFeatureId INT = NULL
	, @FeaturePackId INT = NULL
AS

	SELECT 
		  F.FeatureId AS Id
		, F.FdpFeatureId
		, F.CreatedOn
		, F.CreatedBy
		, F.ProgrammeId
		, F.Gateway
		, F.MappedFeatureCode AS FeatureCode
		, F.BrandDescription
		, F.[Description]
		, F.FeatureGroupId
		, F.FeatureGroup
		, F.FeatureSubGroup
		, F.FeaturePackId
		, F.FeaturePackCode
		, F.FeaturePackName
		, F.FeatureComment
		, F.LongDescription
		, F.FeatureRuleText
		, F.DisplayOrder
		, F.IsMappedFeature
		, F.IsFdpFeature
		, F.FdpFeatureMappingId
		, F.UpdatedOn
		, F.UpdatedBy
	FROM Fdp_FeatureMapping_VW	AS F 
	JOIN OXO_Doc				AS D	ON	F.ProgrammeId	= D.Programme_Id
										AND F.Gateway		= D.Gateway
	WHERE
	D.Id = @DocumentId
	AND
	(@FeatureId IS NULL OR F.FeatureId = @FeatureId)
	AND
	(@FdpFeatureId IS NULL OR F.FdpFeatureId = @FdpFeatureId)
	AND
	(@FeaturePackId IS NULL OR F.FeaturePackId = @FeaturePackId);