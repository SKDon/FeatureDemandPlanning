"use strict";

$(document).ready(function () {
    modal = new FeatureDemandPlanning.Modal.Modal(params);
    ignoredException = new FeatureDemandPlanning.IgnoredException.IgnoredException(params);

    page = new FeatureDemandPlanning.IgnoredException.IgnoredExceptionPage([ignoredException, modal]);

    page.initialise();
});