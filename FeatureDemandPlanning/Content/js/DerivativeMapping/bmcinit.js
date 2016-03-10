"use strict";

$(document).ready(function () {
    modal = new FeatureDemandPlanning.Modal.Modal(params);
    bmc = new FeatureDemandPlanning.Bmc.BrochureModelCode(params);

    page = new FeatureDemandPlanning.Bmc.BmcPage([bmc, modal]);

    page.initialise();
});