CREATE FUNCTION [dbo].[fn_Fdp_TakeRateData_ByMarket_Get]
(
	@FdpVolumeHeaderId		INT
  , @MarketId				INT
  , @ModelIds				NVARCHAR(MAX)
)
RETURNS 
@VolumeData TABLE 
(
	  FeatureId				INT NULL
	, FdpFeatureId			INT NULL
	, PackId				INT NULL
	, ModelId				INT NULL
	, FdpModelId			INT NULL
	, Volume				INT NULL
	, PercentageTakeRate	DECIMAL(5,2) NULL
)
AS
BEGIN
	DECLARE @Models AS TABLE
	(	
		  ModelId			INT
		, StringIdentifier	NVARCHAR(10)
		, IsFdpModel		BIT
	);
	INSERT INTO @Models 
	(
		  ModelId
		, StringIdentifier
		, IsFdpModel
	)
	SELECT 
		  ModelId
		, StringIdentifier
		, IsFdpModel
	FROM 
	dbo.fn_Fdp_SplitModelIds(@ModelIds);
	
	INSERT INTO @VolumeData
	(
		  FeatureId
		, FdpFeatureId
		, PackId
		, ModelId
		, FdpModelId
		, Volume
		, PercentageTakeRate
	)
	SELECT 
		  D.FeatureId
		, D.FdpFeatureId
		, 0								AS PackId
		, D.ModelId
		, CAST(NULL AS INT)				AS FdpModelId
		, SUM(D.Volume)					AS Volume
		, MAX(D.PercentageTakeRate)		AS PercentageTakeRate
    FROM 
    Fdp_VolumeDataItem_VW	AS D
    JOIN @Models			AS M	ON	D.ModelId			= M.ModelId
									AND M.IsFdpModel		= 0
	WHERE 
	D.FdpVolumeHeaderId = @FdpVolumeHeaderId
	AND
	(@MarketId IS NULL OR D.MarketId = @MarketId)
	GROUP BY
	  D.ModelId
	--, D.FdpModelId
	, D.FeatureId
	, D.FdpFeatureId
	
	UNION
	
	SELECT 
		  D.FeatureId
		, D.FdpFeatureId
		, 0						AS PackId
		, CAST(NULL AS INT) AS ModelId
		, D.FdpModelId
		, SUM(D.Volume)			AS Volume
		, MAX(D.PercentageTakeRate)	AS PercentageTakeRate
    FROM 
    Fdp_VolumeDataItem_VW	AS D
    JOIN @Models			AS M	ON	D.FdpModelId		= M.ModelId
									AND M.IsFdpModel		= 1
	WHERE 
	D.FdpVolumeHeaderId = @FdpVolumeHeaderId
	AND
	(@MarketId IS NULL OR D.MarketId = @MarketId)
	GROUP BY
	--  D.ModelId
	  D.FdpModelId
	, D.FeatureId
	, D.FdpFeatureId
	
	RETURN 
END