CREATE PROCEDURE [dbo].[Fdp_Forecast_Get]
	@ForecastId INT
AS
	SET NOCOUNT ON;
	
	SELECT 
		  F.Id AS ForecastId
		, F.CreatedOn
		, F.CreatedBy
		
	FROM Fdp_Forecast_VW AS F 
	WHERE
	F.Id = @ForecastId;
	
	-- Second resultset gets the forecast vehicle
	
	SELECT
		  F.ForecastVehicleId
		, F.VehicleId
		, F.ProgrammeId
		, F.GatewayId
		, F.Make
		, F.Code
		, F.[Description]
		, F.FullDescription
		, F.ModelYear
		, F.Gateway
	FROM Fdp_Forecast_VW AS F
	WHERE
	F.Id = @ForecastId;
	
	-- Third resultset returns the comparison vehicles
	
	SELECT 
		  C.ForecastVehicleId
		, C.VehicleId
		, C.ProgrammeId
		, C.GatewayId
		, C.Make
		, C.Code
		, C.[Description]
		, C.FullDescription
		, C.ModelYear
		, C.Gateway
	FROM Fdp_ForecastComparison_VW AS C
	WHERE
	C.ForecastId = @ForecastId
	ORDER BY
	SortOrder
