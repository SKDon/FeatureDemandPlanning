"use strict";

$(document).ready(function () {
    takeRateData = new FeatureDemandPlanning.TakeRate.TakeRateData(params);
    modal = new FeatureDemandPlanning.Modal.Modal(params);
    page = new FeatureDemandPlanning.TakeRate.TakeRateDataPage([takeRateData, modal]);
    page.initialise();
});