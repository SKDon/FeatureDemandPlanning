CREATE PROCEDURE Fdp_Changeset_GetHistory 
	@FdpVolumeHeaderId AS INT
AS
BEGIN
	SET NOCOUNT ON;

    SELECT 
		  C.UpdatedOn
		, C.UpdatedBy
		, C.Comment
	FROM
	Fdp_Changeset AS C
	WHERE
	C.FdpVolumeHeaderId = @FdpVolumeHeaderId
	AND
	C.IsSaved = 1
	AND
	C.IsDeleted = 0
	ORDER BY
	C.UpdatedOn DESC
END