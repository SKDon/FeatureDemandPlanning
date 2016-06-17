
CREATE PROCEDURE [dbo].[Fdp_TakeRateDataModel_GetTakeRateData] 
    @FdpVolumeHeaderId			INT
  , @MarketId					INT = NULL
  , @ModelIds					NVARCHAR(MAX)
  , @Filter						NVARCHAR(100) = NULL
  , @FeatureCode				NVARCHAR(5) = NULL
  , @ShowCombinedOptions		BIT = 0
  , @ExcludeOptionalPackItems	BIT = 0
AS
	SET NOCOUNT ON;

	-- If there is no pre-computed data for this set of models, create some
	-- This will make future lookups much faster, as there is no joining on tables to perform

	DECLARE @FdpPivotHeaderId AS INT;
	SELECT TOP 1 @FdpPivotHeaderId = FdpPivotHeaderId
	FROM Fdp_PivotHeader 
	WHERE 
	FdpVolumeHeaderId = @FdpVolumeHeaderId
	AND
	(
		(@MarketId IS NULL AND MarketId IS NULL)
		OR
		(@MarketId IS NOT NULL AND MarketId = @MarketId)
	)
	AND
	ModelIds = @ModelIds;

	IF @FdpPivotHeaderId IS NULL
	BEGIN
		EXEC Fdp_PivotData_Update 
			  @FdpVolumeHeaderId = @FdpVolumeHeaderId
			, @MarketId = @MarketId
			, @ModelIds = @ModelIds
			, @FdpPivotHeaderId = @FdpPivotHeaderId OUTPUT;
	END

	SELECT 
		  RANK() OVER (ORDER BY DisplayOrder, FeatureCode, FeatureIdentifier) AS Id
		, DisplayOrder
		, FeatureCode
		, FeatureIdentifier
		, StringIdentifier AS ModelIdentifier
		, ISNULL(PercentageTakeRate, 0) AS PercentageTakeRate
		, ISNULL(Volume, 0) AS Volume
		, OxoCode
		, IsCombinedPackOption
		, IsOptionalPackItem

	FROM Fdp_PivotData
	WHERE 
	FdpPivotHeaderId = @FdpPivotHeaderId
	AND 
	(@FeatureCode IS NULL OR FeatureCode = @FeatureCode)
	AND
	(@ShowCombinedOptions = 1 OR (@ShowCombinedOptions = 0 AND IsCombinedPackOption = 0))
	AND
	(@ExcludeOptionalPackItems = 1 OR (@ExcludeOptionalPackItems = 0 AND IsOptionalPackItem = 0))
	ORDER BY
	DisplayOrder, FeatureCode;