CREATE PROCEDURE [dbo].[Fdp_Forecast_Delete]

	  @ForecastId	INT
AS
	SET NOCOUNT ON;
	
	IF NOT EXISTS(SELECT TOP 1 1 FROM Fdp_Forecast WHERE Id = @ForecastId)
		RAISERROR (N'Forecast not found', 16, 1);
		
	UPDATE Fdp_Forecast SET IsActive = 0 WHERE Id = @ForecastId;
	
	SELECT 
		  F.Id
		, F.CreatedOn
		, F.CreatedBy
		, F.VehicleId
		, F.ProgrammeId
		, F.GatewayId
		, F.Make
		, F.Code
		, F.[Description]
		, F.ModelYear
		, F.Gateway
		
	FROM Fdp_Forecast_VW AS F
	WHERE
	ForecastId = @ForecastId;
	
	
