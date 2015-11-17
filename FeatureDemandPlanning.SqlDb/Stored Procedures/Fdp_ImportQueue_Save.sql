CREATE PROCEDURE [dbo].[Fdp_ImportQueue_Save]
	  @CDSId				NVARCHAR(16)
	, @OriginalFileName		NVARCHAR(100)
	, @FilePath				NVARCHAR(MAX)
	, @FdpImportTypeId		INT
	, @FdpImportStatusId	INT
	, @ProgrammeId			INT
	, @Gateway				NVARCHAR(10)
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
	
	INSERT INTO Fdp_Import
	(
		  FdpImportQueueId
		, ProgrammeId
		, Gateway
	)
	VALUES
	(
		  @FdpImportQueueId
		, @ProgrammeId
		, @Gateway
	);
	
	EXEC Fdp_ImportQueue_Get @FdpImportQueueId;