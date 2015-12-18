CREATE PROCEDURE dbo.Fdp_SpecialFeatureType_GetMany
AS
	SET NOCOUNT ON;
	
	SELECT 
		  FdpSpecialFeatureTypeId
		, SpecialFeatureType
		, [Description]
	FROM dbo.Fdp_SpecialFeatureType
	ORDER BY SpecialFeatureType