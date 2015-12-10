"use strict";

$(document).ready(function () {
    takeRates = new FeatureDemandPlanning.TakeRate.TakeRates(params);
    modal = new FeatureDemandPlanning.Modal.Modal(params);
    
    page = new FeatureDemandPlanning.TakeRate.TakeRatesPage(
        [
            takeRates,
            modal
        ]);

    page.initialise();
});