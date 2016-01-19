"use strict";

$(document).ready(function () {
    modal = new FeatureDemandPlanning.Modal.Modal(params);
    trimMapping = new FeatureDemandPlanning.Trim.TrimMapping(params);

    page = new FeatureDemandPlanning.Trim.TrimMappingsPage([trimMapping, modal]);

    page.initialise();
});