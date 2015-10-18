CREATE PROCEDURE dbo.Fdp_ForecastComparisonTrim_Delete
	  @ForecastId					INT
	, @SystemUser					NVARCHAR(16)
	, @ForecastVehicleTrimId		INT
	, @ComparisonVehicleProgrammeId INT
AS
BEGIN
	SET NOCOUNT ON;
	
	DECLARE @ForecastComparisonId INT;

    UPDATE T SET IsActive = 0
    FROM Fdp_Forecast				AS F
    JOIN Fdp_ForecastComparison		AS C ON F.Id					= C.ForecastId
    JOIN Fdp_ForecastVehicle		AS V ON C.ForecastVehicleId		= V.ForecastVehicleId
    JOIN Fdp_ForecastComparisonTrim AS T ON C.ForecastComparisonId	= T.ForecastComparisonId 
    WHERE
    F.Id = @ForecastId
    AND
    V.ProgrammeId = @ComparisonVehicleProgrammeId
    AND
    T.ForecastVehicleTrimId = @ForecastVehicleTrimId;
    
END
