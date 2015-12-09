CREATE PROCEDURE [dbo].[Fdp_VolumeDataItemNote_GetMany]
	@FdpVolumeDataItemId INT
AS
	
	SET NOCOUNT ON;

	SELECT
		  N.FdpVolumeDataItemNoteId
		, N.EnteredOn
		, N.EnteredBy
		, N.Note
	FROM
	Fdp_VolumeDataItemNote AS N
	WHERE
	N.FdpVolumeDataItemId = @FdpVolumeDataItemId
	ORDER BY
	N.EnteredOn DESC;