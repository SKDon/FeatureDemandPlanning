CREATE PROCEDURE [dbo].[Fdp_MarketReview_Get]
	    @FdpMarketReviewId	INT = NULL
	  , @FdpVolumeHeaderId	INT = NULL
	  , @MarketId			INT = NULL
	  , @CDSId				NVARCHAR(16)
AS
	SET NOCOUNT ON;
	
	IF @FdpMarketReviewId IS NULL
	BEGIN
		SELECT TOP 1 @FdpMarketReviewId = FdpMarketReviewId
		FROM Fdp_MarketReview_VW
		WHERE
		FdpVolumeHeaderId = @FdpVolumeHeaderId
		AND
		MarketId = @MarketId
		ORDER BY
		ISNULL(UpdatedOn, CreatedOn) DESC
	END
	
	SELECT TOP 1
		  MK.FdpMarketReviewId
		, MK.CreatedOn
		, MK.CreatedBy
		, MK.FdpVolumeHeaderId
		, MK.ProgrammeId
		, MK.VehicleName
		, MK.VehicleAKA
		, MK.ModelYear
		, MK.DocumentId
		, MK.FdpMarketReviewStatusId
		, MK.[Status]
		, MK.UpdatedOn
		, MK.UpdatedBy
		, MK.Comment
	FROM
	Fdp_MarketReview_VW AS MK
	JOIN dbo.fn_Fdp_UserMarkets_GetMany2(@CDSId) AS M ON MK.MarketId = M.MarketId
	JOIN dbo.fn_Fdp_UserProgrammes_GetMany2(@CDSId) AS P ON MK.ProgrammeId = P.ProgrammeId
	WHERE 
	MK.FdpMarketReviewId = @FdpMarketReviewId
	ORDER BY
	MK.FdpMarketReviewId DESC;