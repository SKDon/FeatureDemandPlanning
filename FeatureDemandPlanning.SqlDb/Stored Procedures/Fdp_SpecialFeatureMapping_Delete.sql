CREATE PROCEDURE [dbo].[Fdp_SpecialFeatureMapping_Delete] 
	  @FdpSpecialFeatureMappingId INT
	, @CDSId NVARCHAR(16)
AS
	SET NOCOUNT ON;

	UPDATE Fdp_SpecialFeature SET
		IsActive = 0
		, UpdatedBy = @CDSId
		, UpdatedOn = GETDATE()
	WHERE
	FdpSpecialFeatureId = @FdpSpecialFeatureMappingId;
	
	EXEC Fdp_SpecialFeatureMapping_Get @FdpSpecialFeatureMappingId;