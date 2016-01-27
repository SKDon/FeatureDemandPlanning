



CREATE VIEW [dbo].[Fdp_FeatureMapping_VW] AS
	
	SELECT
		  F.FeatureId
		, F.FdpFeatureId
		, F.CreatedOn
		, F.CreatedBy
		, F.ProgrammeId
		, F.Gateway				AS Gateway
		, F.FeatureCode			AS ImportFeatureCode
		, F.FeatureCode			AS MappedFeatureCode
		, F.BrandDescription
		, F.SystemDescription	AS [Description]
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
		, CAST(0 AS BIT)		AS IsMappedFeature
		, F.IsFdpFeature
		, CAST(NULL AS INT)		AS FdpFeatureMappingId
		, F.UpdatedOn
		, F.UpdatedBy 
	FROM
	OXO_Programme			AS P
	JOIN Fdp_Feature_VW		AS F	ON	P.Id = F.ProgrammeId
							
	UNION
	
	SELECT
		  M.FeatureId
		, NULL					AS FdpFeatureId
		, M.CreatedOn
		, M.CreatedBy
		, F.ProgrammeId
		, M.Gateway				AS Gateway
		, M.ImportFeatureCode	AS ImportFeatureCode
		, F.FeatureCode			AS MappedFeatureCode
		, F.BrandDescription
		, F.SystemDescription	AS [Description]
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
		, CAST(1 AS BIT)		AS IsMappedFeature
		, F.IsFdpFeature
		, M.FdpFeatureMappingId
		, M.UpdatedOn
		, M.UpdatedBy
	FROM
	OXO_Programme					AS P 
	JOIN Fdp_Feature_VW				AS F	ON	P.Id			= F.ProgrammeId
	JOIN Fdp_FeatureMapping			AS M	ON	F.ProgrammeId	= M.ProgrammeId
											AND F.Gateway		= M.Gateway
											AND F.FeatureId		= M.FeatureId
											AND M.IsActive		= 1
											AND F.FeatureCode	<> M.ImportFeatureCode
											
	UNION
	
	SELECT
		  M.FeatureId
		, NULL					AS FdpFeatureId
		, M.CreatedOn
		, M.CreatedBy
		, F.ProgrammeId
		, M.Gateway				AS Gateway
		, M.ImportFeatureCode	AS ImportFeatureCode
		, F.FeatureCode			AS MappedFeatureCode
		, F.BrandDescription
		, F.SystemDescription	AS [Description]
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
		, CAST(1 AS BIT)		AS IsMappedFeature
		, F.IsFdpFeature
		, M.FdpFeatureMappingId
		, M.UpdatedOn
		, M.UpdatedBy
	FROM
	OXO_Programme					AS P 
	JOIN Fdp_Feature_VW				AS F	ON	P.Id			= F.ProgrammeId
	JOIN Fdp_FeatureMapping			AS M	ON	F.ProgrammeId	= M.ProgrammeId
											AND F.Gateway		= M.Gateway
											AND F.FeaturePackId	= M.FeaturePackId
											AND M.IsActive		= 1
											AND F.FeatureId		IS NULL
											AND F.FeatureCode   <> M.ImportFeatureCode