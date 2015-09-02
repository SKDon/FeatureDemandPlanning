$(document).ready(function () {
    forecast = new FeatureDemandPlanning.Forecast.Forecast(params);
    vehicle = new FeatureDemandPlanning.Vehicle.Vehicle(params);
    pager = new FeatureDemandPlanning.Pager($(".page"), params);

    page = new FeatureDemandPlanning.Forecast.Page([forecast, vehicle, pager]);

    page.initialise();
});