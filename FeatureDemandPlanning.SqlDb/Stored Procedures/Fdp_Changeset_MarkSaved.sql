CREATE PROCEDURE [dbo].[Fdp_Changeset_MarkSaved]
	  @FdpChangesetId	AS INT
AS
	SET NOCOUNT ON;

	-- Update the changeset to indicate its saved status and prevent any changes from being returned to the user

	UPDATE Fdp_Changeset SET IsSaved = 1
	WHERE
	FdpChangesetId = @FdpChangesetId;
	
	-- Update the underlying take rate document revision number
	
	DECLARE @FdpVolumeHeaderId INT;
	SELECT TOP 1 @FdpVolumeHeaderId = FdpVolumeHeaderId FROM Fdp_Changeset WHERE FdpChangesetId = @FdpChangesetId;
	
	EXEC Fdp_TakeRateHeader_IncrementRevision @FdpVolumeHeaderId = @FdpVolumeHeaderId;