"use strict";

$(document).ready(function () {
    modal = new FeatureDemandPlanning.Modal.Modal(params);
    marketMapping = new FeatureDemandPlanning.Market.MarketMapping(params);

    page = new FeatureDemandPlanning.Market.MarketMappingsPage([marketMapping, modal]);

    page.initialise();
});