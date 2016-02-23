CREATE FUNCTION dbo.fn_Fdp_Changeset_GetLatestByUser
(
	  @FdpVolumeHeaderId	INT
	, @MarketId				INT
	, @CDSId				NVARCHAR(16)
)
RETURNS INT
AS
BEGIN
	DECLARE @FdpChangesetId AS INT;
	
	SELECT TOP 1 @FdpChangesetId = C.FdpChangesetId
	FROM
	Fdp_VolumeHeader_VW	AS H
	JOIN Fdp_Changeset	AS C	ON H.FdpVolumeHeaderId = C.FdpVolumeHeaderId
	WHERE
	H.FdpVolumeHeaderId = @FdpVolumeHeaderId
	AND
	C.CreatedBy = @CDSID
	AND
	C.IsDeleted = 0
	AND
	C.IsSaved = 0
	AND
	C.MarketId = @MarketId
	ORDER BY
	C.CreatedOn DESC;
	
	RETURN @FdpChangesetId;

END