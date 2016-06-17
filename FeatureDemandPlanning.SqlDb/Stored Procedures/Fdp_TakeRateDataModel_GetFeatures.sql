CREATE PROCEDURE [dbo].[Fdp_TakeRateDataModel_GetFeatures] 
    @FdpVolumeHeaderId	INT = NULL
  , @ModelIds			NVARCHAR(MAX) = NULL
  , @MarketId			INT = NULL
AS
	SET NOCOUNT ON;
	
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
		  RANK() OVER (ORDER BY P.DisplayOrder, P.FeatureCode, P.FeatureIdentifier) AS Id
		, P.DisplayOrder
		, P.FeatureIdentifier
		, P.FeatureGroup
		, P.FeatureSubGroup
		, P.FeatureCode
		, P.BrandDescription
		, P.HasRule
		, P.IsMappedToMultipleImportFeatures
		, CAST(CASE WHEN ISNULL(P.FeatureComment, '') <> '' THEN 1 ELSE 0 END AS BIT) AS HasComment
		, P.ExclusiveFeatureGroup
		, FMIX.Volume
		, FMIX.PercentageTakeRate
	FROM
	Fdp_PivotData AS P
	JOIN
	(
		SELECT
		MAX(FdpPivotDataId) AS FdpPivotDataId
		FROM
		Fdp_PivotData
		WHERE
		FdpPivotHeaderId = @FdpPivotHeaderId
		GROUP BY
		FdpPivotHeaderId, FeatureIdentifier
	)
	AS P1 ON P.FdpPivotDataId = P1.FdpPivotDataId
	JOIN Fdp_TakeRateFeatureMixPivot_VW AS FMIX ON P.FeatureIdentifier = FMIX.FeatureIdentifier
	WHERE
	FMIX.FdpVolumeHeaderId = @FdpVolumeHeaderId
	AND
	(
		(@MarketId IS NULL AND FMIX.MarketId IS NULL)
		OR
		(@MarketId IS NOT NULL AND FMIX.MarketId = @MarketId)
	)
	ORDER BY
	Id;