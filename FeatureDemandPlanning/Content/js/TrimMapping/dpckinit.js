"use strict";

$(document).ready(function () {
    modal = new FeatureDemandPlanning.Modal.Modal(params);
    dpck = new FeatureDemandPlanning.Dpck.Dpck(params);

    page = new FeatureDemandPlanning.Dpck.DpckPage([dpck, modal]);

    page.initialise();
});