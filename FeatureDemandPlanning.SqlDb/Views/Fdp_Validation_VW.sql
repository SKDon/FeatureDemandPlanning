CREATE VIEW dbo.Fdp_Validation_VW AS

	SELECT 
		  H.FdpVolumeHeaderId
		, V.ValidationOn
		, V.MarketId
		, R.FdpValidationRuleId
		, R.[Rule]
		, R.[Description]
		, D.FdpVolumeDataItemId
		, CAST(NULL AS INT) AS FdpTakeRateSummaryId
		, CAST(NULL AS INT) AS FdpTakeRateFeatureMixId
		, D.ModelId
		, D.FdpModelId
		, D.FeatureId
		, D.FdpFeatureId
		, D.Volume
		, D.PercentageTakeRate
		, V.[Message]
	FROM
	Fdp_VolumeHeader			AS H
	JOIN Fdp_Validation			AS V	ON	H.FdpVolumeHeaderId		= V.FdpVolumeHeaderId
										AND V.IsActive				= 1
	JOIN Fdp_ValidationRule		AS R	ON	V.FdpValidationRuleId	= R.FdpValidationRuleId
	JOIN Fdp_VolumeDataItem_VW	AS D	ON	V.FdpVolumeDataItemId	= D.FdpVolumeDataItemId
	
	UNION
	
	SELECT 
		  H.FdpVolumeHeaderId
		, V.ValidationOn
		, V.MarketId
		, R.FdpValidationRuleId
		, R.[Rule]
		, R.[Description]
		, CAST(NULL AS INT) AS FdpVolumeDataItemId
		, S.FdpTakeRateSummaryId
		, CAST(NULL AS INT) AS FdpTakeRateFeatureMixId
		, S.ModelId
		, S.FdpModelId
		, CAST(NULL AS INT) AS FeatureId
		, CAST(NULL AS INT) AS FdpFeatureId
		, S.Volume
		, S.PercentageTakeRate
		, V.[Message]
	FROM
	Fdp_VolumeHeader			AS H
	JOIN Fdp_Validation			AS V	ON	H.FdpVolumeHeaderId		= V.FdpVolumeHeaderId
										AND V.IsActive				= 1
	JOIN Fdp_ValidationRule		AS R	ON	V.FdpValidationRuleId	= R.FdpValidationRuleId
	JOIN Fdp_TakeRateSummary	AS S	ON	V.FdpTakeRateSummaryId	= S.FdpTakeRateSummaryId
	
	UNION
	
	SELECT 
		  H.FdpVolumeHeaderId
		, V.ValidationOn
		, V.MarketId
		, R.FdpValidationRuleId
		, R.[Rule]
		, R.[Description]
		, CAST(NULL AS INT) AS FdpVolumeDataItemId
		, CAST(NULL AS INT) AS FdpTakeRateSummaryId
		, F.FdpTakeRateFeatureMixId
		, CAST(NULL AS INT) AS ModelId
		, CAST(NULL AS INT) AS FdpModelId
		, F.FeatureId
		, F.FdpFeatureId
		, F.Volume
		, F.PercentageTakeRate
		, V.[Message]
	FROM
	Fdp_VolumeHeader			AS H
	JOIN Fdp_Validation			AS V	ON	H.FdpVolumeHeaderId			= V.FdpVolumeHeaderId
										AND V.IsActive					= 1
	JOIN Fdp_ValidationRule		AS R	ON	V.FdpValidationRuleId		= R.FdpValidationRuleId
	JOIN Fdp_TakeRateFeatureMix	AS F	ON	V.FdpTakeRateFeatureMixId	= F.FdpTakeRateFeatureMixId