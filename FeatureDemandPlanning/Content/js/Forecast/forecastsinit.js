"use strict";

$(document).ready(function () {
    forecast = new FeatureDemandPlanning.Forecast.Forecast(params);
    forecasts = new FeatureDemandPlanning.Forecast.Forecasts(params);
    modal = new FeatureDemandPlanning.Modal.Modal(params);

    page = new FeatureDemandPlanning.Forecast.ForecastsPage(
        [
            forecasts,
            forecast,
            modal
        ]);

    page.initialise();
});