
CREATE VIEW [dbo].[Fdp_Validation_VW] AS

	SELECT 
		  H.FdpVolumeHeaderId
		, V.MarketId
		, CASE WHEN D.ModelId IS NOT NULL 
			THEN 'O' + CAST(D.ModelId AS NVARCHAR(10))
			ELSE 'F' + CAST(D.FdpModelId AS NVARCHAR(10))
		  END AS ModelIdentifier
		, CASE
			WHEN D.FeatureId IS NOT NULL THEN 'O' + CAST(D.FeatureId AS NVARCHAR(10))
			WHEN D.FeaturePackId IS NOT NULL THEN 'P' + CAST(D.FeaturePackId AS NVARCHAR(10))
			ELSE 'F' + CAST(D.FdpFeatureId AS NVARCHAR(10))
		  END AS FeatureIdentifier
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
		, V.MarketId
		, CASE WHEN S.ModelId IS NOT NULL 
			THEN 'O' + CAST(S.ModelId AS NVARCHAR(10))
			ELSE 'F' + CAST(S.FdpModelId AS NVARCHAR(10))
		  END AS ModelIdentifier
		, CAST(NULL AS NVARCHAR(10)) AS FeatureIdentifier
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
		, V.MarketId
		, CAST(NULL AS NVARCHAR(10)) AS ModelIdentifier
		, CASE
			WHEN F.FeatureId IS NOT NULL THEN 'O' + CAST(F.FeatureId AS NVARCHAR(10))
			WHEN F.FeaturePackId IS NOT NULL THEN 'P' + CAST(F.FeaturePackId AS NVARCHAR(10))
			ELSE 'F' + CAST(F.FdpFeatureId AS NVARCHAR(10))
		  END AS FeatureIdentifier
		, V.[Message]
	FROM
	Fdp_VolumeHeader			AS H
	JOIN Fdp_Validation			AS V	ON	H.FdpVolumeHeaderId			= V.FdpVolumeHeaderId
										AND V.IsActive					= 1
	JOIN Fdp_ValidationRule		AS R	ON	V.FdpValidationRuleId		= R.FdpValidationRuleId
	JOIN Fdp_TakeRateFeatureMix	AS F	ON	V.FdpTakeRateFeatureMixId	= F.FdpTakeRateFeatureMixId