CREATE PROCEDURE [dbo].[Fdp_ForecastComparisonVehicle_Save]
	  @ForecastId	INT
	, @SystemUser	NVARCHAR(16)
	, @ProgrammeId	INT
	, @VehicleIndex INT
	, @ForecastComparisonId INT OUTPUT
AS
	SET NOCOUNT ON;
	
	DECLARE @ForecastVehicleId INT;
	DECLARE @VehicleId INT;
	DECLARE @GatewayId INT;
	
	IF NOT EXISTS(SELECT TOP 1 1 FROM Fdp_Forecast WHERE Id = @ForecastId)
		RAISERROR (N'Forecast not found', 16, 1);
		
	SELECT @VehicleId = VehicleId FROM OXO_Programme_VW WHERE Id = @ProgrammeId;
	SELECT @GatewayId = Id FROM OXO_Gateway WHERE Gateway = 'FOLD';
		
	SELECT @ForecastVehicleId = ForecastVehicleId 
	FROM Fdp_ForecastVehicle AS FV
	WHERE 
	FV.ProgrammeId = @ProgrammeId
	AND
	FV.VehicleId = @VehicleId
	AND
	FV.GatewayId = @GatewayId;
	
	-- If the vehicle has not been used for forecasting before, add it
	
	IF @ForecastVehicleId IS NULL
	BEGIN
		INSERT INTO FDP_ForecastVehicle
		(
			  ProgrammeId
			, VehicleId
			, GatewayId
		)
		VALUES
		(
			  @ProgrammeId
			, @VehicleId
			, @GatewayId
		);
		
		SET @ForecastVehicleId = SCOPE_IDENTITY();
	END;
	
	-- If the comparison row exists, but is for a different vehicle, mark as inactive
	
	UPDATE C SET C.IsActive = 0
	FROM Fdp_ForecastComparison AS C
	WHERE
	C.ForecastId = @ForecastId
	AND
	C.ForecastVehicleId = @ForecastVehicleId
	AND
	C.IsActive = 1
	AND
	C.SortOrder = @VehicleIndex
	AND
	C.ForecastVehicleId <> @ForecastVehicleId;
	
	-- If the comparison entry does not already exist, add it

	SELECT TOP 1 @ForecastComparisonId = ForecastComparisonId
	FROM 
	Fdp_ForecastComparison AS C
	WHERE
	C.ForecastId = @ForecastId
	AND
	C.ForecastVehicleId = @ForecastVehicleId
	AND
	C.IsActive = 1
	AND
	C.SortOrder = @VehicleIndex
	AND
	C.ForecastVehicleId = @ForecastVehicleId;
	
	IF @ForecastComparisonId IS NULL
	BEGIN
		INSERT INTO Fdp_ForecastComparison
		(
			  ForecastId
			, ForecastVehicleId
			, CreatedOn
			, CreatedBy
			, SortOrder
		)
		VALUES
		(
			  @ForecastId
			, @ForecastVehicleId
			, GETDATE()
			, @SystemUser
			, @VehicleIndex
		);
		
		SET @ForecastComparisonId = SCOPE_IDENTITY();
	END;
	
