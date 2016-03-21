"use strict";

$(document).ready(function () {
    modal = new FeatureDemandPlanning.Modal.Modal(params);
    featureCode = new FeatureDemandPlanning.FeatureCode.FeatureCode(params);

    page = new FeatureDemandPlanning.FeatureCode.FeatureCodePage([featureCode, modal]);

    page.initialise();
});