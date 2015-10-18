


CREATE VIEW [dbo].[Fdp_ForecastComparison_VW] AS

	SELECT 
		  FC.ForecastId
		, FC.ForecastVehicleId
		, FC.CreatedOn
		, FC.CreatedBy
		, FV.VehicleId
		, FV.ProgrammeId
		, FV.GatewayId
		, V.Make
		, P.VehicleName AS Code
		, P.VehicleName + ' - ' + P.VehicleAKA AS [Description]
		, P.VehicleName + ' - ' + P.VehicleAKA + ' (' + P.ModelYear + ')' AS FullDescription
		, P.ModelYear
		, G.Gateway
		, FC.SortOrder
	FROM
	Fdp_ForecastComparison			AS FC
	LEFT JOIN Fdp_ForecastVehicle	AS FV	ON	FC.ForecastVehicleId	= FV.ForecastVehicleId
	LEFT JOIN OXO_Programme_VW		AS P	ON	FV.ProgrammeId			= P.Id
											AND FV.VehicleId			= P.VehicleId
	LEFT JOIN OXO_Vehicle			AS V	ON	FV.VehicleId			= V.Id
	LEFT JOIN OXO_Gateway			AS G	ON	FV.GatewayId			= G.Id
	WHERE
	FC.IsActive = 1







