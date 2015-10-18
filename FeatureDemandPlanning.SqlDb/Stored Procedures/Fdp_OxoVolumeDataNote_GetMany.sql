CREATE PROCEDURE [dbo].[Fdp_OxoVolumeDataNote_GetMany]
	@FdpOxoVolumeDataId INT
AS
	
	SET NOCOUNT ON;

	SELECT
		  N.FdpOxoVolumeDataNoteId
		, N.EnteredOn
		, N.EnteredBy
		, N.Note
	FROM
	Fdp_OxoVolumeDataNote AS N
	WHERE
	N.FdpOxoVolumeDataId = @FdpOxoVolumeDataId
	ORDER BY
	N.EnteredOn DESC;