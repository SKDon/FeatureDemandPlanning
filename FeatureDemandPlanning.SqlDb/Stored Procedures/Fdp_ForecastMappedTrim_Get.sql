CREATE PROCEDURE [dbo].[Fdp_ForecastMappedTrim_Get]
	@ForecastId INT
AS
	-- TODO make this dynamic based on the number of trim levels defined for the forecast
	-- vehicle
	
	SET NOCOUNT ON;

	WITH TrimLevelsForForecastVehicle AS
	(
		SELECT 
			  ForecastId
			, ForecastComparisonId
			, ProgrammeId
			, MAX([1])		AS TrimId1
			, MAX([TL1])	AS TrimLevel1
			, MAX([TLA1])	AS TrimLevelAbbr1
			, MAX([2])		AS TrimId2
			, MAX([TL2])	AS TrimLevel2
			, MAX([TLA2])	AS TrimLevelAbbr2
			, MAX([3])		AS TrimId3
			, MAX([TL3])	AS TrimLevel3
			, MAX([TLA3])	AS TrimLevelAbbr3
			, MAX([4])		AS TrimId4
			, MAX([TL4])	AS TrimLevel4
			, MAX([TLA4])	AS TrimLevelAbbr4
			, MAX([5])		AS TrimId5
			, MAX([TL5])	AS TrimLevel5
			, MAX([TLA5])	AS TrimLevelAbbr5
		FROM
		(
			SELECT
				  F.ForecastId	AS ForecastId
				, NULL			AS ForecastComparisonId
				, FV.ProgrammeId	AS ProgrammeId
				, T.TrimId
				, T.TrimName
				, T.Abbreviation
				, T.[Level]
				, T.TrimLevel
				, T.TrimLevelAbbr
			FROM 
			Fdp_Forecast				AS F
			JOIN Fdp_ForecastVehicle	AS FV	ON F.ForecastVehicleId	= FV.ForecastVehicleId
			LEFT JOIN Fdp_TrimLevels	AS T	ON FV.ProgrammeId		= T.ProgrammeId
			WHERE
			(@ForecastId IS NULL OR F.FdpForecastId = @ForecastId)
		)
		AS QUERY
		PIVOT 
		(
			MAX(TrimId)
			FOR Level IN ([1], [2], [3], [4], [5])
		)
		AS P1
		PIVOT
		(
			MAX(TrimName)
			FOR TrimLevel IN ([TL1], [TL2], [TL3], [TL4], [TL5])
		)
		AS P2
		PIVOT
		(
			MAX(Abbreviation)
			FOR TrimLevelAbbr IN ([TLA1], [TLA2], [TLA3], [TLA4], [TLA5])
		)
		AS P3
		GROUP BY
		ForecastId, ForecastComparisonId, ProgrammeId
	)
	
	-- 1st resultset defines the trim levels for the forecast 
	
	SELECT    
		  F.ForecastId
		, F.ForecastComparisonId
		, F.ProgrammeId
		, P.VehicleMake
		, P.VehicleName
		, P.VehicleName + ' - ' + P.VehicleAKA AS VehicleDescription
		, F.TrimId1
		, F.TrimLevel1
		, F.TrimLevelAbbr1
		, F.TrimId2
		, F.TrimLevel2
		, F.TrimLevelAbbr2
		, F.TrimId3
		, F.TrimLevel3
		, F.TrimLevelAbbr3
		, F.TrimId4
		, F.TrimLevel4
		, F.TrimLevelAbbr4
		, F.TrimId5
		, F.TrimLevel5
		, F.TrimLevelAbbr5
			
	FROM TrimLevelsForForecastVehicle	AS F
	JOIN OXO_Programme_VW				AS P ON F.ProgrammeId = P.Id;
	
	WITH TrimLevelsForComparisonVehicles AS
	(
		SELECT 
			  ForecastId
			, ForecastComparisonId
			, ProgrammeId
			, MAX([1])		AS TrimId1
			, MAX([TL1])	AS TrimLevel1
			, MAX([TLA1])	AS TrimLevelAbbr1
			, MAX([2])		AS TrimId2
			, MAX([TL2])	AS TrimLevel2
			, MAX([TLA2])	AS TrimLevelAbbr2
			, MAX([3])		AS TrimId3
			, MAX([TL3])	AS TrimLevel3
			, MAX([TLA3])	AS TrimLevelAbbr3
			, MAX([4])		AS TrimId4
			, MAX([TL4])	AS TrimLevel4
			, MAX([TLA4])	AS TrimLevelAbbr4
			, MAX([5])		AS TrimId5
			, MAX([TL5])	AS TrimLevel5
			, MAX([TLA5])	AS TrimLevelAbbr5
		FROM
		(
			SELECT
				  F.Id				AS ForecastId
				, C.ForecastComparisonId 
				, FVC.ProgrammeId	AS ProgrammeId
				, T2.TrimId
				, T.[Level]
				, T2.TrimName
				, T2.Abbreviation
				, T2.TrimLevel
				, T2.TrimLevelAbbr
			FROM 
			Fdp_Forecast							AS F
			JOIN Fdp_ForecastComparison				AS C	ON	F.Id				= C.ForecastId
															AND C.IsActive			= 1
			JOIN Fdp_ForecastVehicle				AS FV	ON	F.ForecastVehicleId	= FV.ForecastVehicleId
			JOIN Fdp_ForecastVehicle				AS FVC	ON	C.ForecastVehicleId = FVC.ForecastVehicleId
			
			-- The trim levels of the forecast vehicle
			LEFT JOIN Fdp_TrimLevels				AS T	ON	FV.ProgrammeId		= T.ProgrammeId
			
			-- The trim levels of the comparison vehicle that have been mapped by the user
			LEFT JOIN Fdp_ForecastComparisonTrim	AS FT	ON	C.ForecastComparisonId  = FT.ForecastComparisonId
															AND T.[Level]				= FT.[Level]
			LEFT JOIN Fdp_TrimLevels				AS T2	ON	FT.TrimId				= T2.TrimId
			WHERE
			(@ForecastId IS NULL OR F.ForecastId = @ForecastId)
		)
		AS QUERY
		PIVOT 
		(
			MAX(TrimId)
			FOR Level IN ([1], [2], [3], [4], [5])
		)
		AS P1
		PIVOT
		(
			MAX(TrimName)
			FOR TrimLevel IN ([TL1], [TL2], [TL3], [TL4], [TL5])
		)
		AS P2
		PIVOT
		(
			MAX(Abbreviation)
			FOR TrimLevelAbbr IN ([TLA1], [TLA2], [TLA3], [TLA4], [TLA5])
		)
		AS P3
		GROUP BY
		ForecastId, ForecastComparisonId, ProgrammeId
	)

	-- 2nd resultset defines the comparison trim levels including those that have been saved
	
	SELECT    
		  C.ForecastId
		, C.ForecastComparisonId
		, C.ProgrammeId
		, P.VehicleMake
		, P.VehicleName
		, P.VehicleName + ' - ' + P.VehicleAKA AS VehicleDescription
		, C.TrimId1
		, C.TrimLevel1
		, C.TrimLevelAbbr1
		, C.TrimId2
		, C.TrimLevel2
		, C.TrimLevelAbbr2
		, C.TrimId3
		, C.TrimLevel3
		, C.TrimLevelAbbr3
		, C.TrimId4
		, C.TrimLevel4
		, C.TrimLevelAbbr4
		, C.TrimId5
		, C.TrimLevel5
		, C.TrimLevelAbbr5
			
	FROM TrimLevelsForComparisonVehicles	AS C
	JOIN OXO_Programme_VW					AS P ON C.ProgrammeId = P.Id;


