﻿CREATE FUNCTION [dbo].[fn_Fdp_TakeRateData_ByMarketGroup_Get]
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
		, NULL
		, SUM(D.Volume)			AS Volume
		, MAX(D.PercentageTakeRate)	AS PercentageTakeRate	
    FROM 
    Fdp_VolumeHeader		AS H
    JOIN OXO_Doc			AS D1	ON	H.DocumentId		= D1.Id
    JOIN Fdp_VolumeDataItem AS D	ON	H.FdpVolumeHeaderId	= D.FdpVolumeHeaderId
    JOIN @Models			AS M	ON	D.ModelId			= M.ModelId
									AND M.IsFdpModel		= 0
	JOIN OXO_Programme_MarketGroupMarket_VW 
							AS MK	ON	D.MarketId			= MK.Market_Id
									AND D1.Programme_Id		= MK.Programme_Id
	WHERE 
	H.DocumentId = @OxoDocId
	AND
	(@MarketGroupId IS NULL OR MK.Market_Group_Id = @MarketGroupId)
	GROUP BY
	  D.ModelId
	, D.FeatureId
	, D.FdpFeatureId
	
	UNION
	
	SELECT 
		  D.FeatureId
		, D.FdpFeatureId
		, 0						AS PackId
		, NULL
		, D.FdpModelId
		, SUM(D.Volume)			AS Volume
		, MAX(D.PercentageTakeRate)					AS PercentageTakeRate	
    FROM 
    Fdp_VolumeHeader		AS H
    JOIN OXO_Doc			AS D1	ON	H.DocumentId		= D1.Id
    JOIN Fdp_VolumeDataItem AS D	ON	H.FdpVolumeHeaderId	= D.FdpVolumeHeaderId
    JOIN @Models			AS M	ON	D.FdpModelId		= M.ModelId
									AND M.IsFdpModel		= 1
	JOIN OXO_Programme_MarketGroupMarket_VW 
							AS MK	ON	D.MarketId			= MK.Market_Id
									AND D1.Programme_Id		= MK.Programme_Id
	WHERE 
	H.DocumentId = @OxoDocId
	AND
	(@MarketGroupId IS NULL OR MK.Market_Group_Id = @MarketGroupId)
	GROUP BY
	  D.FdpModelId
	, D.FeatureId
	, D.FdpFeatureId
	
	RETURN; 
END