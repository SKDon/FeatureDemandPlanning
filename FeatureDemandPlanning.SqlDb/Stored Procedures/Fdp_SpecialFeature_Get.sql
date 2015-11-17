CREATE PROCEDURE [dbo].[Fdp_SpecialFeature_Get] 
	@FdpSpecialFeatureId INT
AS
	SET NOCOUNT ON;

	SELECT 
		  SF.FdpSpecialFeatureId
		, SF.ProgrammeId
		, SF.Gateway
		, SF.FeatureCode
		, SFT.FdpSpecialFeatureTypeId
		, SFT.SpecialFeatureType
		, SFT.[Description] AS FeatureDescription
		, SF.CreatedOn
		, SF.CreatedBy
		, SF.UpdatedOn
		, SF.UpdatedBy
		, SF.IsActive

	FROM Fdp_SpecialFeature		AS SF
	JOIN Fdp_SpecialFeatureType AS SFT ON SF.FdpSpecialFeatureTypeId = SFT.FdpSpecialFeatureTypeId
	WHERE 
	SF.FdpSpecialFeatureId = @FdpSpecialFeatureId;