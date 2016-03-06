CREATE FUNCTION [dbo].[fn_Fdp_Changeset_GetLatestByUser]
(
	  @FdpVolumeHeaderId	INT
	, @MarketId				INT
	, @CDSId				NVARCHAR(16)
)
RETURNS INT
AS
BEGIN
	DECLARE @FdpChangesetId AS INT;

	-- If the market is under review, we get the latest changeset, regardless of user
	-- that has not been saved and created by a market reviewer role user since the file was placed in market review

	DECLARE @MarketReviewOn DATETIME
	SELECT @MarketReviewOn = CreatedOn FROM Fdp_MarketReview_VW
	WHERE
	FdpVolumeHeaderId = @FdpVolumeHeaderId
	AND
	MarketId = @MarketId
	AND
	FdpMarketReviewStatusId <> 4 -- If the review has been approved, we are no longer in market review
								 -- and any changes will have been merged into the data and saved

	IF @MarketReviewOn IS NULL
	BEGIN
	
		SELECT TOP 1 @FdpChangesetId = C.FdpChangesetId
		FROM
		Fdp_VolumeHeader_VW	AS H
		JOIN Fdp_Changeset	AS C	ON H.FdpVolumeHeaderId = C.FdpVolumeHeaderId
		WHERE
		H.FdpVolumeHeaderId = @FdpVolumeHeaderId
		AND
		C.CreatedBy = @CDSID
		AND
		C.IsDeleted = 0
		AND
		C.IsSaved = 0
		AND
		C.MarketId = @MarketId
		ORDER BY
		C.CreatedOn DESC;

	END
	ELSE
	BEGIN

		SELECT TOP 1 @FdpChangesetId = C.FdpChangesetId
		FROM
		Fdp_VolumeHeader_VW	AS H
		JOIN Fdp_Changeset	AS C	ON H.FdpVolumeHeaderId	= C.FdpVolumeHeaderId
		JOIN Fdp_User		AS U	ON C.CreatedBy			= U.CDSId
		JOIN Fdp_UserRoleMapping AS R ON U.FdpUserId		= R.FdpUserId
										AND R.IsActive		= 1
										AND R.FdpUserRoleId	IN (4, 9) -- Market Reviewer or Approver
		WHERE
		H.FdpVolumeHeaderId = @FdpVolumeHeaderId
		AND
		C.CreatedOn >= @MarketReviewOn
		AND
		C.IsDeleted = 0
		AND
		C.IsSaved = 0
		AND
		C.MarketId = @MarketId
		ORDER BY
		C.CreatedOn;
	END
	
	RETURN @FdpChangesetId;

END