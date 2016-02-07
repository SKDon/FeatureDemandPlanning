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
	DECLARE @Models AS TABLE
	(	
		ModelId INT
	);
	DECLARE @ModelIdentifiers AS NVARCHAR(MAX);

	INSERT INTO @Models (ModelId)
	SELECT DISTINCT M.ModelId
	FROM
	Fdp_TakeRateSummaryByModelAndMarket_VW AS M
	WHERE
	M.FdpVolumeHeaderId = @FdpVolumeHeaderId
	AND
	(@MarketId IS NULL OR M.MarketId = @MarketId);

	SELECT @ModelIdentifiers = COALESCE(@ModelIdentifiers+',' ,'') + '[' + CAST(ModelId AS NVARCHAR(10)) + ']' FROM @Models;

	WITH ApplicabilityForMarket AS
	(
		SELECT
			  M.Market_Id	AS MarketId
			, FA.Model_Id	AS ModelId
			, FA.Feature_Id AS FeatureId
			, F.EFGName
			, MAX(P.Pack_Id)		AS FeaturePackId
			, MAX(FA.OXO_Code)	AS OxoCode
		FROM
		Fdp_VolumeHeader_VW						AS H 
		JOIN OXO_Programme_MarketGroupMarket_VW AS M	ON	H.ProgrammeId	= M.Programme_Id
		CROSS APPLY dbo.FN_OXO_Data_Get_FBM_Market(H.DocumentId, M.Market_Group_Id, M.Market_Id, @ModelIdentifiers) AS FA
		JOIN OXO_Programme_Feature_VW			AS F	ON	H.ProgrammeId	= F.ProgrammeId
													AND FA.Feature_Id	= F.ID
		LEFT JOIN OXO_Pack_Feature_Link			AS P	ON	H.ProgrammeId	= P.Programme_Id
													AND F.ID			= P.Feature_Id
		WHERE
		H.FdpVolumeHeaderId = @FdpVolumeHeaderId
		AND
		(@MarketId IS NULL OR M.Market_Id = @MarketId)
		GROUP BY
		M.Market_Id, FA.Model_Id, FA.Feature_Id, F.EFGName
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