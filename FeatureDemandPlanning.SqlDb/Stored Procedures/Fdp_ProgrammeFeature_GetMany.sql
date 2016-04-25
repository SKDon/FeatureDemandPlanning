CREATE PROCEDURE [dbo].[Fdp_ProgrammeFeature_GetMany]
	  @DocumentId INT
	, @FeatureId INT = NULL
	, @FdpFeatureId INT = NULL
	, @FeaturePackId INT = NULL
AS
	SELECT
		  F.FeatureId AS Id
		, F.FeatureId
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
	F.FeatureId IS NOT NULL
	AND
	(@FeatureId IS NULL OR F.FeatureId = @FeatureId)
	
	UNION
	
	SELECT
		  CAST(NULL AS INT) AS Id
		, CAST(NULL AS INT) AS FeatureId
		, CAST(NULL AS INT) AS FdpFeatureId
		, MAX(F.CreatedOn) AS CreatedOn
		, MAX(F.CreatedBy) AS CreatedBy
		, F.ProgrammeId
		, F.Gateway
		, F.FeaturePackCode
		, MAX(F.BrandDescription) AS BrandDescription
		, MAX(F.[Description]) AS [Description]
		, F.FeatureGroupId
		, F.FeatureGroup
		, F.FeatureSubGroup
		, F.FeaturePackId
		, F.FeaturePackCode
		, MAX(F.FeaturePackName) AS FeaturePackName
		, MAX(F.FeatureComment) AS FeatureComment
		, MAX(F.LongDescription) AS LongDescription
		, MAX(F.FeatureRuleText) AS FeatureRuleText
		, MAX(F.DisplayOrder) AS DisplayOrder
		, CAST(0 AS BIT) AS IsMappedFeature
		, CAST(0 AS BIT) AS IsFdpFeature
		, CAST(NULL AS INT) AS FdpFeatureMappingId
		, MAX(F.UpdatedOn) AS UpdatedOn
		, MAX(F.UpdatedBy) AS UpdatedBy
		
	FROM Fdp_FeatureMapping_VW	AS F 
	JOIN OXO_Doc				AS D	ON	F.ProgrammeId	= D.Programme_Id
										AND F.Gateway		= D.Gateway
	WHERE
	D.Id = @DocumentId
	AND
	F.FeatureId IS NULL
	AND
	F.FeaturePackId IS NOT NULL
	AND
	(@FdpFeatureId IS NULL OR F.FdpFeatureId = @FdpFeatureId)
	AND
	(@FeaturePackId IS NULL OR F.FeaturePackId = @FeaturePackId)
	GROUP BY
	F.ProgrammeId, F.Gateway, F.FeaturePackCode, F.FeatureGroupId, F.FeatureGroup, F.FeatureSubGroup, F.FeaturePackId