CREATE FUNCTION [dbo].[fn_Fdp_TakeRateData_ByMarket_Get]
(
	@FdpVolumeHeaderId	INT
  , @MarketId			INT
  , @ModelIds			NVARCHAR(MAX)
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
	, IsOrphanedData		BIT
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
		, IsOrphanedData
	)
	-- We still need all features in the list regardless as to whether we have take rate information
	-- We still need all models in the list regardless as to whether we have take rate information
	-- This is why we need to cross join on the models list and use all features that may be available
	
	-- Feature take rates
	
	SELECT 
		  AF.FeatureId
		, CAST(NULL AS INT) AS FdpFeatureId
		, AF.FeaturePackId
		, M.ModelId
		, CAST(NULL AS INT) AS FdpModelId
		, ISNULL(D.Volume, 0)				AS Volume
		, ISNULL(D.PercentageTakeRate, 0)	AS PercentageTakeRate
		, CAST(0 AS BIT)					AS IsOrphanedData
		--, CAST(CASE WHEN ISNULL(F.IsActive, 0) = 0 THEN 1 ELSE 0 END AS BIT) AS IsOrphanedData	
    FROM 
	Fdp_VolumeHeader_VW						AS H
	JOIN OXO_Programme_MarketGroupMarket_VW AS MK	ON	H.ProgrammeId		= MK.Programme_Id
	CROSS APPLY @Models						AS M 
	JOIN Fdp_Feature_VW						AS AF	ON	H.DocumentId		= AF.DocumentId
													AND AF.FeatureId		IS NOT NULL
	LEFT JOIN Fdp_VolumeDataItem_VW			AS D	ON	H.FdpVolumeHeaderId = D.FdpVolumeHeaderId
		    										AND MK.Market_Id		= D.MarketId
													AND M.ModelId			= D.ModelId
													AND AF.FeatureId		= D.FeatureId										
	WHERE 
	H.FdpVolumeHeaderId = @FdpVolumeHeaderId
	AND
	(@MarketId IS NULL OR MK.Market_Id = @MarketId)
	
	UNION
	
	-- Feature pack take rates

	SELECT 
		  AF.FeatureId
		, CAST(NULL AS INT) AS FdpFeatureId
		, AF.FeaturePackId
		, M.ModelId
		, CAST(NULL AS INT) AS FdpModelId
		, ISNULL(D.Volume, 0)				AS Volume
		, ISNULL(D.PercentageTakeRate, 0)	AS PercentageTakeRate
		, CAST(0 AS BIT)					AS IsOrphanedData
		--, CAST(CASE WHEN ISNULL(F.IsActive, 0) = 0 THEN 1 ELSE 0 END AS BIT) AS IsOrphanedData	
    FROM 
	Fdp_VolumeHeader_VW						AS H
	JOIN OXO_Programme_MarketGroupMarket_VW AS MK	ON	H.ProgrammeId		= MK.Programme_Id
	CROSS APPLY @Models						AS M 
	JOIN Fdp_Feature_VW						AS AF	ON	H.DocumentId		= AF.DocumentId
													AND AF.FeatureId		IS NULL
													AND	AF.FeaturePackId	IS NOT NULL
	LEFT JOIN Fdp_VolumeDataItem_VW			AS D	ON	H.FdpVolumeHeaderId = D.FdpVolumeHeaderId
		    										AND MK.Market_Id		= D.MarketId
													AND M.ModelId			= D.ModelId
													AND AF.FeaturePackId	= D.FeaturePackId
													AND D.FeatureId			IS NULL										
	WHERE 
	H.FdpVolumeHeaderId = @FdpVolumeHeaderId
	AND
	(@MarketId IS NULL OR MK.Market_Id = @MarketId)
	
	RETURN; 
END