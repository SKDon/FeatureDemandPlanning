CREATE VIEW Fdp_VolumeDataItem_VW
AS
	SELECT
		  FdpVolumeDataItemId
		, CreatedOn
		, CreatedBy
		, FdpVolumeHeaderId
		, IsManuallyEntered
		, MarketId
		, MarketGroupId
		, ModelId
		, FdpModelId
		, TrimId
		, FdpTrimId
		, FeatureId
		, FdpFeatureId
		, FeaturePackId
		, Volume
		, PercentageTakeRate
		, UpdatedOn
		, UpdatedBy
		, CAST(
			CASE
				WHEN
				(ModelId IS NOT NULL OR FdpModelId IS NOT NULL)
				AND
				(FeatureId IS NOT NULL OR FdpFeatureId IS NOT NULL)
				THEN
				1
				ELSE
				0
			END 
			AS BIT
		  )
		  AS IsFeatureData
		, CAST(
			CASE
				WHEN
				ModelId IS NULL
				AND
				FdpModelId IS NULL
				AND
				FeatureId IS NULL 
				AND
				FdpFeatureId IS NULL
				THEN
				1
				ELSE
				0
			END 
			AS BIT
		  )
		  AS IsMarketData
		, CAST(
			CASE
				WHEN
				ModelId IS NULL
				AND
				FdpModelId IS NULL
				AND
				(FeatureId IS NOT NULL OR FdpFeatureId IS NOT NULL)
				THEN
				1
				ELSE
				0
			END 
			AS BIT
		  )
		  AS IsFeatureMix
	FROM
	Fdp_VolumeDataItem AS D