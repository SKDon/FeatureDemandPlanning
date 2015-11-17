

CREATE VIEW [dbo].[Fdp_FeatureMapping_VW] AS

	SELECT 
		  P.Id			AS ProgrammeId
		, G.Gateway		AS Gateway
		, F.Id			AS FeatureId
		, F.Feat_Code	AS ImportFeatureCode
		, F.Feat_Code	AS MappedFeatureCode
	FROM
	OXO_Programme AS P
	JOIN Fdp_Gateways_VW					AS G	ON	P.Id			= G.ProgrammeId
	JOIN OXO_Vehicle_Feature_Applicability	AS A	ON	P.Vehicle_Id	= A.Vehicle_Id
	JOIN OXO_Feature_Ext					AS F	ON	A.Feature_id	= F.Id
	LEFT JOIN Fdp_FeatureMapping			AS M	ON	P.Id			= M.ProgrammeId
													AND	A.Feature_id	= M.FeatureId
													AND G.Gateway		= M.Gateway
													AND M.IsActive		= 1
	WHERE
	M.FdpFeatureMappingId IS NULL
	
	UNION
	
	SELECT
		  P.Id					AS ProgrammeId
		, M.Gateway				AS Gateway
		, F.Id					AS FeatureId
		, M.ImportFeatureCode	AS ImportFeatureCode
		, F.Feat_Code			AS MappedFeatureCode
	FROM
	OXO_Programme							AS P
	JOIN Fdp_Gateways_VW					AS G	ON	P.Id			= G.ProgrammeId
	JOIN Fdp_FeatureMapping					AS M	ON	P.Id			= M.ProgrammeId
													AND G.Gateway		= M.Gateway
													AND M.IsActive		= 1
	JOIN OXO_Vehicle_Feature_Applicability	AS A	ON	P.Vehicle_Id	= A.Vehicle_Id
													AND M.FeatureId		= A.Feature_id
	JOIN OXO_Feature_Ext					AS F	ON	F.Id			= M.FeatureId