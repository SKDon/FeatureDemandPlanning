CREATE PROCEDURE [dbo].[Fdp_MarketReview_Save]
	  @FdpVolumeHeaderId		INT
	, @MarketId					INT
	, @FdpMarketReviewStatusId	INT
	, @CDSId					NVARCHAR(16)
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
		)
		VALUES
		(
			  @CDSId
			, @FdpVolumeHeaderId
			, @MarketId
			, @FdpMarketReviewStatusId
		)
		
		SET @FdpMarketReviewId = SCOPE_IDENTITY();
	END
	ELSE
	BEGIN
		UPDATE Fdp_MarketReview SET FdpMarketReviewStatusId = @FdpMarketReviewStatusId
		WHERE
		FdpMarketReviewId = @FdpMarketReviewId;
	END
	
	EXEC Fdp_MarketReview_Get @FdpMarketReviewId = @FdpMarketReviewId;