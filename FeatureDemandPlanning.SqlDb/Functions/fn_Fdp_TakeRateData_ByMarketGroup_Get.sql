CREATE FUNCTION [dbo].[fn_Fdp_TakeRateData_ByMarketGroup_Get]
(
	@FdpVolumeHeaderId	INT
  , @MarketGroupId		INT
  , @ModelIds			NVARCHAR(MAX)
)
RETURNS @TakeRateData TABLE 
(
	  FeatureId INT NULL
	, FdpFeatureId INT NULL
	, FeaturePackId INT NULL
	, ModelId INT NULL
	, FdpModelId INT NULL
	, Volume INT
	, PercentageTakeRate DECIMAL(5,4)
	, IsOrphanedData BIT
)
AS
BEGIN
	-- We still need all features in the list regardless as to whether we have take rate information
	-- We still need all models in the list regardless as to whether we have take rate information
	-- This is why we need to cross join on the models list and use all features that may be available
	
	-- Feature take rates

	DECLARE @Models AS TABLE
	(
		  ModelId INT NULL
		, StringIdentifier NVARCHAR(20) NULL
		, IsFdpModel BIT
	)
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
		
	INSERT INTO @TakeRateData
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
	SELECT 
		  AF.FeatureId
		, AF.FdpFeatureId
		, AF.FeaturePackId
		, CASE WHEN M.IsFdpModel = 0 THEN M.ModelId ELSE NULL END AS ModelId
		, CASE WHEN M.IsFdpModel = 1 THEN M.ModelId ELSE NULL END AS FdpModelId
		, SUM(ISNULL(D.Volume, 0))				AS Volume
		, MAX(ISNULL(D.PercentageTakeRate, 0))	AS PercentageTakeRate
		, CAST(CASE WHEN ISNULL(F.IsActive, 0) = 0 THEN 1 ELSE 0 END AS BIT) AS IsOrphanedData	
    FROM 
	Fdp_VolumeHeader_VW						AS H
	JOIN OXO_Programme_MarketGroupMarket_VW AS MK	ON	H.ProgrammeId		= MK.Programme_Id
	JOIN Fdp_AllFeatures_VW					AS AF	ON	H.FdpVolumeHeaderId	= AF.FdpVolumeHeaderId
	CROSS APPLY @Models						AS M 
	LEFT JOIN Fdp_VolumeDataItem_VW			AS D	ON	H.FdpVolumeHeaderId = D.FdpVolumeHeaderId
		    										AND MK.Market_Id		= D.MarketId
													AND M.ModelId			= D.ModelId
													AND AF.FeatureId		= D.FeatureId
	LEFT JOIN Fdp_Feature_VW				AS F	ON	H.DocumentId		= F.DocumentId
													AND AF.FeatureId		= F.FeatureId																			
	WHERE 
	H.FdpVolumeHeaderId = @FdpVolumeHeaderId
	AND
	(@MarketGroupId IS NULL OR MK.Market_Group_Id = @MarketGroupId)
	AND
	AF.FeatureId IS NOT NULL
	GROUP BY
	  M.ModelId
	, M.IsFdpModel
	, AF.FeatureId
	, AF.FdpFeatureId
	, AF.FeaturePackId
	, F.IsActive
	
	UNION
	
	-- Feature pack take rates
	
	SELECT 
		  AF.FeatureId
		, AF.FdpFeatureId
		, AF.FeaturePackId
		, CASE WHEN M.IsFdpModel = 0 THEN M.ModelId ELSE NULL END AS ModelId
		, CASE WHEN M.IsFdpModel = 1 THEN M.ModelId ELSE NULL END AS FdpModelId
		, SUM(ISNULL(D.Volume, 0))				AS Volume
		, MAX(ISNULL(D.PercentageTakeRate, 0))	AS PercentageTakeRate
		, CAST(CASE WHEN P.Id IS NULL THEN 1 ELSE 0 END AS BIT) AS IsOrphanedData -- Pack not associated with the programme
    FROM 
	Fdp_VolumeHeader_VW						AS H
	CROSS APPLY @Models						AS M 
	JOIN Fdp_AllFeatures_VW					AS AF	ON H.FdpVolumeHeaderId	= AF.FdpVolumeHeaderId
	JOIN OXO_Programme_MarketGroupMarket_VW AS MK	ON	H.ProgrammeId		= MK.Programme_Id
	
	LEFT JOIN Fdp_VolumeDataItem_VW			AS D	ON	H.FdpVolumeHeaderId = D.FdpVolumeHeaderId
		    										AND MK.Market_Id		= D.MarketId
													AND M.ModelId			= D.ModelId
													AND AF.FeaturePackId	= D.FeaturePackId
													AND D.FeatureId			IS NULL
	LEFT JOIN OXO_Programme_Pack			AS P	ON	H.ProgrammeId		= P.Programme_Id
													AND AF.FeaturePackId	= P.Id													
	WHERE 
	H.FdpVolumeHeaderId = @FdpVolumeHeaderId
	AND
	(@MarketGroupId IS NULL OR MK.Market_Group_Id = @MarketGroupId)
	AND
	AF.FeatureId IS NULL
	AND
	AF.FeaturePackId IS NOT NULL
	GROUP BY
	  M.ModelId
	, M.IsFdpModel
	, AF.FeatureId
	, AF.FdpFeatureId
	, AF.FeaturePackId
	, P.Id
	
	RETURN
END