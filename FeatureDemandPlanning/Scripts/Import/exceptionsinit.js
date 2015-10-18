"use strict";

$(document).ready(function () {
    exceptions = new FeatureDemandPlanning.Import.Exceptions(params);
    modal = new FeatureDemandPlanning.Modal.Modal(params);

    page = new FeatureDemandPlanning.Import.ExceptionsPage([exceptions, modal]);

    page.initialise();
});