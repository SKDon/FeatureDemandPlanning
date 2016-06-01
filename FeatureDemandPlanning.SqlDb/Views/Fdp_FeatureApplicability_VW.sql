CREATE VIEW Fdp_FeatureApplicability_VW AS

	WITH ApplicabilityForMarket AS
	(
		SELECT
			  D.Id	AS DocumentId
			, FA.MarketId
			, FA.ModelId
			, FA.FeatureId
			, F.EFGName
			, FA.FeaturePackId
			, FA.Applicability AS OxoCode
		FROM
		OXO_Doc								AS D
		JOIN Fdp_FeatureApplicability		AS FA	ON	D.Id			= FA.DocumentId
		LEFT JOIN OXO_Programme_Feature_VW	AS F	ON	D.Programme_Id	= F.ProgrammeId
													AND FA.FeatureId	= F.ID
	)
	SELECT
		  A.DocumentId 
		, A.MarketId
		, A.ModelId
		, A.FeatureId
		, A.EFGName
		, A.FeaturePackId
		, COUNT(A.FeatureId) OVER (PARTITION BY A.DocumentId, A.MarketId, A.ModelId, A.EfgName) AS FeaturesInExclusiveFeatureGroup
		, CAST(CASE WHEN A.OxoCode LIKE '%S%' THEN 1 ELSE 0 END AS BIT) AS IsStandardFeatureInGroup 
		, CAST(CASE WHEN A.OxoCode LIKE '%O%' THEN 1 ELSE 0 END AS BIT) AS IsOptionalFeatureInGroup
		, CAST(CASE WHEN A.OxoCode LIKE '%NA%' THEN 1 ELSE 0 END AS BIT) AS IsNonApplicableFeatureInGroup
		, COUNT(CASE WHEN A.OxoCode NOT LIKE '%NA%' THEN A.FeatureId ELSE NULL END) OVER (PARTITION BY A.DocumentId, A.MarketId, A.ModelId, A.EfgName) AS ApplicableFeaturesInExclusiveFeatureGroup
		, A.OxoCode -- We are only interested in the applicability at this market level, not any
										-- parent group or globaly
	FROM 
	ApplicabilityForMarket AS A