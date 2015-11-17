CREATE PROCEDURE [dbo].[Fdp_SpecialFeature_Delete] 
	  @FdpSpecialFeatureId INT
	, @CDSId NVARCHAR(16)
AS
	SET NOCOUNT ON;

	UPDATE Fdp_SpecialFeature SET
		IsActive = 0
		, UpdatedBy = @CDSId
		, UpdatedOn = GETDATE()
	WHERE
	FdpSpecialFeatureId = @FdpSpecialFeatureId;
	
	EXEC Fdp_SpecialFeature_Get @FdpSpecialFeatureId;