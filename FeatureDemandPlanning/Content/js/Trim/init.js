"use strict";

$(document).ready(function () {
    modal = new FeatureDemandPlanning.Modal.Modal(params);
    trim = new FeatureDemandPlanning.Trim.Trim(params);

    page = new FeatureDemandPlanning.Trim.TrimsPage([trim, modal]);

    page.initialise();
});