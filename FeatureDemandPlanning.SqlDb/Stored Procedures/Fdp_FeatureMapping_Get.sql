CREATE PROCEDURE [dbo].[Fdp_FeatureMapping_Get]
	  @FdpFeatureMappingId	INT
AS
	SET NOCOUNT ON;
		
	SELECT 
		  MAP.FdpFeatureMappingId
		, MAP.ImportFeatureCode
		, MAP.DocumentId
		, MAP.ProgrammeId
		, MAP.Gateway
		, MAP.FeatureId
		, MAP.FeaturePackId
		, F.Feat_Code AS FeatureCode
		, ISNULL(B.Brand_Desc, F.[Description]) AS [Description]
		, MAP.CreatedOn
		, MAP.CreatedBy
		, MAP.IsActive
		, MAP.UpdatedOn
		, MAP.UpdatedBy
		
	  FROM Fdp_FeatureMapping			AS MAP
	  JOIN OXO_Feature_Ext				AS F	ON MAP.FeatureId	= F.Id
	  LEFT JOIN OXO_Feature_Brand_Desc	AS B	ON F.Feat_Code		= B.Feat_Code
	  WHERE 
	  FdpFeatureMappingId = @FdpFeatureMappingId
	  
	UNION
	  
	SELECT 
		  MAP.FdpFeatureMappingId
		, MAP.ImportFeatureCode
		, MAP.DocumentId
		, MAP.ProgrammeId
		, MAP.Gateway
		, MAP.FeatureId
		, MAP.FeaturePackId
		, P.Feature_Code AS FeatureCode
		, P.Pack_Name AS [Description]
		, MAP.CreatedOn
		, MAP.CreatedBy
		, MAP.IsActive
		, MAP.UpdatedOn
		, MAP.UpdatedBy
		
	  FROM Fdp_FeatureMapping			AS MAP
	  JOIN OXO_Programme_Pack			AS P	ON MAP.FeaturePackId	= P.Id
	  WHERE 
	  FdpFeatureMappingId = @FdpFeatureMappingId;