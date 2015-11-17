CREATE PROCEDURE [dbo].[Fdp_OxoVolumeDataNote_GetMany]
	@FdpOxoVolumeDataId INT
AS
	
	SET NOCOUNT ON;

	SELECT
		  N.FdpOxoVolumeDataItemNoteId
		, N.FdpOxoVolumeDataItemId
		, N.EnteredOn
		, N.EnteredBy
		, N.Note
	FROM
	Fdp_OxoVolumeDataItemNote AS N
	WHERE
	N.FdpOxoVolumeDataItemId = @FdpOxoVolumeDataId
	ORDER BY
	N.EnteredOn DESC;