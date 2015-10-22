"use strict";

$(document).ready(function () {
    importQueue = new FeatureDemandPlanning.Import.ImportQueue(params);
    modal = new FeatureDemandPlanning.Modal.Modal(params);

    page = new FeatureDemandPlanning.Import.ImportQueuePage([importQueue, modal]);

    page.initialise();
});