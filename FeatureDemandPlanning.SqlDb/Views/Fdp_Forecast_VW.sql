



CREATE VIEW [dbo].[Fdp_Forecast_VW] AS

	SELECT 
		  F.Id
		, F.CreatedOn
		, F.CreatedBy
		, FV.ForecastVehicleId
		, FV.VehicleId
		, FV.ProgrammeId
		, FV.GatewayId
		, V.Make
		, P.VehicleName AS Code
		, P.VehicleName + ' - ' + P.VehicleAKA AS [Description]
		, P.VehicleName + ' - ' + P.VehicleAKA + ' (' + P.ModelYear + ', ' + G.Gateway + ')' AS FullDescription
		, P.ModelYear
		, G.Gateway
	FROM
	Fdp_Forecast				AS F 
	JOIN Fdp_ForecastVehicle	AS FV	ON	F.ForecastVehicleId	= FV.ForecastVehicleId
	JOIN OXO_Programme_VW		AS P	ON	FV.ProgrammeId		= P.Id
										AND FV.VehicleId		= P.VehicleId
	JOIN OXO_Vehicle			AS V	ON	FV.VehicleId		= V.Id
	LEFT JOIN OXO_Gateway		AS G	ON	FV.GatewayId		= G.Id








