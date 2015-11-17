CREATE PROCEDURE dbo.Fdp_SpecialFeatureType_GetMany
AS
	SET NOCOUNT ON;
	
	SELECT 
		  FdpSpecialFeatureTypeId
		, SpecialFeatureType
		, [Description]
	FROM Fdp_SpecialFeatureType
	ORDER BY SpecialFeatureType