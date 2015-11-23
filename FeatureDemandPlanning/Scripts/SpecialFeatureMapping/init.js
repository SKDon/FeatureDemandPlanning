"use strict";

$(document).ready(function () {
    modal = new FeatureDemandPlanning.Modal.Modal(params);
    specialFeatureMapping = new FeatureDemandPlanning.Feature.SpecialFeatureMapping(params);

    page = new FeatureDemandPlanning.Feature.SpecialFeatureMappingsPage([specialFeatureMapping, modal]);

    page.initialise();
});