CREATE PROCEDURE [dbo].[Fdp_ImportQueue_GetMany]
	  @FdpImportQueueId		INT			= NULL
	, @FdpImportTypeId		INT			= NULL
	, @FdpImportStatusId	INT			= NULL
	, @FilterMessage		NVARCHAR(50) = NULL
	, @PageIndex			INT			= NULL
	, @PageSize				INT			= 10
	, @SortIndex			INT			= 0
	, @SortDirection		VARCHAR(5)	= 'DESC'
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
		  RowIndex INT IDENTITY(1,1)
		, FdpImportQueueId INT
	);
	INSERT INTO @PageRecords (FdpImportQueueId)
	SELECT 
		Q.FdpImportQueueId
	FROM Fdp_ImportQueue_VW AS Q
	JOIN Fdp_Import				AS I	ON	Q.FdpImportQueueId = I.FdpImportQueueId
	JOIN OXO_Programme_VW		AS V	ON	I.ProgrammeId	= V.Id
	WHERE
	(@FdpImportQueueId IS NULL OR Q.FdpImportQueueId = @FdpImportQueueId)
	AND
	(@FdpImportTypeId IS NULL OR Q.FdpImportTypeId = @FdpImportTypeId)
	AND
	(@FdpImportStatusId IS NULL OR Q.FdpImportStatusId = @FdpImportStatusId)
	AND
	(ISNULL(@FilterMessage, '') = '' 
		OR V.VehicleName		LIKE '%' + @FilterMessage + '%'
		OR V.ModelYear			LIKE '%' + @FilterMessage + '%'
		OR I.Gateway			LIKE '%' + @FilterMessage + '%'
		OR V.VehicleAKA			LIKE '%' + @FilterMessage + '%'
		OR Q.OriginalFileName	LIKE '%' + @FilterMessage + '%')
							
	ORDER BY
		CASE @SortDirection
			WHEN 'ASC' THEN
				CASE ISNULL(@SortIndex, 0)
					WHEN 0 THEN CONVERT(VARCHAR, Q.CreatedOn, 120)
					WHEN 1 THEN Q.CreatedBy
					WHEN 2 THEN V.VehicleName + ' ' + V.ModelYear + ' ' + I.Gateway
					WHEN 3 THEN Q.OriginalFileName
					WHEN 4 THEN [Status]
				END
		END ASC,
		CASE @SortDirection
			WHEN 'DESC' THEN
				CASE ISNULL(@SortIndex, 0)
					WHEN 0 THEN CONVERT(VARCHAR, Q.CreatedOn, 120)
					WHEN 1 THEN Q.CreatedBy
					WHEN 2 THEN V.VehicleName + ' ' + V.ModelYear + ' ' + I.Gateway
					WHEN 3 THEN Q.OriginalFileName
					WHEN 4 THEN [Status]
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
		  Q.FdpImportQueueId
		, Q.CreatedOn
		, Q.CreatedBy
		, Q.FdpImportTypeId
		, Q.[Type]
		, Q.FdpImportStatusId
		, Q.[Status]
		, Q.OriginalFileName
		, Q.FilePath
		, Q.UpdatedOn
		, Q.Error
		, Q.ErrorOn
		, V.Id AS ProgrammeId
		, V.VehicleName
		, V.VehicleAKA
		, V.ModelYear
		, I.Gateway
		, D.Version_Id AS Document
		, CAST(CASE WHEN E.ErrorCount > 0 THEN 1 ELSE 0 END AS BIT) AS HasErrors
		, ISNULL(E.ErrorCount, 0) AS ErrorCount
		, E.ErrorType
		, E.ErrorSubType
		, I.DocumentId
		
	FROM @PageRecords			AS P
	JOIN Fdp_ImportQueue_VW		AS Q	ON	P.FdpImportQueueId	= Q.FdpImportQueueId
										AND P.RowIndex BETWEEN @MinIndex AND @MaxIndex
	JOIN Fdp_Import				AS I	ON	Q.FdpImportQueueId	= I.FdpImportQueueId
	JOIN OXO_Programme_VW		AS V	ON	I.ProgrammeId		= V.Id
	JOIN OXO_Doc				AS D	ON	I.DocumentId		= D.Id
	OUTER APPLY dbo.fn_Fdp_ImportErrorCount_GetMany(I.FdpImportId) AS E
	ORDER BY
	P.RowIndex