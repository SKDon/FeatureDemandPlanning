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
	, FeaturePackId			INT NULL
	, ModelId				INT NULL
	, FdpModelId			INT NULL
	, Volume				INT NULL
	, PercentageTakeRate	DECIMAL(5,4) NULL
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
		, FeaturePackId
		, ModelId
		, FdpModelId
		, Volume
		, PercentageTakeRate
	)
	SELECT 
		  D.FeatureId
		, D.FdpFeatureId
		, D.FeaturePackId
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
	, D.FeatureId
	, D.FdpFeatureId
	, D.FeaturePackId
	
	UNION
	
	SELECT 
		  D.FeatureId
		, D.FdpFeatureId
		, D.FeaturePackId
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
	  D.FdpModelId
	, D.FeatureId
	, D.FdpFeatureId
	, D.FeaturePackId
	
	
	-- Features that have no take rate information, we still need to return as they need to be included in the matrix
	-- So add them to the results
	
	INSERT INTO @VolumeData
	(
		  FeatureId
		, FdpFeatureId
		, FeaturePackId
		, ModelId
		, FdpModelId
		, Volume
		, PercentageTakeRate
	)
	SELECT
		    F.FeatureId
		  , F.FdpFeatureId
		  , F.FeaturePackId
		  , CASE WHEN M.IsFdpModel = 0 THEN M.ModelId ELSE NULL END AS ModelId
		  , CASE WHEN M.IsFdpModel = 1 THEN M.ModelId ELSE NULL END AS FdpModelId
		  , 0 AS Volume
		  , 0 AS PercentageTakeRate
	FROM
	Fdp_VolumeHeader AS H
	JOIN OXO_Doc AS O ON H.DocumentId = O.Id
	JOIN Fdp_FeatureMapping_VW AS F ON F.ProgrammeId = O.Programme_Id
									AND F.Gateway = O.Gateway
	CROSS APPLY @Models AS M
	LEFT JOIN @VolumeData AS D ON (
		F.FeatureId = D.FeatureId
		OR
		F.FdpFeatureId = D.FdpFeatureId
		OR
		(F.FeaturePackId = D.FeaturePackId AND D.FeatureId IS NULL)
	)
	WHERE 
	H.FdpVolumeHeaderId = @FdpVolumeHeaderId
	AND
	D.Volume IS NULL
	
	RETURN 
END