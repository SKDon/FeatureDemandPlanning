CREATE PROCEDURE dbo.Fdp_Changeset_Delete
	  @FdpVolumeHeaderId	AS INT
	, @MarketId				AS INT
	, @CDSID				AS NVARCHAR(16)
AS
	SET NOCOUNT ON;
	
	UPDATE C SET 
		IsDeleted = 1
		
	FROM Fdp_VolumeHeader	AS H
	JOIN Fdp_Changeset		AS C ON H.FdpVolumeHeaderId = C.FdpVolumeHeaderId
	WHERE
	H.FdpVolumeHeaderId = @FdpVolumeHeaderId
	AND
	C.MarketId = @MarketId
	AND 
	C.IsDeleted = 0
	AND
	C.CreatedBy = @CDSID;
	
	EXEC Fdp_Changeset_GetLatestByUser @FdpVolumeHeaderId = @FdpVolumeHeaderId, @MarketId = @MarketId, @CDSID = @CDSID