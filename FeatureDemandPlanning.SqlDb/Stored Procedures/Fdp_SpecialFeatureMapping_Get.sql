CREATE PROCEDURE [dbo].[Fdp_SpecialFeatureMapping_Get] 
	@FdpSpecialFeatureMappingId INT
AS
	SET NOCOUNT ON;

	SELECT 
		  SF.FdpSpecialFeatureMappingId
		, SF.ProgrammeId
		, SF.Gateway
		, SF.ImportFeatureCode AS FeatureCode
		, SF.FdpSpecialFeatureTypeId
		, SF.SpecialFeatureType
		, SF.[Description]
		, SF.CreatedOn
		, SF.CreatedBy
		, SF.UpdatedOn
		, SF.UpdatedBy
		, SF.IsActive

	FROM Fdp_SpecialFeatureMapping_VW		AS SF
	WHERE 
	SF.FdpSpecialFeatureMappingId = @FdpSpecialFeatureMappingId;