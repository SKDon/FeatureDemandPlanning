"use strict";

$(document).ready(function () {
    exceptions = new FeatureDemandPlanning.Import.Exceptions(params);
    modal = new FeatureDemandPlanning.Modal.Modal(params);
    market = new FeatureDemandPlanning.Import.Market(params);
    derivative = new FeatureDemandPlanning.Import.Derivative(params);
    feature = new FeatureDemandPlanning.Import.Feature(params);
    trim = new FeatureDemandPlanning.Import.Trim(params);
    ignore = new FeatureDemandPlanning.Import.Ignore(params);
   
    page = new FeatureDemandPlanning.Import.ExceptionsPage(
        [
            exceptions,
            modal,
            market,
            derivative,
            trim,
            feature,
            ignore
        ]);

    page.initialise();
});