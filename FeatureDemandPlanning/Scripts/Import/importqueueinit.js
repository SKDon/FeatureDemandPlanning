"use strict";

$(document).ready(function () {
    importQueue = new FeatureDemandPlanning.Import.ImportQueue(params);
    modal = new FeatureDemandPlanning.Modal.Modal(params);
    exceptions = new FeatureDemandPlanning.Import.Exceptions(params);
    upload = new FeatureDemandPlanning.Import.Upload(params);

    page = new FeatureDemandPlanning.Import.ImportQueuePage([importQueue, exceptions, modal, upload]);

    page.initialise();
});