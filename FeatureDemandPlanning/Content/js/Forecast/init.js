$(document).ready(function () {
    forecast = new FeatureDemandPlanning.Forecast.Forecast(params);
    vehicle = new FeatureDemandPlanning.Vehicle.Vehicle(params);
    pager = new FeatureDemandPlanning.Pager($(".page"), params);
    modal = new FeatureDemandPlanning.Modal.Modal(params);
    trimMapping = new FeatureDemandPlanning.TrimMapping.TrimMapping(params);

    page = new FeatureDemandPlanning.Forecast.Page([forecast, vehicle, pager, modal, trimMapping]);

    page.initialise();
});