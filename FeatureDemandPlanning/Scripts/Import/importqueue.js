var model = namespace("FeatureDemandPlanning.Import");

model.ImportQueue = function (params) {
    /* Private members */

    var uid = 0;
    var privateStore = {};
    var me = this;

    /* Constructor */
    privateStore[me.id = uid++] = {};
    privateStore[me.id].ImportQueue = params.ImportQueue;
    privateStore[me.id].ImportQueueUri = params.ImportQueueUri;
    privateStore[me.id].ProcessUri = params.ProcessUri;
    privateStore[me.id].CancelUri = params.CancelUri;
    privateStore[me.id].Configuration = params.Configuration;
    privateStore[me.id].PageSize = params.PageSize;
    privateStore[me.id].PageIndex = params.PageIndex;

    me.ModelName = "ImportQueue";

    me.getPageSize = function () {
        return privateStore[me.id].PageSize;
    }

    me.getPageIndex = function () {
        return privateStore[me.id].PageIndex
    }

    me.getImportQueueUri = function () {
        return privateStore[me.id].ImportQueueUri;
    }

    me.getProcessUri = function () {
        return privateStore[me.id].ProcessUri;
    }

    me.getCancelUri = function () {
        return privateStore[me.id].CancelUri;
    }

    me.getImportQueue = function () {
        return privateStore[me.id].ImportQueue;
    };

    me.loadImportQueue = function () {

        $.ajax({
            url: me.getImportQueueUri(),
            type: "GET",
            dataType: "json",
            data: filter,
            success: loadImportQueueCallback,
            error: genericErrorCallback
        });
    }

    me.process = function (importQueueId) {

        $.ajax({
            url: me.getProcessUri(),
            type: "POST",
            dataType: "json",
            data:
            {
                importQueueId: importQueueId
            },
            success: processedImportQueueCallback,
            error: genericErrorCallback
        });
    };

    me.initialise = function () {
        var me = this;
        $(document).trigger("notifySuccess", me);
    };

    function genericSuccessCallback(response) {
        privateStore[me.id].Config = response.Configuration;
        privateStore[me.id].AvailableMarkets = response.AvailableMarkets;
        privateStore[me.id].TopMarkets = response.TopMarkets;
        $(document).trigger("notifySuccess", response);
    };

    function genericErrorCallback(response) {
        if (response.status === 200) {
            return false;
        }
        privateStore[me.id].Config = response.Configuration;
        $(document).trigger("notifyError", response);
    };

    function loadImportQueueCallback(response) {
        $(document).trigger("notifyResults", response);
    }

    function processedImportQueueCallback(response) {
        $(document).trigger("notifyProcessed", response);
    }
};