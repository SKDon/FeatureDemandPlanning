CREATE FUNCTION [dbo].[fn_Fdp_TakeRateData_ByMarketGroup_Get]
(
	@OxoDocId		INT
  , @MarketGroupId	INT
  , @ModelIds		NVARCHAR(MAX)
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
		, 0						AS PackId
		, D.ModelId
		, D.FdpModelId
		, SUM(D.Volume)			AS Volume
		, 0.0					AS PercentageTakeRate	
    FROM 
    Fdp_OxoVolumeDataItem	AS D	WITH(NOLOCK) 
    JOIN @Models			AS M	ON	D.ModelId		= M.ModelId
									AND M.IsFdpModel	= 0
    JOIN Fdp_OxoDoc			AS FO	ON	D.FdpOxoDocId	= FO.FdpOxoDocId
	WHERE 
	FO.OxoDocId = @OxoDocId
	AND
	(@MarketGroupId IS NULL OR D.MarketGroupId = @MarketGroupId)
	AND 
	D.IsActive = 1
	GROUP BY
	  D.ModelId
	, D.FdpModelId
	, D.FeatureId
	, D.FdpFeatureId
	
	UNION
	
	SELECT 
		  D.FeatureId
		, D.FdpFeatureId
		, 0						AS PackId
		, D.ModelId
		, D.FdpModelId
		, SUM(D.Volume)			AS Volume
		, 0.0					AS PercentageTakeRate	
    FROM 
    Fdp_OxoVolumeDataItem	AS D	WITH(NOLOCK) 
    JOIN @Models			AS M	ON	D.FdpModelId	= M.ModelId
									AND M.IsFdpModel	= 1
    JOIN Fdp_OxoDoc			AS FO	ON	D.FdpOxoDocId	= FO.FdpOxoDocId
	WHERE 
	FO.OxoDocId = @OxoDocId
	AND
	(@MarketGroupId IS NULL OR D.MarketGroupId = @MarketGroupId)
	AND 
	D.IsActive = 1
	GROUP BY
	  D.ModelId
	, D.FdpModelId
	, D.FeatureId
	, D.FdpFeatureId
	
	RETURN 
END