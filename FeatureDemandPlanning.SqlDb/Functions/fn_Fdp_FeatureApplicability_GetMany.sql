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
		, OxoCode
	)
	SELECT 
		  M.Market_Id
		, FA.Model_Id	AS ModelId
		, FA.Feature_Id AS FeatureId
		, F.EFGName
		, P.Pack_Id		AS FeaturePackId
		, COUNT(FA.Feature_Id) OVER (PARTITION BY FA.Model_Id, F.EfgName) AS FeaturesInExclusiveFeatureGroup
		, CAST(CASE WHEN MAX(FA.OXO_Code) LIKE '%S%' THEN 1 ELSE 0 END AS BIT) AS IsStandardFeatureInGroup 
		, CAST(CASE WHEN MAX(FA.OXO_Code) LIKE '%O%' THEN 1 ELSE 0 END AS BIT) AS IsOptionalFeatureInGroup
		, MAX(FA.OXO_Code)	AS OxoCode -- We are only interested in the applicability at this market level, not any
										-- parent group or globaly
	FROM 
	Fdp_VolumeHeader_VW						AS H 
	JOIN OXO_Programme_MarketGroupMarket_VW AS M	ON	H.ProgrammeId	= M.Programme_Id
	CROSS APPLY dbo.FN_OXO_Data_Get_FBM_Market(H.DocumentId, M.Market_Group_Id, M.Market_Id, @ModelIdentifiers) AS FA
	JOIN OXO_Programme_Feature_VW			AS F	ON	H.ProgrammeId	= F.ProgrammeId
													AND FA.Feature_Id	= F.ID
	LEFT JOIN OXO_Pack_Feature_Link			AS P	ON	H.ProgrammeId	= P.Programme_Id
													AND F.ID			= P.Feature_Id
	
	WHERE
	(@MarketId IS NULL OR M.Market_Id = @MarketId)
	--AND
	--FA.OXO_Code NOT LIKE '%NA%' -- Ignore features that are not available for that market / model as they will skew the count of available features in an EFG
	GROUP BY
	M.Market_Id, FA.Model_Id, FA.Feature_Id, F.EFGName, P.Pack_Id

	RETURN
END