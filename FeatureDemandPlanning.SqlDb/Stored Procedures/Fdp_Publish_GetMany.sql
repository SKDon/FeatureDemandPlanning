CREATE PROCEDURE [dbo].[Fdp_Publish_GetMany]
	  @FdpVolumeHeaderId	INT				= NULL
	, @MarketId				INT				= NULL
	, @FilterMessage		NVARCHAR(50)	= NULL
	, @CDSId				NVARCHAR(16)
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
		, FdpPublishId INT
	);
	INSERT INTO @PageRecords 
	(
		FdpPublishId
	)
	SELECT
		P.FdpPublishId
	FROM
	Fdp_VolumeHeader_VW								AS H
	JOIN Fdp_Publish								AS P	ON H.FdpVolumeHeaderId	= P.FdpVolumeHeaderId
	JOIN OXO_Market_Group_Market_VW					AS MK	ON P.MarketId			= MK.Market_Id
	JOIN OXO_Programme_VW							AS P1	ON H.ProgrammeId		= P1.Id
	JOIN OXO_Doc									AS D	ON H.DocumentId			= D.Id

	-- Restrict by the available markets and programmes for the current user

	JOIN dbo.fn_Fdp_UserMarkets_GetMany2(@CDSId)	AS MK1	ON P.MarketId			= MK1.MarketId
	JOIN dbo.fn_Fdp_UserProgrammes_GetMany2(@CDSId) AS P2	ON H.ProgrammeId		= P2.ProgrammeId
	WHERE
	(@FdpVolumeHeaderId IS NULL OR H.FdpVolumeHeaderId = @FdpVolumeHeaderId)
	AND
	(ISNULL(@FilterMessage, '') = '' 
		OR P1.VehicleName LIKE '%' + @FilterMessage + '%'
		OR P1.VehicleAKA LIKE '%' + @FilterMessage + '%'
		OR P1.ModelYear LIKE '%' + @FilterMessage + '%'
		OR H.Gateway LIKE '%' + @FilterMessage + '%'
		OR MK.Market_Name LIKE '%' + @FilterMessage + '%')
	AND
	P.IsPublished = 1

	ORDER BY	
		CASE @SortDirection
		WHEN 'ASC' THEN
			CASE ISNULL(@SortIndex, 0)
				WHEN 3 THEN H.CreatedBy
				WHEN 4 THEN P1.VehicleName + ' ' + P1.ModelYear
				WHEN 5 THEN H.Gateway
				WHEN 6 THEN CAST(D.Version_Id AS NVARCHAR(10))
				WHEN 7 THEN D.[Status]
				WHEN 8 THEN MK.Market_Name
			END
		END ASC,
		CASE @SortDirection
		WHEN 'DESC' THEN
			CASE ISNULL(@SortIndex, 0)
				WHEN 3 THEN H.CreatedBy
				WHEN 4 THEN P1.VehicleName + ' ' + P1.ModelYear
				WHEN 5 THEN H.Gateway
				WHEN 6 THEN CAST(D.Version_Id AS NVARCHAR(10))
				WHEN 7 THEN D.[Status]
				WHEN 8 THEN MK.Market_Name
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
		  P.FdpPublishId
		, P.PublishOn
		, P.PublishBy
		, P.FdpVolumeHeaderId
		, P.MarketId
		, MK.Market_Name AS MarketName
		, V.ProgrammeId
		, V.VehicleMake
		, V.VehicleName
		, V.VehicleAKA
		, V.ModelYear
		, V.Gateway
		, V.DocumentVersion
		, V.VersionString
		, V.[Status]
		, P.IsPublished
		, ISNULL(P.Comment, '') AS Comment
	FROM
	@PageRecords							AS PA
	JOIN Fdp_Publish						AS P	ON	PA.FdpPublishId		= P.FdpPublishId
	JOIN Fdp_VolumeHeader_VW				AS H	ON	P.FdpVolumeHeaderId = H.FdpVolumeHeaderId
	JOIN Fdp_Version_VW						AS V	ON	H.FdpVolumeHeaderId	= V.FdpVolumeHeaderId
	JOIN OXO_Programme_MarketGroupMarket_VW AS MK	ON	H.ProgrammeId		= MK.Programme_Id
													AND P.MarketId			= MK.Market_Id