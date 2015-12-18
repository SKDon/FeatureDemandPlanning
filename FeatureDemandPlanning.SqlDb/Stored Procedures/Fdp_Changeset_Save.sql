CREATE PROCEDURE [dbo].[Fdp_Changeset_Save]
	  @DocumentId	AS INT
	, @CDSID		AS NVARCHAR(16)
	, @IsSaved		AS BIT = 0
AS
	SET NOCOUNT ON;
	
	DECLARE @FdpChangesetId INT;
	
	SELECT TOP 1 
		@FdpChangesetId = C.FdpChangesetId
	FROM Fdp_VolumeHeader AS H 
	JOIN Fdp_Changeset AS C ON H.FdpVolumeHeaderId = C.FdpVolumeHeaderId
	WHERE
	H.DocumentId = @DocumentId
	AND
	C.CreatedBy = @CDSID
	AND
	C.IsDeleted = 0
	AND
	C.IsSaved = 0;
	
	IF @FdpChangesetId IS NULL
	BEGIN
		INSERT INTO Fdp_Changeset
		(
			  CreatedBy
			, FdpVolumeHeaderId
		)
		SELECT
			  @CDSID 
			, FdpVolumeHeaderId
		FROM 
		Fdp_VolumeHeader AS H
		WHERE
		H.DocumentId = @DocumentId;
		
		SET @FdpChangesetId = SCOPE_IDENTITY();
	END
	
	EXEC Fdp_Changeset_Get @FdpChangesetId = @FdpChangesetId;