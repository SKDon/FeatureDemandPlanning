CREATE PROCEDURE [dbo].[Fdp_OxoVolumeDataNote_Save]
	  @FdpOxoVolumeDataId INT
	, @CDSID NVARCHAR(16)
	, @Note NVARCHAR(MAX)
	, @FdpOxoVolumeDataNoteId INT OUTPUT
AS
	
	SET NOCOUNT ON;

	INSERT INTO Fdp_OxoVolumeDataItemNote
	(
		  FdpOxoVolumeDataItemId
		, EnteredBy
		, Note
	)
	VALUES
	(
		  @FdpOxoVolumeDataId
		, @CDSID
		, LTRIM(RTRIM(@Note))
	);
	
	SET @FdpOxoVolumeDataNoteId = SCOPE_IDENTITY();
	
	