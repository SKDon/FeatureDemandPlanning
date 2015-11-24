





CREATE VIEW [dbo].[Fdp_SpecialFeatureMapping_VW] AS

	SELECT
		  S.FdpSpecialFeatureId AS FdpSpecialFeatureMappingId
		, S.CreatedOn
		, S.CreatedBy
		, S.ProgrammeId
		, S.Gateway				AS Gateway
		, S.FdpSpecialFeatureId	AS FeatureId
		, S.FeatureCode			AS ImportFeatureCode
		, S.FeatureCode			AS MappedFeatureCode
		, T.FdpSpecialFeatureTypeId
		, T.SpecialFeatureType
		, T.[Description]
		, CAST(1 AS BIT)		AS IsMappedFeature
		, S.IsActive
		, S.UpdatedOn
		, S.UpdatedBy
	FROM
	OXO_Programme_VW		AS P 
	JOIN Fdp_Gateways_VW	AS G		ON	P.Id		= G.ProgrammeId
	JOIN Fdp_SpecialFeature	AS S		ON	P.Id		= S.ProgrammeId
										AND G.Gateway	= S.Gateway
	JOIN Fdp_SpecialFeatureType AS T	ON	S.FdpSpecialFeatureTypeId 
														= T.FdpSpecialFeatureTypeId