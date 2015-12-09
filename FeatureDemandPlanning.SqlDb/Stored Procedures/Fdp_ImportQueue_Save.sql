CREATE PROCEDURE [dbo].[Fdp_ImportQueue_Save]
	  @CDSId				NVARCHAR(16)
	, @OriginalFileName		NVARCHAR(100)
	, @FilePath				NVARCHAR(MAX)
	, @FdpImportTypeId		INT
	, @FdpImportStatusId	INT
	, @ProgrammeId			INT
	, @Gateway				NVARCHAR(10)
	, @DocumentId			INT = NULL
AS
	SET NOCOUNT ON;
		
	DECLARE @FdpImportQueueId INT;
	
	INSERT INTO Fdp_ImportQueue
	(
		  CreatedBy
		, OriginalFileName
		, FilePath
		, FdpImportTypeId
		, FdpImportStatusId
	)
	VALUES
	(
		  @CDSId
		, @OriginalFileName
		, @FilePath
		, @FdpImportTypeId
		, @FdpImportStatusId
	);
	
	SET @FdpImportQueueId = SCOPE_IDENTITY();
	
	IF @DocumentId IS NULL
	BEGIN
		SELECT TOP 1 @DocumentId = Id
		FROM OXO_Doc
		WHERE
		Programme_Id = @ProgrammeId
		AND
		Gateway = @Gateway
		AND
		[Status] = 'PUBLISHED'
		ORDER BY
		Version_Id DESC;
	END
	
	INSERT INTO Fdp_Import
	(
		  FdpImportQueueId
		, ProgrammeId
		, Gateway
		, DocumentId
	)
	VALUES
	(
		  @FdpImportQueueId
		, @ProgrammeId
		, @Gateway
		, @DocumentId
	);
	
	EXEC Fdp_ImportQueue_Get @FdpImportQueueId;