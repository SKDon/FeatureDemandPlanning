CREATE PROCEDURE [dbo].[Fdp_ImportError_Save]
	  @FdpImportErrorId INT
	, @IsExcluded		BIT = 0
	, @CDSId			NVARCHAR(16)
AS
	SET NOCOUNT ON;
	
	DECLARE @ProgrammeId			INT;
	DECLARE @Gateway				NVARCHAR(100);
	DECLARE @FdpImportErrorTypeId	INT;
	DECLARE @ErrorMessage			NVARCHAR(MAX);
	
	SELECT 
		  @ProgrammeId			= I.ProgrammeId
		, @Gateway				= I.Gateway
		, @FdpImportErrorTypeId = E.FdpImportErrorTypeId
		, @ErrorMessage			= E.ErrorMessage
	FROM
	Fdp_ImportError AS E
	JOIN Fdp_Import AS I ON E.FdpImportQueueId = E.FdpImportQueueId
	WHERE
	FdpImportErrorId = @FdpImportErrorId;
	
	UPDATE E SET 
		  IsExcluded = @IsExcluded
		, UpdatedOn = GETDATE()
		, UpdatedBy = @CDSId
	FROM Fdp_ImportError	AS E
	JOIN Fdp_Import			AS I ON E.FdpImportQueueId = E.FdpImportQueueId
	JOIN Fdp_ImportQueue	AS Q ON I.FdpImportQueueId = Q.FdpImportQueueId
								 AND Q.FdpImportStatusId = 4 -- Error
	WHERE
	E.FdpImportErrorId = @FdpImportErrorId
	OR
	(
		I.ProgrammeId = @ProgrammeId
		AND
		I.Gateway = @Gateway
		AND
		E.FdpImportErrorTypeId = @FdpImportErrorTypeId
		AND
		E.ErrorMessage = @ErrorMessage
	)	
	
	IF @IsExcluded = 1
	BEGIN
		DECLARE @FdpVolumeHeaderId AS INT;
		SELECT @FdpVolumeHeaderId = MAX(H.FdpVolumeHeaderId)
		FROM 
		Fdp_VolumeHeader		AS H
		JOIN Fdp_Import			AS I ON H.DocumentId = I.DocumentId
		JOIN Fdp_ImportError	AS E ON I.FdpImportQueueId = E.FdpImportQueueId
		WHERE
		E.FdpImportErrorId = @FdpImportErrorId
		
		-- Update the take rate file 
		UPDATE Fdp_VolumeHeader SET UpdatedOn = GETDATE(), UpdatedBy = @CDSId
		WHERE
		FdpVolumeHeaderId = @FdpVolumeHeaderId;
	END

	EXEC Fdp_ImportError_Get @FdpImportErrorId;