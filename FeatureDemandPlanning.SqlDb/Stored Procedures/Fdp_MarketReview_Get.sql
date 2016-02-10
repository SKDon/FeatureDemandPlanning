CREATE PROCEDURE [dbo].[Fdp_MarketReview_Get]
	  @FdpMarketReviewId INT
AS
	SET NOCOUNT ON;
	
	SELECT
		  M.FdpMarketReviewId
		, M.CreatedOn
		, M.CreatedBy
		, M.FdpVolumeHeaderId
		, M.ProgrammeId
		, M.VehicleName
		, M.VehicleAKA
		, M.ModelYear
		, M.DocumentId
		, M.FdpMarketReviewStatusId
		, M.[Status]
	FROM
	Fdp_MarketReview_VW AS M
	WHERE 
	M.FdpMarketReviewId = @FdpMarketReviewId;