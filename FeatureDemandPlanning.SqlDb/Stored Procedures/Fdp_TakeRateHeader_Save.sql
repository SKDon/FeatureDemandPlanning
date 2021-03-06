﻿CREATE PROCEDURE [dbo].[Fdp_TakeRateHeader_Save]
	  @FdpVolumeHeaderId	INT = NULL OUTPUT
	, @DocumentId			INT
	, @IsManuallyEntered	BIT = 1
	, @TotalVolume			INT = 0
	, @FdpTakeRateStatusId	INT = 1
	, @CDSID				NVARCHAR(16)
AS
	SET NOCOUNT ON;

	IF (@FdpVolumeHeaderId IS NULL)
	BEGIN
		INSERT INTO Fdp_VolumeHeader
		(
			  CreatedBy
			, DocumentId
			, FdpTakeRateStatusId
			, TotalVolume
			, IsManuallyEntered
		)
		VALUES
		(
			  @CDSID
			, @DocumentId
			, @FdpTakeRateStatusId
			, @TotalVolume
			, @IsManuallyEntered
		)
		
		SET @FdpVolumeHeaderId = SCOPE_IDENTITY();
		
		-- Add an initial version for the document
		
		INSERT INTO Fdp_TakeRateVersion
		(
			  FdpTakeRateHeaderId
			, MajorVersion
			, MinorVersion
			, Revision
		)
		VALUES
		(
			  @FdpVolumeHeaderId
			, 0
			, 0
			, 0
		)
	END
	ELSE
	BEGIN
	
		UPDATE Fdp_VolumeHeader SET
			  TotalVolume = @TotalVolume
			, FdpTakeRateStatusId = @FdpTakeRateStatusId
			, UpdatedOn = GETDATE()
			, UpdatedBy = @CDSID
		WHERE
		FdpVolumeHeaderId = @FdpVolumeHeaderId;
	
	END

	EXEC Fdp_VolumeHeader_Get @FdpVolumeHeaderId;