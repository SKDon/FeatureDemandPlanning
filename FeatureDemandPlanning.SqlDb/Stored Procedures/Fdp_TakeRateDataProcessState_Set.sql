CREATE PROCEDURE [dbo].[Fdp_TakeRateDataProcessState_Set]
	  @FdpImportId			AS INT = NULL
	, @FdpVolumeHeaderId	AS INT = NULL
	, @State				AS NVARCHAR(MAX)
AS
	SET NOCOUNT ON;

	DELETE FROM Fdp_TakeRateDataProcessState WHERE FdpVolumeHeaderId = @FdpVolumeHeaderId;
	DELETE FROM Fdp_TakeRateDataProcessState WHERE FdpImportId = @FdpImportId;

	INSERT INTO Fdp_TakeRateDataProcessState
	(
		  FdpImportId
		, FdpVolumeHeaderId
		, [State]
	)
	VALUES
	(
		  @FdpImportId
		, @FdpVolumeHeaderId
		, @State
	);