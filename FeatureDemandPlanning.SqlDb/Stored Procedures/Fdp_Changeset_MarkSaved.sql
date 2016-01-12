CREATE PROCEDURE [dbo].[Fdp_Changeset_MarkSaved]
	  @FdpChangesetId	AS INT
AS
	SET NOCOUNT ON;

	-- Update the changeset to indicate its saved status and prevent any changes from being returned to the user

	UPDATE Fdp_Changeset SET 
		  IsSaved = 1
		, UpdatedOn = GETDATE()
		, UpdatedBy = CreatedBy
	WHERE
	FdpChangesetId = @FdpChangesetId;

	-- Update the UpdatedOn and UpdatedBy for the take rate file

	UPDATE H SET UpdatedOn = GETDATE(), UpdatedBy = C.CreatedBy
	FROM
	Fdp_Changeset AS C
	JOIN Fdp_VolumeHeader AS H ON C.FdpVolumeHeaderId = H.FdpVolumeHeaderId
	WHERE
	C.FdpChangesetId = @FdpChangesetId;
	
	-- Update the underlying take rate document revision number
	
	DECLARE @FdpVolumeHeaderId INT;
	SELECT TOP 1 @FdpVolumeHeaderId = FdpVolumeHeaderId FROM Fdp_Changeset WHERE FdpChangesetId = @FdpChangesetId;
	
	EXEC Fdp_TakeRateHeader_IncrementRevision @FdpVolumeHeaderId = @FdpVolumeHeaderId;