CREATE FUNCTION [dbo].[fn_Fdp_TakeRateData_ByMarketGroup_Get]
(
	@FdpVolumeHeaderId	INT
  , @MarketGroupId		INT
  , @ModelIds			NVARCHAR(MAX)
)
RETURNS TABLE
AS
RETURN
(
	-- We still need all features in the list regardless as to whether we have take rate information
	-- We still need all models in the list regardless as to whether we have take rate information
	-- This is why we need to cross join on the models list and use all features that may be available
	
	-- Feature take rates

	WITH Models AS
	(
		SELECT 
		  ModelId
		, StringIdentifier
		, IsFdpModel
		FROM 
		dbo.fn_Fdp_SplitModelIds(@ModelIds)
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
	CROSS APPLY Models						AS M 
	LEFT JOIN Fdp_VolumeDataItem_VW			AS D	ON	H.FdpVolumeHeaderId = D.FdpVolumeHeaderId
		    										AND MK.Market_Id		= D.MarketId
													AND 
													(
														(M.IsFdpModel = 0 AND M.ModelId = D.ModelId)
														OR
														(M.IsFdpModel = 1 AND M.ModelId = D.FdpModelId)
													)
													AND
													(
														(AF.FeatureId IS NOT NULL AND AF.FeatureId = D.FeatureId)
														OR
														(AF.FdpFeatureId IS NOT NULL AND AF.FdpFeatureId = D.FdpFeatureId)
													)
	LEFT JOIN Fdp_Feature_VW				AS F	ON	H.ProgrammeId		= F.ProgrammeId
													AND H.Gateway			= F.Gateway
													AND 
													(
														(AF.FeatureId = F.FeatureId)
														OR
														(AF.FdpFeatureId = F.FdpFeatureId)
													)																				
	WHERE 
	H.FdpVolumeHeaderId = @FdpVolumeHeaderId
	AND
	(@MarketGroupId IS NULL OR MK.Market_Group_Id = @MarketGroupId)
	AND
	(
		AF.FeatureId IS NOT NULL
		OR
		AF.FdpFeatureId IS NOT NULL
	)
	GROUP BY
	  M.ModelId
	, M.IsFdpModel
	, AF.FeatureId
	, AF.FdpFeatureId
	, AF.FeaturePackId
	, F.IsActive
	
	--UNION
	
	---- Feature pack take rates
	
	--SELECT 
	--	  AF.FeatureId
	--	, AF.FdpFeatureId
	--	, AF.FeaturePackId
	--	, CASE WHEN M.IsFdpModel = 0 THEN M.ModelId ELSE NULL END AS ModelId
	--	, CASE WHEN M.IsFdpModel = 1 THEN M.ModelId ELSE NULL END AS FdpModelId
	--	, SUM(ISNULL(D.Volume, 0))				AS Volume
	--	, MAX(ISNULL(D.PercentageTakeRate, 0))	AS PercentageTakeRate
	--	, CAST(CASE WHEN P.Id IS NULL THEN 1 ELSE 0 END AS BIT) AS IsOrphanedData -- Pack not associated with the programme
 --   FROM 
	--Fdp_VolumeHeader_VW						AS H
	--CROSS APPLY Models						AS M 
	--JOIN Fdp_AllFeatures_VW					AS AF	ON H.FdpVolumeHeaderId	= AF.FdpVolumeHeaderId
	--JOIN OXO_Programme_MarketGroupMarket_VW AS MK	ON	H.ProgrammeId		= MK.Programme_Id
	
	--LEFT JOIN Fdp_VolumeDataItem_VW			AS D	ON	H.FdpVolumeHeaderId = D.FdpVolumeHeaderId
	--	    										AND MK.Market_Id		= D.MarketId
	--												AND 
	--												(
	--													(M.IsFdpModel = 0 AND M.ModelId = D.ModelId)
	--													OR
	--													(M.IsFdpModel = 1 AND M.ModelId = D.FdpModelId)
	--												)
	--												AND AF.FeaturePackId	= D.FeaturePackId
	--												AND D.FeatureId			IS NULL
	--LEFT JOIN OXO_Programme_Pack			AS P	ON	H.ProgrammeId		= P.Programme_Id
	--												AND AF.FeaturePackId	= P.Id													
	--WHERE 
	--H.FdpVolumeHeaderId = @FdpVolumeHeaderId
	--AND
	--(@MarketGroupId IS NULL OR MK.Market_Group_Id = @MarketGroupId)
	--AND
	--AF.FeatureId IS NULL
	--AND
	--AF.FeaturePackId IS NOT NULL
	--GROUP BY
	--  M.ModelId
	--, M.IsFdpModel
	--, AF.FeatureId
	--, AF.FdpFeatureId
	--, AF.FeaturePackId
	--, P.Id
	
)