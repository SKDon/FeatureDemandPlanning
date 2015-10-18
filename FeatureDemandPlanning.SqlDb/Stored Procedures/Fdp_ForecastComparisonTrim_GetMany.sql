CREATE PROCEDURE dbo.Fdp_ForecastComparisonTrim_GetMany 
	@ForecastId INT
AS
BEGIN
	SET NOCOUNT ON;

    SELECT
		  T.ForecastComparisonTrimId	AS Id 
		, F.Id							AS ForecastId
		, T.ForecastVehicleTrimId
		, RANK() OVER (ORDER BY C.ForecastComparisonId)	
										AS VehicleIndex
		, V.ProgrammeId					AS ComparisonVehicleProgrammeId
		, T.ComparisonVehicleTrimId
		
    FROM Fdp_Forecast				AS F
    JOIN Fdp_ForecastComparison		AS C	ON	F.Id					= C.ForecastId
											AND C.IsActive				= 1
	JOIN Fdp_ForecastVehicle		AS V	ON  C.ForecastVehicleId		= V.ForecastVehicleId
	JOIN Fdp_ForecastComparisonTrim AS T	ON	C.ForecastComparisonId	= T.ForecastComparisonId
											AND T.IsActive				= 1
    WHERE
    F.Id = @ForecastId
    ORDER BY
    Id, VehicleIndex;
END
