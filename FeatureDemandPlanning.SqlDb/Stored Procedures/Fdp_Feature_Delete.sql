CREATE PROCEDURE [dbo].[Fdp_Feature_Delete]
	  @FdpFeatureId INT
	, @CDSId NVARCHAR(16)
AS
	SET NOCOUNT ON;
	
	UPDATE Fdp_Feature SET 
		  IsActive = 0
		, UpdatedOn = GETDATE()
		, UpdatedBy = @CDSId 
	WHERE
	FdpFeatureId = @FdpFeatureId;
	
	EXEC Fdp_Feature_Get @FdpFeatureId;