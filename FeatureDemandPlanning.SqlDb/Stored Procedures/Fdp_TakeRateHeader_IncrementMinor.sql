CREATE PROCEDURE [dbo].[Fdp_TakeRateHeader_IncrementMinor]
	@FdpVolumeHeaderId INT
AS
	SET NOCOUNT ON;

	INSERT INTO Fdp_TakeRateVersion
	(
		  FdpTakeRateHeaderId
		, MajorVersion
		, MinorVersion
		, Revision
	)
	SELECT
		    FdpVolumeHeaderId
		  , V.MajorVersion
		  , V.MinorVersion + 1
		  , 0
	FROM
	Fdp_Version_VW AS V
	WHERE
	V.FdpVolumeHeaderId = @FdpVolumeHeaderId;