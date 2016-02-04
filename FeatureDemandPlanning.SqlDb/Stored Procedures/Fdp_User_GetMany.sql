CREATE PROCEDURE [dbo].[Fdp_User_GetMany]
	  @CDSId				NVARCHAR(16)= NULL
	, @FilterMessage		NVARCHAR(50) = NULL
	, @HideInactiveUsers	BIT			= 1
	, @PageIndex			INT			= NULL
	, @PageSize				INT			= 10
	, @SortIndex			INT			= 1
	, @SortDirection		VARCHAR(5)	= 'ASC'
	, @TotalPages			INT OUTPUT
	, @TotalRecords			INT OUTPUT
	, @TotalDisplayRecords	INT OUTPUT
AS
	SET NOCOUNT ON;
	
	IF @PageIndex IS NULL 
		SET @PageIndex = 1;
	
	DECLARE @MinIndex AS INT;
	DECLARE @MaxIndex AS INT;
	DECLARE @PageRecords AS TABLE
	(
		  RowIndex INT IDENTITY(1, 1)
		, FdpUserId INT
	);
	
	
	INSERT INTO @PageRecords (FdpUserId)
	SELECT U.FdpUserId
	FROM
	Fdp_User_VW AS U
	WHERE
	(@CDSId IS NULL OR U.CDSId = @CDSId)
	AND
	(ISNULL(@FilterMessage, '') = '' OR 
		U.CDSId LIKE '%' + @FilterMessage + '%' OR
		U.FullName LIKE '%' + @FilterMessage + '%' OR
		U.Programmes LIKE '%' + @FilterMessage + '%')
	AND
	(
		@HideInactiveUsers = 0
		OR
		(@HideInactiveUsers = 1 AND U.IsActive = 1)
	)
	ORDER BY
		CASE @SortDirection
			WHEN 'ASC' THEN
				CASE ISNULL(@SortIndex, 0)
					WHEN 1 THEN U.CDSId
					WHEN 2 THEN FullName
					WHEN 3 THEN CAST(IsActive AS NVARCHAR(1))
					WHEN 4 THEN CAST(IsAdmin AS NVARCHAR(1))
					ELSE U.CDSId
				END
		END ASC,
		CASE @SortDirection
			WHEN 'DESC' THEN
				CASE ISNULL(@SortIndex, 0)
					WHEN 1 THEN U.CDSId
					WHEN 2 THEN FullName
					WHEN 3 THEN CAST(IsActive AS NVARCHAR(1))
					WHEN 4 THEN CAST(IsAdmin AS NVARCHAR(1))
					ELSE U.CDSId
				END	
		END DESC
		
	SELECT @TotalRecords = COUNT(1) FROM @PageRecords;
	SELECT @TotalDisplayRecords = @TotalRecords;
	
	IF ISNULL(@PageSize, 0) = 0
		SET @PageSize = @TotalRecords;
	
	SET @TotalPages = CEILING(@TotalRecords / CAST(@PageSize AS DECIMAL));
	SET @MinIndex = ((@PageIndex - 1) * @PageSize) + 1;
	SET @MaxIndex = @MinIndex + (@PageSize - 1);
	
	SELECT 
		  U.FdpUserId
		, U.CDSId
		, U.FullName
		, U.IsActive
		, U.IsAdmin
		, U.Programmes
		, U.Markets
		, U.Roles
		, U.CreatedOn
		, U.CreatedBy
		, U.UpdatedOn
		, U.UpdatedBy
		
	FROM @PageRecords		AS P
	JOIN Fdp_User_VW			AS U	ON	P.FdpUserId = U.FdpUserId
									AND P.RowIndex BETWEEN @MinIndex AND @MaxIndex