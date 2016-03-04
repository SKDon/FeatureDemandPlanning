CREATE FUNCTION [dbo].[fn_Fdp_TakeRateData_ByMarket_Get2]
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
	SELECT 
		  F.FeatureId
		, F.FdpFeatureId
		, F.FeaturePackId
		, M.ModelId
		, NULL
		, SUM(ISNULL(D.Volume, 0))				AS Volume
		, MAX(ISNULL(D.PercentageTakeRate, 0))	AS PercentageTakeRate
		, CAST(0 AS BIT)						AS IsOrphanedData		
    FROM 
	Fdp_VolumeHeader_VW						AS H
	CROSS APPLY @Models						AS M
	JOIN OXO_Programme_MarketGroupMarket_VW AS MK	ON	H.ProgrammeId		= MK.Programme_Id
	JOIN Fdp_Feature_VW						AS F	ON	H.ProgrammeId		= F.ProgrammeId
													AND	H.Gateway			= F.Gateway
    LEFT JOIN Fdp_VolumeDataItem_VW			AS D	ON	H.FdpVolumeHeaderId = D.FdpVolumeHeaderId
		    										AND MK.Market_Id		= D.MarketId
													AND M.ModelId			= D.ModelId
													AND 
													(
														F.FeatureId = D.FeatureId
														OR
														F.FdpFeatureId = D.FdpFeatureId
													)
	WHERE 
	H.FdpVolumeHeaderId = @FdpVolumeHeaderId
	AND
	M.IsFdpModel = 0
	AND
	(F.FeatureId IS NOT NULL OR F.FdpFeatureId IS NOT NULL)
	AND
	(@MarketId IS NULL OR MK.Market_Id = @MarketId)
	GROUP BY
	  M.ModelId
	, F.FeatureId
	, F.FdpFeatureId
	, F.FeaturePackId
	
	UNION

	SELECT 
		  NULL
		, NULL
		, F.FeaturePackId
		, M.ModelId
		, NULL
		, SUM(ISNULL(D.Volume, 0))				AS Volume
		, MAX(ISNULL(D.PercentageTakeRate, 0))	AS PercentageTakeRate
		, CAST(0 AS BIT)						AS IsOrphanedData		
    FROM 
	Fdp_VolumeHeader_VW						AS H
	CROSS APPLY @Models						AS M
	JOIN OXO_Programme_MarketGroupMarket_VW AS MK	ON	H.ProgrammeId		= MK.Programme_Id
	JOIN Fdp_Feature_VW						AS F	ON	H.ProgrammeId		= F.ProgrammeId
													AND	H.Gateway			= F.Gateway
    LEFT JOIN Fdp_VolumeDataItem_VW			AS D	ON	H.FdpVolumeHeaderId	= D.FdpVolumeHeaderId
		    										AND MK.Market_Id		= D.MarketId
													AND M.ModelId			= D.ModelId
													AND 
													(
														F.FeatureId = D.FeatureId
														OR
														F.FdpFeatureId = D.FdpFeatureId
													)
	WHERE 
	H.FdpVolumeHeaderId = @FdpVolumeHeaderId
	AND
	M.IsFdpModel = 0
	AND
	F.FeatureId IS NULL 
	AND 
	F.FdpFeatureId IS NULL
	AND
	F.FeaturePackId IS NOT NULL
	AND
	(@MarketId IS NULL OR MK.Market_Id = @MarketId)
	GROUP BY
	  M.ModelId
	, F.FeaturePackId

	UNION
	
		SELECT 
		  F.FeatureId
		, F.FdpFeatureId
		, F.FeaturePackId
		, NULL
		, M.ModelId
		, SUM(ISNULL(D.Volume, 0))				AS Volume
		, MAX(ISNULL(D.PercentageTakeRate, 0))	AS PercentageTakeRate
		, CAST(0 AS BIT)						AS IsOrphanedData		
    FROM 
	Fdp_VolumeHeader_VW						AS H
	CROSS APPLY @Models						AS M
	JOIN OXO_Programme_MarketGroupMarket_VW AS MK	ON	H.ProgrammeId		= MK.Programme_Id
	JOIN Fdp_Feature_VW						AS F	ON	H.ProgrammeId		= F.ProgrammeId
													AND	H.Gateway			= F.Gateway
    LEFT JOIN Fdp_VolumeDataItem_VW			AS D	ON	H.FdpVolumeHeaderId = D.FdpVolumeHeaderId
		    										AND MK.Market_Id		= D.MarketId
													AND M.ModelId			= D.FdpModelId
													AND 
													(
														F.FeatureId = D.FeatureId
														OR
														F.FdpFeatureId = D.FdpFeatureId
													)
	WHERE 
	H.FdpVolumeHeaderId = @FdpVolumeHeaderId
	AND
	M.IsFdpModel = 1
	AND
	(F.FeatureId IS NOT NULL OR F.FdpFeatureId IS NOT NULL)
	AND
	(@MarketId IS NULL OR MK.Market_Id = @MarketId)
	GROUP BY
	  M.ModelId
	, F.FeatureId
	, F.FdpFeatureId
	, F.FeaturePackId
	
	UNION
	
	-- Show orphaned features. These are where we have take rate information, but these features are no longer 
	-- available for the programme
	
	SELECT 
		  D.FeatureId
		, D.FdpFeatureId
		, D.FeaturePackId
		, M.ModelId
		, NULL
		, SUM(ISNULL(D.Volume, 0))				AS Volume
		, MAX(ISNULL(D.PercentageTakeRate, 0))	AS PercentageTakeRate
		, CAST(1 AS BIT)						AS IsOrphanedData	
    FROM 
	Fdp_VolumeHeader_VW						AS H
	CROSS APPLY @Models						AS M
	JOIN OXO_Programme_MarketGroupMarket_VW AS MK	ON	H.ProgrammeId		= MK.Programme_Id
	JOIN Fdp_VolumeDataItem_VW				AS D	ON	H.FdpVolumeHeaderId = D.FdpVolumeHeaderId
		    										AND MK.Market_Id		= D.MarketId
													AND M.ModelId			= D.ModelId
	LEFT JOIN Fdp_Feature_VW				AS F	ON	H.ProgrammeId		= F.ProgrammeId
													AND H.Gateway			= F.Gateway
													AND 
													(
														(D.FeatureId = F.FeatureId)
														OR
														(D.FdpFeatureId = F.FdpFeatureId)
														OR
														(D.FeaturePackId = F.FeaturePackId AND D.FeatureId IS NULL)
													)											
	WHERE 
	H.FdpVolumeHeaderId = @FdpVolumeHeaderId
	AND
	M.IsFdpModel = 0
	AND
	F.Id IS NULL
	AND
	(@MarketId IS NULL OR MK.Market_Id = @MarketId)
	GROUP BY
	  M.ModelId
	, D.FeatureId
	, D.FdpFeatureId
	, D.FeaturePackId
	
	RETURN; 
END