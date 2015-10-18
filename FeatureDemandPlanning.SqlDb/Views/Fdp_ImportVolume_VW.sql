CREATE VIEW Fdp_ImportVolume_VW AS

	WITH Volumes AS
	(
		SELECT
			  I.FdpImportId
			, I.MarketId
			, I.MarketGroupId
			, I.ModelId
			, I.TrimId
			, I.EngineId
			, I.SpecialFeatureCodeTypeId
			, CAST(I.ImportVolume AS INT) AS Volume
		FROM
		Fdp_Import_VW				AS I
		WHERE 
		I.IsExistingData = 0
		AND
		I.IsMarketMissing = 0
		AND
		I.IsDerivativeMissing = 0
		AND
		I.IsFeatureMissing = 0
		AND
		I.IsSpecialFeatureCode = 1
	)
	, FullYearVolumes AS
	(
		SELECT
			  I.FdpImportId
			, I.MarketId
			, I.MarketGroupId
			, I.ModelId
			, I.TrimId
			, I.EngineId
			, I.Volume
		FROM
		Volumes					AS I
		WHERE 
		I.SpecialFeatureCodeTypeId = 1 -- TOTALVOLUME
	),
	HalfYearVolumes AS
	(
		SELECT
			  I.FdpImportId
			, I.MarketId
			, I.MarketGroupId
			, I.ModelId
			, I.TrimId
			, I.EngineId
			, I.Volume
		FROM
		Volumes					AS I
		WHERE 
		I.SpecialFeatureCodeTypeId = 2 -- HALFYEARVOLUME
	)

	SELECT
		  I.FdpImportId   
		, I.MarketId
		, I.MarketGroupId
		, I.ModelId
		, I.TrimId
		, I.EngineId
		, SUM(
			CASE 
				WHEN FY.Volume IS NOT NULL THEN FY.Volume
				WHEN HY.Volume IS NOT NULL THEN HY.Volume
				ELSE 0
			END
		  ) AS TotalVolume
		  
	FROM Volumes				AS I
	LEFT JOIN FullYearVolumes	AS FY	ON	I.FdpImportId	= FY.FdpImportId
										AND I.MarketId		= FY.MarketId
										AND I.MarketGroupId = FY.MarketGroupId
										AND I.ModelId		= FY.ModelId
										AND I.TrimId		= FY.TrimId
										AND I.EngineId		= FY.EngineId
	LEFT JOIN HalfYearVolumes	AS HY	ON	I.FdpImportId	= HY.FdpImportId
										AND I.MarketId		= HY.MarketId
										AND I.MarketGroupId = HY.MarketGroupId
										AND I.ModelId		= HY.ModelId
										AND I.TrimId		= HY.TrimId
										AND I.EngineId		= HY.EngineId
	GROUP BY
		  I.FdpImportId
		, I.MarketId
		, I.MarketGroupId
		, I.ModelId
		, I.TrimId
		, I.EngineId
