







CREATE VIEW [dbo].[Fdp_FeatureMapping_VW] AS
	
	SELECT
		  F.FeatureId
		, F.FdpFeatureId
		, F.CreatedOn
		, F.CreatedBy
		, D.Id AS DocumentId
		, D.Programme_Id		AS ProgrammeId
		, D.Gateway
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
		, F.ExclusiveFeatureGroup
	FROM
	OXO_Doc					AS D
	JOIN OXO_Programme		AS P	ON	D.Programme_Id	= P.Id
	JOIN Fdp_Feature_VW		AS F	ON	D.Id			= F.DocumentId
							
	UNION
	
	SELECT
		  M.FeatureId
		, NULL					AS FdpFeatureId
		, M.CreatedOn
		, M.CreatedBy
		, D.Id					AS DocumentId
		, D.Programme_Id		AS ProgrammeId
		, D.Gateway
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
		, F.ExclusiveFeatureGroup
	FROM
	OXO_Doc							AS D
	JOIN OXO_Programme				AS P	ON	D.Programme_Id	= P.Id 
	JOIN Fdp_Feature_VW				AS F	ON	D.Id			= F.DocumentId
	JOIN Fdp_FeatureMapping			AS M	ON	F.DocumentId	= M.DocumentId
											AND F.FeatureId		= M.FeatureId
											AND M.IsActive		= 1
											AND F.FeatureCode	<> M.ImportFeatureCode
											
	UNION
	
	SELECT
		  M.FeatureId
		, NULL					AS FdpFeatureId
		, M.CreatedOn
		, M.CreatedBy
		, F.DocumentId
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
		, F.ExclusiveFeatureGroup
	FROM
	OXO_Doc							AS D
	JOIN OXO_Programme				AS P	ON D.Programme_Id	= P.Id 
	JOIN Fdp_Feature_VW				AS F	ON	D.Id			= F.DocumentId
	JOIN Fdp_FeatureMapping			AS M	ON	D.Id			= M.DocumentId
											AND F.FeaturePackId	= M.FeaturePackId
											AND M.IsActive		= 1
											AND F.FeatureId		IS NULL
											AND F.FeatureCode   <> M.ImportFeatureCode