CREATE PROCEDURE [dbo].[ImportQueue_GetMany]
	  @ImportQueueId	INT			= NULL
	, @ImportTypeId		INT			= NULL
	, @ImportStatusId	INT			= NULL
	, @PageIndex		INT			= NULL
	, @PageSize			INT			= NULL
	, @SortIndex		INT			= 0
	, @SortDirection	VARCHAR(5)	= 'DESC'
	, @TotalPages		INT OUTPUT
	, @TotalRecords		INT OUTPUT
AS
	SET NOCOUNT ON;
	
	IF @PageIndex IS NULL 
		SET @PageIndex = 1;
	
	DECLARE @MinIndex AS INT;
	DECLARE @MaxIndex AS INT;
	DECLARE @PageRecords AS TABLE
	(
		  RowIndex INT
		, ImportQueueId INT
	);
	INSERT INTO @PageRecords 
	(
		  RowIndex
		, ImportQueueId
	)
	SELECT
		  RANK() OVER (ORDER BY ImportQueueId DESC) AS RowIndex
		, Q.ImportQueueId
		
	FROM ImportQueue_VW AS Q
	WHERE
	(@ImportQueueId IS NULL OR Q.ImportQueueId = @ImportQueueId)
	AND
	(@ImportTypeId IS NULL OR Q.ImportTypeId = @ImportTypeId)
	AND
	(@ImportStatusId IS NULL OR Q.ImportStatusId = @ImportStatusId)
	ORDER BY
		CASE @SortDirection
			WHEN 'ASC' THEN
				CASE ISNULL(@SortIndex, 0)
					WHEN 0 THEN CreatedOn
					WHEN 1 THEN CreatedBy
					WHEN 2 THEN FilePath
					WHEN 3 THEN [Status]
				END
		END ASC,
		CASE @SortDirection
			WHEN 'DESC' THEN
				CASE ISNULL(@SortIndex, 0)
					WHEN 0 THEN CreatedOn
					WHEN 1 THEN CreatedBy
					WHEN 2 THEN FilePath
					WHEN 3 THEN [Status]
				END	
		END DESC
	
	SELECT @TotalRecords = COUNT(1) FROM @PageRecords;
	
	IF ISNULL(@PageSize, 0) = 0
		SET @PageSize = @TotalRecords;
	
	SET @TotalPages = CEILING(@TotalRecords / CAST(@PageSize AS DECIMAL));
	SET @MinIndex = ((@PageIndex - 1) * @PageSize) + 1;
	SET @MaxIndex = @MinIndex + (@PageSize - 1);

	SELECT 
		  Q.ImportQueueId
		, Q.CreatedOn
		, Q.CreatedBy
		, Q.ImportTypeId
		, Q.[Type]
		, Q.ImportStatusId
		, Q.[Status]
		, Q.FilePath
		, Q.UpdatedOn
		, Q.Error
		, Q.ErrorOn
		
	FROM @PageRecords	AS P
	JOIN ImportQueue_VW AS Q	ON	P.ImportQueueId = Q.ImportQueueId
								AND P.RowIndex BETWEEN @MinIndex AND @MaxIndex
	

