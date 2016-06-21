CREATE PROCEDURE [dbo].[Fdp_Publish_Save]
	  @FdpVolumeHeaderId	INT
	, @MarketId				INT
	, @Comment				NVARCHAR(MAX) = NULL
	, @IsPublished			BIT			= 1
	, @CDSId				NVARCHAR(16)
AS
	SET NOCOUNT ON;

	DECLARE @FdpPublishId AS INT;

	SELECT TOP 1 @FdpPublishId = FdpPublishId FROM Fdp_Publish WHERE FdpVolumeHeaderId = @FdpVolumeHeaderId AND MarketId = @MarketId

	IF @FdpPublishId IS NOT NULL
	BEGIN
		UPDATE Fdp_Publish SET IsPublished = 1, PublishBy = @CDSId, PublishOn = GETDATE()
		WHERE
		FdpPublishId = @FdpPublishId;
	END
	ELSE
	BEGIN
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
	END

	-- Update the volume for all markets based on the published data
	DECLARE @TotalVolume AS INT;
	SELECT @TotalVolume = SUM(S.Volume) 
	FROM Fdp_TakeRateSummary AS S
	JOIN Fdp_Publish AS P ON S.FdpVolumeHeaderId = P.FdpVolumeHeaderId
							AND S.MarketId = S.MarketId
							AND P.IsPublished = 1
	WHERE
	S.FdpVolumeHeaderId = @FdpVolumeHeaderId
	AND
	S.ModelId IS NULL

	UPDATE Fdp_VolumeHeader SET TotalVolume = @TotalVolume
	WHERE
	FdpVolumeHeaderId = @FdpVolumeHeaderId;
	
	-- Recalculate the ALL MARKETS view now we have published

	EXEC Fdp_TakeRateData_CalculateAllMarkets @FdpVolumeHeaderId, @CDSId;

	EXEC Fdp_Publish_Get @FdpPublishId;