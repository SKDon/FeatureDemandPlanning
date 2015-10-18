CREATE PROCEDURE dbo.Fdp_ForecastComparisonTrim_Save
	  @ForecastId					INT
	, @SystemUser					NVARCHAR(16)
	, @ForecastVehicleTrimId		INT
	, @ComparisonVehicleProgrammeId INT
	, @ComparisonVehicleTrimId		INT
	, @ForecastComparisonTrimId		INT OUTPUT
AS
BEGIN
	SET NOCOUNT ON;
	
	DECLARE @ForecastComparisonId INT;
	
	SELECT TOP 1 @ForecastComparisonId = ForecastComparisonId
	FROM Fdp_ForecastComparison AS C
	JOIN Fdp_ForecastVehicle	AS V ON C.ForecastVehicleId = V.ForecastVehicleId
	WHERE 
	C.ForecastId = @ForecastId
	AND
	V.ProgrammeId = @ComparisonVehicleProgrammeId;

    INSERT INTO Fdp_ForecastComparisonTrim
    (
		  CreatedBy
		, ForecastComparisonId
		, ForecastVehicleTrimId
		, ComparisonVehicleTrimId
    )
    VALUES
    (
		  @SystemUser
		, @ForecastComparisonId
		, @ForecastVehicleTrimId
		, @ComparisonVehicleTrimId
    )
    
    SET @ForecastComparisonTrimId = SCOPE_IDENTITY();
    
END
