CREATE PROCEDURE [dbo].[Fdp_MarketReview_GetManyByUsername]
	  @FdpVolumeHeaderId	INT				= NULL
	, @FilterMessage		NVARCHAR(50)	= NULL
	, @CDSId				NVARCHAR(16)	= NULL
	, @PageIndex			INT				= NULL
	, @PageSize				INT				= 10
	, @SortIndex			INT				= 0
	, @SortDirection		VARCHAR(5)		= 'DESC'
	, @TotalPages			INT OUTPUT
	, @TotalRecords			INT OUTPUT
	, @TotalDisplayRecords  INT OUTPUT
AS

	SET NOCOUNT ON;

	IF @PageIndex IS NULL 
		SET @PageIndex = 1;
	
	DECLARE @MinIndex AS INT;
	DECLARE @MaxIndex AS INT;
	DECLARE @PageRecords AS TABLE
	(
		  RowIndex	INT IDENTITY(1,1)
		, FdpMarketReviewId INT
	);
	INSERT INTO @PageRecords 
	(
		FdpMarketReviewId
	)
	SELECT
		M.FdpMarketReviewId
	FROM
	Fdp_VolumeHeader_VW								AS H
	JOIN Fdp_MarketReview							AS M	ON H.FdpVolumeHeaderId	= M.FdpVolumeHeaderId
	JOIN OXO_Market_Group_Market_VW					AS MK	ON M.MarketId			= MK.Market_Id
	JOIN OXO_Programme_VW							AS P	ON H.ProgrammeId		= P.Id
	JOIN OXO_Doc									AS D	ON H.DocumentId			= D.Id

	-- Restrict by the available markets and programmes for the current user

	JOIN dbo.fn_Fdp_UserMarkets_GetMany2(@CDSId)	AS MK1	ON M.MarketId			= MK1.MarketId
	JOIN dbo.fn_Fdp_UserProgrammes_GetMany2(@CDSId) AS P1	ON H.ProgrammeId		= P1.ProgrammeId
	WHERE
	(@FdpVolumeHeaderId IS NULL OR H.FdpVolumeHeaderId = @FdpVolumeHeaderId)
	AND
	(ISNULL(@FilterMessage, '') = '' 
		OR P.VehicleName LIKE '%' + @FilterMessage + '%'
		OR P.VehicleAKA LIKE '%' + @FilterMessage + '%'
		OR P.ModelYear LIKE '%' + @FilterMessage + '%'
		OR H.Gateway LIKE '%' + @FilterMessage + '%'
		OR MK.Market_Name LIKE '%' + @FilterMessage + '%')
	AND
	M.IsActive = 1
	ORDER BY	
		CASE @SortDirection
		WHEN 'ASC' THEN
			CASE ISNULL(@SortIndex, 0)
				WHEN 3 THEN H.CreatedBy
				WHEN 4 THEN P.VehicleName + ' ' + P.ModelYear
				WHEN 5 THEN H.Gateway
				WHEN 6 THEN CAST(D.Version_Id AS NVARCHAR(10))
				WHEN 7 THEN D.[Status]
				WHEN 8 THEN MK.Market_Name
				WHEN 9 THEN CAST(M.FdpMarketReviewStatusId AS NVARCHAR(10))
			END
		END ASC,
		CASE @SortDirection
		WHEN 'DESC' THEN
			CASE ISNULL(@SortIndex, 0)
				WHEN 3 THEN H.CreatedBy
				WHEN 4 THEN P.VehicleName + ' ' + P.ModelYear
				WHEN 5 THEN H.Gateway
				WHEN 6 THEN CAST(D.Version_Id AS NVARCHAR(10))
				WHEN 7 THEN D.[Status]
				WHEN 8 THEN MK.Market_Name
				WHEN 9 THEN CAST(M.FdpMarketReviewStatusId AS NVARCHAR(10))
			END	
		END DESC
	
	SELECT @TotalRecords = COUNT(1) FROM @PageRecords;

	IF ISNULL(@PageSize, 0) = 0
		SET @PageSize = @TotalRecords;
	
	SET @TotalPages = CEILING(@TotalRecords / CAST(@PageSize AS DECIMAL));
	SET @MinIndex = ((@PageIndex - 1) * @PageSize) + 1;
	SET @MaxIndex = @MinIndex + (@PageSize - 1);
	
	SELECT @TotalDisplayRecords = COUNT(1) FROM @PageRecords WHERE RowIndex BETWEEN @MinIndex AND @MaxIndex;

	SELECT
	  M.FdpVolumeHeaderId
	, M.FdpMarketReviewId
	, M.CreatedBy
	, M.CreatedOn
	, M.DocumentId
	, M.ProgrammeId
	, M.VehicleName
	, M.VehicleAKA
	, M.ModelYear
	, M.MarketId
	, M.MarketName
	, M.FdpMarketReviewStatusId
	, M.[Status]
	FROM
	@PageRecords						AS PA
	JOIN Fdp_MarketReview_VW			AS M	ON PA.FdpMarketReviewId = M.FdpMarketReviewId
												AND PA.RowIndex BETWEEN @MinIndex AND @MaxIndex