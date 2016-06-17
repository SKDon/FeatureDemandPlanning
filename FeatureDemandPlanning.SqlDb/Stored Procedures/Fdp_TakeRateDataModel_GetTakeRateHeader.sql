CREATE PROCEDURE [dbo].[Fdp_TakeRateDataModel_GetTakeRateHeader] 
    @FdpVolumeHeaderId			INT = NULL
  , @MarketId					INT = NULL
  , @ModelIds					NVARCHAR(MAX)
AS
	SET NOCOUNT ON;

	DECLARE @FilteredVolume		INT;
	DECLARE @FilteredPercentage	DECIMAL(5,4);
	DECLARE @ModelMix			DECIMAL(5, 4);
	DECLARE @ModelVolume		INT;
	DECLARE @TotalVolume		INT;
	
	-- Work out total volumes so we can calculate percentage take from the feature mix
	
	SELECT TOP 1 @TotalVolume = TotalVolume FROM Fdp_VolumeHeader WHERE FdpVolumeHeaderId = @FdpVolumeHeaderId;

	SELECT @FilteredVolume = @TotalVolume;
	SET @FilteredPercentage = 1;
	SET @ModelMix = 1
	SET @ModelVolume = @TotalVolume;

	IF @MarketId IS NOT NULL 
	BEGIN
		SELECT TOP 1 @FilteredVolume = Volume, @FilteredPercentage = PercentageTakeRate 
		FROM Fdp_TakeRateSummary 
		WHERE
		FdpVolumeHeaderId = @FdpVolumeHeaderId
		AND
		MarketId = @MarketId
		AND
		ModelId IS NULL;

		SELECT @ModelMix = SUM(PercentageTakeRate), @ModelVolume = SUM(Volume)
		FROM
		Fdp_TakeRateSummary
		WHERE
		FdpVolumeHeaderId = @FdpVolumeHeaderId
		AND
		(@MarketId IS NULL OR MarketId = @MarketId)
		AND
		ModelId IS NOT NULL;
	END;

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
	
	-- Summary dataset returning the meta information for the data (created by, updated, total volume mix, volume for market, etc)
	
	SELECT TOP 1
		  ISNULL(@TotalVolume, 0)				AS TotalVolume
		, ISNULL(@FilteredVolume, 0)			AS FilteredVolume
		, ISNULL(@FilteredPercentage, 0.0)		AS PercentageOfTotalVolume
		, ISNULL(@ModelMix, 0)					AS ModelMix
		, ISNULL(@ModelVolume, 0)				AS ModelVolume
		, H.CreatedBy
		, H.CreatedOn
		
	FROM
	Fdp_VolumeHeader AS H
	WHERE
	H.FdpVolumeHeaderId = @FdpVolumeHeaderId