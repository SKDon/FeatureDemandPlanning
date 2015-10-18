CREATE PROCEDURE [dbo].[Fdp_VolumeHeader_Save]
	  @FdpVolumeHeaderId	INT = NULL OUTPUT
	, @ProgrammeId			INT
	, @Gateway				NVARCHAR(100)
	, @FdpImportId			INT = NULL
	, @IsManuallyEntered	BIT = 1
	, @CDSID				NVARCHAR(16)
AS
	SET NOCOUNT ON;

	IF (@FdpVolumeHeaderId IS NULL)
	BEGIN
		INSERT INTO Fdp_VolumeHeader
		(
			  CreatedBy
			, ProgrammeId
			, Gateway
			, FdpImportId
			, IsManuallyEntered
		)
		VALUES
		(
			  @CDSID
			, @ProgrammeId
			, @Gateway
			, @FdpImportId
			, @IsManuallyEntered
		)
		
		SET @FdpVolumeHeaderId = SCOPE_IDENTITY();
	END
	ELSE
	BEGIN
	
		UPDATE Fdp_VolumeHeader SET
			  ProgrammeId		= @ProgrammeId
			, Gateway			= @Gateway
			, FdpImportId		= @FdpImportId
			, IsManuallyEntered = @IsManuallyEntered
		WHERE
		FdpVolumeHeaderId = @FdpVolumeHeaderId;
	
	END

	SELECT 
		  FdpVolumeHeaderId
		, CreatedOn
		, CreatedBy
		, ProgrammeId
		, Gateway
		, FdpImportId
		, IsManuallyEntered
	FROM
	FDP_VolumeHeader
	WHERE 
	FdpVolumeHeaderId = @FdpVolumeHeaderId;
