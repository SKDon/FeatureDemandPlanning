






CREATE VIEW [dbo].[Fdp_SpecialFeatureMapping_VW] AS

	SELECT
		  S.FdpSpecialFeatureId AS FdpSpecialFeatureMappingId
		, S.CreatedOn
		, S.CreatedBy
		, S.DocumentId
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
	OXO_Doc					AS D
	JOIN Fdp_SpecialFeature	AS S		ON	D.Id		= S.DocumentId
	JOIN Fdp_SpecialFeatureType AS T	ON	S.FdpSpecialFeatureTypeId 
														= T.FdpSpecialFeatureTypeId