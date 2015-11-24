CREATE PROCEDURE [dbo].[Fdp_FeatureMapping_Get]
	  @FdpFeatureMappingId	INT
AS
	SET NOCOUNT ON;
		
	SELECT 
		  FdpFeatureMappingId
		, ImportFeatureCode
		, ProgrammeId
		, Gateway
		, FeatureId
		, F.Feat_Code AS FeatureCode
		, ISNULL(B.Brand_Desc, F.[Description]) AS [Description]
		, CreatedOn
		, CreatedBy
		, IsActive
		, UpdatedOn
		, UpdatedBy
		
	  FROM Fdp_FeatureMapping			AS MAP
	  JOIN OXO_Feature_Ext				AS F	ON MAP.FeatureId	= F.Id
	  LEFT JOIN OXO_Feature_Brand_Desc	AS B	ON F.Feat_Code		= B.Feat_Code
	  WHERE 
	  FdpFeatureMappingId = @FdpFeatureMappingId;