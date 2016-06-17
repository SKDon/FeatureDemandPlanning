CREATE VIEW Fdp_TakeRateFeatureMixPivot_VW AS

	-- Returns feature mix for both regular features and optional items that are available individually and as part of a pack

	SELECT 
		  FdpVolumeHeaderId
		, MarketId
		, FeatureIdentifier
		, Volume	
		, PercentageTakeRate
	FROM 
	Fdp_TakeRateFeatureMix AS F

	UNION

	SELECT 
	  PACKOPT.FdpVolumeHeaderId
	, PACKOPT.MarketId												
	, PACKOPT.FeatureIdentifier										
	, PACKITEMMIX.Volume + PACKMIX.Volume							AS Volume
	, PACKITEMMIX.PercentageTakeRate + PACKMIX.PercentageTakeRate	AS PercentageTakeRate
	FROM
	(
		SELECT
			  H.FdpVolumeHeaderId
			, H.MarketId
			, P.FeatureIdentifier
			, P.FeatureId
			, P.FeaturePackId
		FROM 
		Fdp_PivotHeader AS H
		JOIN Fdp_PivotData AS P ON H.FdpPivotHeaderId = P.FdpPivotHeaderId										
		WHERE 
		P.IsCombinedPackOption = 1
		--AND
		--H.FdpPivotHeaderId = @FdpPivotHeaderId
		GROUP BY 
		H.FdpVolumeHeaderId, H.MarketId, P.FeatureIdentifier, P.FeatureId, P.FeaturePackId
	)
	AS PACKOPT
	JOIN Fdp_TakeRateFeatureMix AS PACKITEMMIX	ON	PACKOPT.FeatureId			= PACKITEMMIX.FeatureId
												AND PACKOPT.FdpVolumeHeaderId	= PACKITEMMIX.FdpVolumeHeaderId
												AND PACKOPT.MarketId			= PACKITEMMIX.MarketId
	JOIN Fdp_TakeRateFeatureMix AS PACKMIX		ON	PACKOPT.FeaturePackId		= PACKMIX.FeaturePackId
												AND PACKOPT.FdpVolumeHeaderId	= PACKMIX.FdpVolumeHeaderId
												AND PACKOPT.MarketId			= PACKMIX.MarketId