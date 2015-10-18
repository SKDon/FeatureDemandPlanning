CREATE PROCEDURE [dbo].[Fdp_Forecast_GetMany]
	@ForecastId INT = NULL
AS
	SET NOCOUNT ON;
	
	SELECT 
		  F.Id AS ForecastId
		, F.CreatedOn
		, F.CreatedBy
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
	(@ForecastId IS NULL OR F.Id = @ForecastId);

