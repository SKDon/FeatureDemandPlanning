CREATE PROCEDURE [dbo].[Fdp_Forecast_Save]

	  @ForecastId	INT OUTPUT
	, @SystemUser	NVARCHAR(16)
	, @ProgrammeId	INT
	, @Gateway		NVARCHAR(50) = NULL
AS
	SET NOCOUNT ON;
	
	DECLARE @GatewayId INT;
	DECLARE @VehicleId INT;
	DECLARE @ForecastVehicleId INT;
	
	-- If the selected vehicle does not exist, create it
	
	SELECT @VehicleId = VehicleId FROM OXO_Programme_VW WHERE Id = @ProgrammeId;
	
	IF @VehicleId IS NULL
		RAISERROR (N'Vehicle not found', 16, 1);
		
	SELECT @GatewayId = Id FROM OXO_Gateway WHERE Gateway = @Gateway;
	
	IF @GatewayId IS NULL
		RAISERROR (N'Gateway not found', 16, 1);
		
	SELECT @ForecastVehicleId = ForecastVehicleId 
	FROM Fdp_ForecastVehicle AS FV
	WHERE 
	FV.ProgrammeId = @ProgrammeId
	AND
	FV.VehicleId = @VehicleId
	AND
	FV.GatewayId = @GatewayId;
	
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
	
	-- If the forecast has not been created, add it
	-- otherwise update it
	
	IF @ForecastId IS NULL OR NOT EXISTS(SELECT TOP 1 1 FROM Fdp_Forecast WHERE Id = @ForecastId)
	BEGIN
		INSERT INTO Fdp_Forecast
		(
			  CreatedBy
			, CreatedOn
			, ForecastVehicleId
		)
		VALUES
		(
			  @SystemUser
			, GETDATE()
			, @ForecastVehicleId
		)
		
		SET @ForecastId = SCOPE_IDENTITY();
	END
	ELSE
	BEGIN
		UPDATE Fdp_Forecast SET
			  UpdatedBy = @SystemUser
			, UpdatedOn = GETDATE()
			, ForecastVehicleId = @ForecastVehicleId
		WHERE
		Id = @ForecastId;
	END;
	
	
