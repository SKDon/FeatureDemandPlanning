"use strict";

$(document).ready(function () {
    modal = new FeatureDemandPlanning.Modal.Modal(params);
    derivative = new FeatureDemandPlanning.Derivative.Derivative(params);

    page = new FeatureDemandPlanning.Derivative.DerivativesPage([derivative, modal]);

    page.initialise();
});