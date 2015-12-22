CREATE PROCEDURE dbo.Fdp_TakeRateHeader_IncrementRevision
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
		  , V.MinorVersion
		  , V.Revision + 1
	FROM
	Fdp_Version_VW AS V
	WHERE
	V.FdpVolumeHeaderId = @FdpVolumeHeaderId;