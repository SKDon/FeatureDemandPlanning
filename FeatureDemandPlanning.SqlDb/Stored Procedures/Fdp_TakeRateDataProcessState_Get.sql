CREATE PROCEDURE Fdp_TakeRateDataProcessState_Get
	  @FdpImportId AS INT = NULL
	  , @FdpVolumeHeaderId AS INT = NULL
AS
	SET NOCOUNT ON;

	SELECT TOP 1 FdpImportId, FdpVolumeHeaderId, [State]
	FROM
	Fdp_TakeRateDataProcessState
	WHERE
	(@FdpImportId IS NULL OR FdpImportId = @FdpImportId)
	AND
	(@FdpVolumeHeaderId IS NULL OR FdpVolumeHeaderId = @FdpVolumeHeaderId);