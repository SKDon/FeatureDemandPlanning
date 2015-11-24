CREATE PROCEDURE [dbo].[Fdp_FeatureMapping_Delete] 
	  @FdpFeatureMappingId INT
	, @CDSId NVARCHAR(16)
AS
	SET NOCOUNT ON;

	UPDATE Fdp_FeatureMapping SET
		IsActive = 0
		, UpdatedBy = @CDSId
		, UpdatedOn = GETDATE()
	WHERE
	FdpFeatureMappingId = @FdpFeatureMappingId;
	
	EXEC Fdp_FeatureMapping_Get @FdpFeatureMappingId;