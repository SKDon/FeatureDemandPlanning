CREATE PROCEDURE [dbo].[Fdp_VolumeDataItemNote_Save]
	  @FdpVolumeDataItemId INT
	, @CDSID NVARCHAR(16)
	, @Note NVARCHAR(MAX)
	, @FdpVolumeDataItemNoteId INT OUTPUT
AS
	
	SET NOCOUNT ON;

	INSERT INTO Fdp_VolumeDataItemNote
	(
		  FdpVolumeDataItemId
		, EnteredBy
		, Note
	)
	VALUES
	(
		  @FdpVolumeDataItemId
		, @CDSID
		, LTRIM(RTRIM(@Note))
	);
	
	SET @FdpVolumeDataItemNoteId = SCOPE_IDENTITY();