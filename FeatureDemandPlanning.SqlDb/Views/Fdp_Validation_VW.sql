

CREATE VIEW [dbo].[Fdp_Validation_VW] AS

	SELECT 
		  H.FdpVolumeHeaderId
		, V.FdpValidationId
		, V.ValidationOn
		, V.ValidationBy
		, V.MarketId
		, M.Market_Group_Id AS MarketGroupId
		, V.ModelId
		, V.FdpModelId
		, CASE 
			WHEN V.ModelId IS NOT NULL THEN 'O' + CAST(V.ModelId AS NVARCHAR(10))
			ELSE 'F' + CAST(V.FdpModelId AS NVARCHAR(10))
		  END AS ModelIdentifier
		, V.FeatureId
		, V.FdpFeatureId
		, V.FeaturePackId
		, V.ExclusiveFeatureGroup
		, CASE
			WHEN V.FeatureId IS NOT NULL THEN 'O' + CAST(V.FeatureId AS NVARCHAR(10))
			WHEN V.FeaturePackId IS NOT NULL THEN 'P' + CAST(V.FeaturePackId AS NVARCHAR(10))
			ELSE 'F' + CAST(V.FdpFeatureId AS NVARCHAR(10))
		  END AS FeatureIdentifier
		, V.BodyId
		, V.EngineId
		, V.TransmissionId
		, V.[Message]
		, V.FdpVolumeDataItemId
		, V.FdpChangesetDataItemId
		, V.FdpTakeRateSummaryId
		, V.FdpTakeRateFeatureMixId
		, V.FdpPowertrainDataItemId
	FROM
	Fdp_VolumeHeader_VW			AS H
	JOIN Fdp_Validation			AS V	ON	H.FdpVolumeHeaderId		= V.FdpVolumeHeaderId
										AND V.IsActive				= 1
	JOIN Fdp_ValidationRule		AS R	ON	V.FdpValidationRuleId	= R.FdpValidationRuleId
	JOIN OXO_Programme_MarketGroupMarket_VW AS M 
										ON V.MarketId					= M.Market_Id
										AND M.Programme_Id				= H.ProgrammeId