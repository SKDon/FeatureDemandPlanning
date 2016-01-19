"use strict";

$(document).ready(function () {
    modal = new FeatureDemandPlanning.Modal.Modal(params);
    featureMapping = new FeatureDemandPlanning.Feature.FeatureMapping(params);

    page = new FeatureDemandPlanning.Feature.FeatureMappingsPage([featureMapping, modal]);

    page.initialise();
});