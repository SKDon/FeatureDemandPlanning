CREATE PROCEDURE [dbo].[Fdp_VolumeHeader_Get]
	@FdpVolumeHeaderId INT
AS
	SET NOCOUNT ON;

	SELECT 
		  FdpVolumeHeaderId
		, CreatedOn
		, CreatedBy
		, DocumentId
		, FdpTakeRateStatusId
		, TotalVolume
		, UpdatedBy
		, UpdatedOn
		, IsManuallyEntered
	FROM
	FDP_VolumeHeader
	WHERE 
	FdpVolumeHeaderId = @FdpVolumeHeaderId;
