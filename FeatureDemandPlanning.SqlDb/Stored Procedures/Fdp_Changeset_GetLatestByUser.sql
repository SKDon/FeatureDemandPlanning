CREATE PROCEDURE [dbo].[Fdp_Changeset_GetLatestByUser]
	  @FdpVolumeHeaderId	AS INT
	, @MarketId				AS INT
	, @CDSID				AS NVARCHAR(16)
	, @IsSaved				AS BIT = 0
AS
	SET NOCOUNT ON;
	
	DECLARE @FdpChangesetId AS INT;
	
	SELECT @FdpChangesetId = dbo.fn_Fdp_Changeset_GetLatestByUser(@FdpVolumeHeaderId, @MarketId, @CDSID)
	
	EXEC Fdp_Changeset_Get @FdpChangesetId = @FdpChangesetId;