CREATE FUNCTION [dbo].[fn_Fdp_FeatureApplicability_GetMany]
(
	  @FdpVolumeHeaderId	INT
	, @MarketId				INT
)
RETURNS 
@FeatureApplicability TABLE
(
	  MarketId	INT
	, FeatureId INT
	, FeaturePackId INT
	, EFGName	NVARCHAR(100)
	, FeaturesInExclusiveFeatureGroup INT
	, IsStandardFeatureInGroup BIT
	, IsOptionalFeatureInGroup BIT
	, IsNonApplicableFeatureInGroup BIT
	, ApplicableFeaturesInExclusiveFeatureGroup INT
	, ModelId	INT
	, OxoCode	NVARCHAR(10)
)
AS
BEGIN
	
	;WITH ApplicabilityForMarket AS
	(
		SELECT
			  FA.MarketId
			, FA.ModelId
			, FA.FeatureId
			, F.EFGName
			, FA.FeaturePackId
			, FA.Applicability AS OxoCode
		FROM
		Fdp_VolumeHeader_VW AS H
		JOIN Fdp_FeatureApplicability		AS FA	ON	H.DocumentId	= FA.DocumentId
		LEFT JOIN OXO_Programme_Feature_VW	AS F	ON	H.ProgrammeId	= F.ProgrammeId
													AND FA.FeatureId	= F.ID
		WHERE
		H.FdpVolumeHeaderId = @FdpVolumeHeaderId
		AND
		FA.MarketId = @MarketId
	)
	INSERT INTO @FeatureApplicability
	(
		  MarketId
		, ModelId
		, FeatureId
		, EFGName
		, FeaturePackId
		, FeaturesInExclusiveFeatureGroup
		, IsStandardFeatureInGroup
		, IsOptionalFeatureInGroup
		, IsNonApplicableFeatureInGroup
		, ApplicableFeaturesInExclusiveFeatureGroup
		, OxoCode
	)
	SELECT 
		  A.MarketId
		, A.ModelId
		, A.FeatureId
		, A.EFGName
		, A.FeaturePackId
		, COUNT(A.FeatureId) OVER (PARTITION BY A.ModelId, A.EfgName) AS FeaturesInExclusiveFeatureGroup
		, CAST(CASE WHEN A.OxoCode LIKE '%S%' THEN 1 ELSE 0 END AS BIT) AS IsStandardFeatureInGroup 
		, CAST(CASE WHEN A.OxoCode LIKE '%O%' THEN 1 ELSE 0 END AS BIT) AS IsOptionalFeatureInGroup
		, CAST(CASE WHEN A.OxoCode LIKE '%NA%' THEN 1 ELSE 0 END AS BIT) AS IsNonApplicableFeatureInGroup
		, COUNT(CASE WHEN A.OxoCode NOT LIKE '%NA%' THEN A.FeatureId ELSE NULL END) OVER (PARTITION BY A.ModelId, A.EfgName) AS ApplicableFeaturesInExclusiveFeatureGroup
		, A.OxoCode -- We are only interested in the applicability at this market level, not any
										-- parent group or globaly
	FROM 
	ApplicabilityForMarket AS A

	RETURN
END