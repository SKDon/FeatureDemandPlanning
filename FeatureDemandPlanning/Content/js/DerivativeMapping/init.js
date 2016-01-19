"use strict";

$(document).ready(function () {
    modal = new FeatureDemandPlanning.Modal.Modal(params);
    derivativeMapping = new FeatureDemandPlanning.Derivative.DerivativeMapping(params);

    page = new FeatureDemandPlanning.Derivative.DerivativeMappingsPage([derivativeMapping, modal]);

    page.initialise();
});