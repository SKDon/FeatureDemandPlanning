CREATE PROCEDURE [dbo].[Fdp_Publish_Save]
	  @FdpVolumeHeaderId	INT
	, @MarketId				INT
	, @Comment				NVARCHAR(MAX) = NULL
	, @IsPublished			BIT			= 1
	, @CDSId				NVARCHAR(16)
AS
	SET NOCOUNT ON;

	DECLARE @FdpPublishId AS INT;

	INSERT INTO Fdp_Publish
	(
		  FdpVolumeHeaderId
		, MarketId
		, Comment
		, IsPublished
		, PublishBy
	)
	VALUES
	(
		  @FdpVolumeHeaderId
		, @MarketId
		, @Comment
		, @IsPublished
		, @CDSId
	)

	SET @FdpPublishId = SCOPE_IDENTITY();

	EXEC Fdp_Publish_Get @FdpPublishId;