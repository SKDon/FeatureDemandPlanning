

CREATE VIEW [dbo].[Fdp_VolumeDataItem_VW]
AS
	SELECT
		  D.FdpVolumeDataItemId
		, D.CreatedOn
		, D.CreatedBy
		, H.FdpVolumeHeaderId
		, H.DocumentId
		, D.IsManuallyEntered
		, D.MarketId
		, D.MarketGroupId
		, D.ModelId
		, D.FdpModelId
		, D.TrimId
		, D.FdpTrimId
		, D.FeatureId
		, D.FdpFeatureId
		, D.FeaturePackId
		, D.Volume
		, D.PercentageTakeRate
		, D.UpdatedOn
		, D.UpdatedBy
		, CAST(
			CASE
				WHEN
				(D.ModelId IS NOT NULL OR D.FdpModelId IS NOT NULL)
				AND
				(D.FeatureId IS NOT NULL OR D.FdpFeatureId IS NOT NULL OR D.FeaturePackId IS NOT NULL)
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
				D.ModelId IS NULL
				AND
				D.FdpModelId IS NULL
				AND
				D.FeatureId IS NULL 
				AND
				D.FdpFeatureId IS NULL
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
				D.ModelId IS NULL
				AND
				D.FdpModelId IS NULL
				AND
				(D.FeatureId IS NOT NULL OR D.FdpFeatureId IS NOT NULL)
				THEN
				1
				ELSE
				0
			END 
			AS BIT
		  )
		  AS IsFeatureMix
	FROM
	Fdp_VolumeHeader AS H
	JOIN Fdp_VolumeDataItem AS D ON H.FdpVolumeHeaderId = D.FdpVolumeHeaderId