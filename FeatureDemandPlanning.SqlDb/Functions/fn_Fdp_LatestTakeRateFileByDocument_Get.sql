CREATE FUNCTION dbo.fn_Fdp_LatestTakeRateFileByDocument_Get
(
	@DocumentId AS INT
)
RETURNS INT
AS
BEGIN
	DECLARE @FdpVolumeHeaderId AS INT;

	SELECT TOP 1 @FdpVolumeHeaderId = FdpVolumeHeaderId
	FROM
	Fdp_VolumeHeader AS H
	WHERE
	H.DocumentId = @DocumentId
	ORDER BY
	H.FdpVolumeHeaderId DESC;

	RETURN @FdpVolumeHeaderId;

END