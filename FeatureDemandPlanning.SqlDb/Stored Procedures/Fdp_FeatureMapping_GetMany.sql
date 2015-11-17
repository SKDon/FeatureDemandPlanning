CREATE PROCEDURE [dbo].[Fdp_FeatureMapping_GetMany]
	  @ProgrammeId	INT				= NULL
	, @Gateway		NVARCHAR(100)	= NULL
	, @CDSId		NVARCHAR(16)
AS
	SET NOCOUNT ON;
		
	SELECT 
		  MAP.FdpFeatureMappingId
		, MAP.ImportFeatureCode
		, MAP.ProgrammeId
		, MAP.Gateway
		, F.Id AS FeatureId
		, F.Feat_Code AS FeatureCode
		, ISNULL(B.Brand_Desc, F.[Description]) AS FeatureDescription
		, MAP.CreatedOn
		, MAP.CreatedBy
		, MAP.IsActive
		, MAP.UpdatedOn
		, MAP.UpdatedBy
		
	  FROM Fdp_FeatureMapping			AS MAP
	  JOIN OXO_Feature_Ext				AS F	ON MAP.FeatureId	= F.Id
	  LEFT JOIN OXO_Feature_Brand_Desc	AS B	ON F.Feat_Code		= B.Feat_Code
	  WHERE 
	  (@ProgrammeId IS NULL OR MAP.ProgrammeId = @ProgrammeId)
	  AND
	  (@Gateway IS NULL OR MAP.Gateway = @Gateway)
	  AND
	  MAP.IsActive = 1
	  ORDER BY
	  MAP.ImportFeatureCode