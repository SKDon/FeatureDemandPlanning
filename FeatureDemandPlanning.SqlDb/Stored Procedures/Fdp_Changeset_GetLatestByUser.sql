CREATE PROCEDURE [dbo].[Fdp_Changeset_GetLatestByUser]
	  @DocumentId	AS INT
	, @CDSID		AS NVARCHAR(16)
	, @IsSaved		AS BIT = 0
AS
	SET NOCOUNT ON;
	
	DECLARE @FdpChangesetId AS INT;
	
	SELECT TOP 1 @FdpChangesetId = C.FdpChangesetId
	FROM
	Fdp_VolumeHeader	AS H
	JOIN Fdp_Changeset	AS C	ON H.FdpVolumeHeaderId = C.FdpVolumeHeaderId
	WHERE
	H.DocumentId = @DocumentId
	AND
	C.CreatedBy = @CDSID
	AND
	C.IsDeleted = 0
	AND
	C.IsSaved = @IsSaved
	ORDER BY
	C.CreatedOn DESC;
	
	EXEC Fdp_Changeset_Get @FdpChangesetId = @FdpChangesetId;