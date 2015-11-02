"use strict";

$(document).ready(function () {
    forecasts = new FeatureDemandPlanning.Forecast.Forecasts(params);
    modal = new FeatureDemandPlanning.Modal.Modal(params);

    page = new FeatureDemandPlanning.Forecast.ForecastsPage(
        [
            forecasts,
            modal
        ]);

    page.initialise();
});