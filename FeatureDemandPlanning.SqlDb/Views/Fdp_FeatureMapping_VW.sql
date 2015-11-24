



CREATE VIEW [dbo].[Fdp_FeatureMapping_VW] AS

	SELECT 
		  NULL				AS FdpFeatureMappingId
		, E.Created_On		AS CreatedOn
		, E.Created_By		AS CreatedBy
		, F.ProgrammeId
		, G.Gateway			AS Gateway
		, F.Id				AS FeatureId
		, F.FeatureCode		AS ImportFeatureCode
		, F.FeatureCode		AS MappedFeatureCode
		, ISNULL(F.BrandDescription, F.SystemDescription) AS [Description]
		, CAST(0 AS BIT)	AS IsMappedFeature
		, E.Last_Updated	AS UpdatedOn
		, E.Updated_By		AS UpdatedBy
	FROM
	OXO_Programme_Feature_VW		AS F 
	JOIN OXO_Feature_Ext			AS E	ON	F.FeatureCode	= E.Feat_Code
	JOIN Fdp_Gateways_VW			AS G	ON	F.ProgrammeId	= G.ProgrammeId
	LEFT JOIN Fdp_FeatureMapping	AS M	ON	F.ProgrammeId	= M.ProgrammeId
											AND G.Gateway		= M.Gateway
											AND F.ID			= M.FeatureId
											AND M.IsActive		= 1
	WHERE
	M.FdpFeatureMappingId IS NULL
	
	UNION
	
	SELECT
		  M.FdpFeatureMappingId
		, M.CreatedOn
		, M.CreatedBy
		, F.ProgrammeId
		, M.Gateway				AS Gateway
		, F.Id					AS FeatureId
		, M.ImportFeatureCode	AS ImportFeatureCode
		, F.FeatureCode			AS MappedFeatureCode
		, ISNULL(F.BrandDescription, F.SystemDescription) AS [Description]
		, CAST(1 AS BIT)		AS IsMappedFeature
		, M.UpdatedOn
		, M.UpdatedBy
	FROM
	OXO_Programme_Feature_VW		AS F 
	JOIN OXO_Feature_Ext			AS E	ON	F.FeatureCode	= E.Feat_Code
	JOIN Fdp_Gateways_VW			AS G	ON	F.ProgrammeId	= G.ProgrammeId
	JOIN Fdp_FeatureMapping			AS M	ON	F.ProgrammeId	= M.ProgrammeId
											AND G.Gateway		= M.Gateway
											AND F.ID			= M.FeatureId
											AND M.IsActive		= 1