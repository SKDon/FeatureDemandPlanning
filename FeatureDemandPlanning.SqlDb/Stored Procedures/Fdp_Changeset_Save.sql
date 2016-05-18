CREATE PROCEDURE [dbo].[Fdp_Changeset_Save]
	  @FdpVolumeHeaderId	AS INT
	, @MarketId				AS INT
	, @CDSID				AS NVARCHAR(16)
	, @IsSaved				AS BIT = 0
AS
	SET NOCOUNT ON;
	
	DECLARE @FdpChangesetId INT;
	
	SELECT TOP 1 
		@FdpChangesetId = C.FdpChangesetId
	FROM Fdp_Changeset AS C
	WHERE
	C.FdpVolumeHeaderId = @FdpVolumeHeaderId
	--AND
	--C.CreatedBy = @CDSID -- Changsets are now global and not per user. The data items themselves record who made the change
	AND
	C.IsDeleted = 0
	AND
	C.IsSaved = 0
	AND
	C.MarketId = @MarketId;
	
	IF @FdpChangesetId IS NULL
	BEGIN
		INSERT INTO Fdp_Changeset
		(
			  CreatedBy
			, MarketId
			, FdpVolumeHeaderId
		)
		SELECT
			  @CDSID 
			, @MarketId
			, @FdpVolumeHeaderId
		
		SET @FdpChangesetId = SCOPE_IDENTITY();
	END
	
	EXEC Fdp_Changeset_Get @FdpChangesetId = @FdpChangesetId;