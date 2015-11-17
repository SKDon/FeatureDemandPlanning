CREATE PROCEDURE dbo.Fdp_Trim_Delete
	  @FdpTrimId INT
	, @CDSId NVARCHAR(100)
AS
	SET NOCOUNT ON;
	
	UPDATE Fdp_Trim SET 
		IsActive = 0,
		UpdatedBy = @CDSId,
		UpdatedOn = GETDATE()
	WHERE
	FdpTrimId = @FdpTrimId;
	
	EXEC Fdp_Trim_Get @FdpTrimId;