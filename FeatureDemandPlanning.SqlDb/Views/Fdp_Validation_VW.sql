




CREATE VIEW [dbo].[Fdp_Validation_VW] AS

	SELECT 
		  H.FdpVolumeHeaderId
		, V.MarketId
		, M.Market_Group_Id AS MarketGroupId
		, D.ModelId
		, D.FdpModelId
		, CASE WHEN D.ModelId IS NOT NULL 
			THEN 'O' + CAST(D.ModelId AS NVARCHAR(10))
			ELSE 'F' + CAST(D.FdpModelId AS NVARCHAR(10))
		  END AS ModelIdentifier
		, D.FeatureId
		, D.FdpFeatureId
		, CASE
			WHEN D.FeatureId IS NOT NULL THEN 'O' + CAST(D.FeatureId AS NVARCHAR(10))
			WHEN D.FeaturePackId IS NOT NULL THEN 'P' + CAST(D.FeaturePackId AS NVARCHAR(10))
			ELSE 'F' + CAST(D.FdpFeatureId AS NVARCHAR(10))
		  END AS FeatureIdentifier
		, V.[Message]
		, V.FdpChangesetDataItemId
	FROM
	Fdp_VolumeHeader			AS H
	JOIN OXO_Doc				AS O	ON	H.DocumentId			= O.Id
	JOIN Fdp_Validation			AS V	ON	H.FdpVolumeHeaderId		= V.FdpVolumeHeaderId
										AND V.IsActive				= 1
	JOIN Fdp_ValidationRule		AS R	ON	V.FdpValidationRuleId	= R.FdpValidationRuleId
	JOIN Fdp_VolumeDataItem_VW	AS D	ON	V.FdpVolumeDataItemId	= D.FdpVolumeDataItemId
	JOIN OXO_Programme_MarketGroupMarket_VW AS M 
										ON V.MarketId					= M.Market_Id
										AND M.Programme_Id				= O.Programme_Id
	
	UNION
	
	SELECT 
		  H.FdpVolumeHeaderId
		, V.MarketId
		, M.Market_Group_Id AS MarketGroupId
		, S.ModelId
		, S.FdpModelId
		, CASE WHEN S.ModelId IS NOT NULL 
			THEN 'O' + CAST(S.ModelId AS NVARCHAR(10))
			ELSE 'F' + CAST(S.FdpModelId AS NVARCHAR(10))
		  END AS ModelIdentifier
		, CAST(NULL AS INT) AS FeatureId
		, CAST(NULL AS INT) AS FdpFeatureId
		, CAST(NULL AS NVARCHAR(10)) AS FeatureIdentifier
		, V.[Message]
		, V.FdpChangesetDataItemId
	FROM
	Fdp_VolumeHeader			AS H
	JOIN OXO_Doc				AS D	ON	H.DocumentId				= D.Id
	JOIN Fdp_Validation			AS V	ON	H.FdpVolumeHeaderId		= V.FdpVolumeHeaderId
										AND V.IsActive				= 1
	JOIN Fdp_ValidationRule		AS R	ON	V.FdpValidationRuleId	= R.FdpValidationRuleId
	JOIN Fdp_TakeRateSummary	AS S	ON	V.FdpTakeRateSummaryId	= S.FdpTakeRateSummaryId
	JOIN OXO_Programme_MarketGroupMarket_VW AS M 
										ON V.MarketId					= M.Market_Id
										AND M.Programme_Id				= D.Programme_Id
	
	UNION
	
	SELECT 
		  H.FdpVolumeHeaderId
		, V.MarketId
		, M.Market_Group_Id AS MarketGroupId
		, CAST(NULL AS INT) AS ModelId
		, CAST(NULL AS INT) AS FdpModelId
		, CAST(NULL AS NVARCHAR(10)) AS ModelIdentifier
		, F.FeatureId
		, F.FdpFeatureId
		, CASE
			WHEN F.FeatureId IS NOT NULL THEN 'O' + CAST(F.FeatureId AS NVARCHAR(10))
			WHEN F.FeaturePackId IS NOT NULL THEN 'P' + CAST(F.FeaturePackId AS NVARCHAR(10))
			ELSE 'F' + CAST(F.FdpFeatureId AS NVARCHAR(10))
		  END AS FeatureIdentifier
		, V.[Message]
		, V.FdpChangesetDataItemId
	FROM
	Fdp_VolumeHeader			AS H
	JOIN OXO_Doc				AS D	ON	H.DocumentId				= D.Id
	JOIN Fdp_Validation			AS V	ON	H.FdpVolumeHeaderId			= V.FdpVolumeHeaderId
										AND V.IsActive					= 1
	JOIN Fdp_ValidationRule		AS R	ON	V.FdpValidationRuleId		= R.FdpValidationRuleId
	JOIN Fdp_TakeRateFeatureMix	AS F	ON	V.FdpTakeRateFeatureMixId	= F.FdpTakeRateFeatureMixId
	JOIN OXO_Programme_MarketGroupMarket_VW AS M 
										ON V.MarketId					= M.Market_Id
										AND M.Programme_Id				= D.Programme_Id