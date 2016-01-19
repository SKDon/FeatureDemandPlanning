"use strict";

$(document).ready(function () {
    modal = new FeatureDemandPlanning.Modal.Modal(params);
    feature = new FeatureDemandPlanning.Feature.Feature(params);

    page = new FeatureDemandPlanning.Feature.FeaturesPage([feature, modal]);

    page.initialise();
});