CREATE PROCEDURE [dbo].[Fdp_MarketReview_Save]
	  @FdpVolumeHeaderId		INT
	, @MarketId					INT
	, @FdpMarketReviewStatusId	INT
	, @CDSId					NVARCHAR(16)
	, @Comment					NVARCHAR(MAX)
AS
	SET NOCOUNT ON;
	
	DECLARE @FdpMarketReviewId INT;
	
	SELECT 
		TOP 1 @FdpMarketReviewId = FdpMarketReviewId
	FROM
	Fdp_MarketReview_VW AS R
	WHERE
	R.FdpVolumeHeaderId = @FdpVolumeHeaderId
	AND
	R.MarketId = @MarketId
	--AND
	--R.FdpMarketReviewStatusId = @FdpMarketReviewStatusId
	ORDER BY
	R.FdpMarketReviewId DESC -- Ensure the most recent review is used
	
	IF @FdpMarketReviewId IS NULL
	BEGIN
		INSERT INTO Fdp_MarketReview
		(
			  CreatedBy
			, FdpVolumeHeaderId
			, MarketId
			, FdpMarketReviewStatusId
			, Comment
		)
		VALUES
		(
			  @CDSId
			, @FdpVolumeHeaderId
			, @MarketId
			, @FdpMarketReviewStatusId
			, @Comment
		)
		
		SET @FdpMarketReviewId = SCOPE_IDENTITY();
	END
	ELSE
	BEGIN
		UPDATE Fdp_MarketReview SET 
			  FdpMarketReviewStatusId = @FdpMarketReviewStatusId
			, UpdatedOn = GETDATE()
			, UpdatedBy = @CDSId
			, Comment = @Comment
		WHERE
		FdpMarketReviewId = @FdpMarketReviewId;
	END
	
	EXEC Fdp_MarketReview_Get @FdpMarketReviewId = @FdpMarketReviewId, @CDSId = @CDSId