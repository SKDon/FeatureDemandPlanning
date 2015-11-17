CREATE PROCEDURE [dbo].[Fdp_Feature_Get] 
	@FdpFeatureId INT
AS
	SET NOCOUNT ON;

	SELECT 
		  FdpFeatureId
		, ProgrammeId
		, Gateway
		, FeatureCode
		, FeatureGroupId
		, FeatureDescription AS BrandDescription
		, CreatedOn
		, CreatedBy
		, UpdatedOn
		, UpdatedBy
		, IsActive

	FROM Fdp_Feature
	WHERE 
	FdpFeatureId = @FdpFeatureId;