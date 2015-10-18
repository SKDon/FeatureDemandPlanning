"use strict";

var model = namespace("FeatureDemandPlanning.Import");

model.ExceptionsFilter = function () {
    var me = this;
    me.ImportQueueId = 0;
    me.ImportExceptionTypeId = 0
    me.FilterMessage = "";
}

model.Exceptions = function (params) {
    var uid = 0;
    var privateStore = {};
    var me = this;

    privateStore[me.id = uid++] = {};
    privateStore[me.id].Config = params.Configuration;
    privateStore[me.id].ExceptionsUri = params.ExceptionsUri;
    privateStore[me.id].AddFeatureUri = params.AddFeatureUri;
    privateStore[me.id].MapFeatureUri = params.MapFeatureUri;
    privateStore[me.id].MapMarketUri = params.MapMarketUri;
    privateStore[me.id].AddDerivativeUri = params.AddDerivativeUri;
    privateStore[me.id].MapDerivativeUri = params.MapDerivativeUri;
    privateStore[me.id].IgnoreUri = params.IgnoreUri;
    privateStore[me.id].ImportQueueId = params.ImportQueueId;
    privateStore[me.id].PageSize = params.PageSize;
    privateStore[me.id].PageIndex = params.PageIndex;

    me.ModelName = "Exceptions";

    me.initialise = function () {
        var me = this;
        $(document).trigger("notifySuccess", me);
    };
    me.filterResults = function () {
        $(document).trigger("FilterComplete");
    };
    me.getConfiguration = function () {
        return privateStore[me.id].Configuration;
    };
    me.getPageSize = function () {
        return privateStore[me.id].PageSize;
    };
    me.getPageIndex = function () {
        return privateStore[me.id].PageIndex
    };
    me.getExceptionsUri = function () {
        var importQueueId =  me.getImportQueueId();
        var uri = privateStore[me.id].ExceptionsUri
        //if (importQueueId != null) {
        //    uri = uri + "?importQueueId=" + importQueueId
        //}
        return uri;
    };
    me.getAddFeatureUri = function () {
        return privateStore[me.id].AddFeatureUri;
    };
    me.getMapFeatureUri = function () {
        return privateStore[me.id].MapFeatureUri;
    };
    me.getAddDerivativeUri = function () {
        return privateStore[me.id].AddDerivativeUri;
    };
    me.getMapDerivativeUri = function () {
        return privateStore[me.id].MapDerivativeUri;
    };
    me.getMapMarketUri = function () {
        return privateStore[me.id].MapMarketUri;
    };
    me.getIgnoreUri = function () {
        return privateStore[me.id].IgnoreUri;
    };
    me.getExceptions = function (callback) {
        //var volume = me.getFilter();
        //var encodedVolume = JSON.stringify(volume);

        //$.ajax({
        //    type: "POST",
        //    url: me.getExceptionsUri(),
        //    data: encodedVolume,
        //    context: this,
        //    contentType: "application/json",
        //    success: function (response) {
        //        callback.call(this, response);
        //    },
        //    error: function (response) {
        //        alert(response.responseText);
        //    },
        //    async: true
        //});
    };
    me.getImportQueueId = function () {
        return privateStore[me.id].ImportQueueId;
    }
    function genericErrorCallback(response) {
        if (response.status == 400) {
            var json = JSON.parse(response.responseText);
            privateStore[me.id].IsValid = false;
            $(document).trigger("Validation", [json]);
        } else {
            $(document).trigger("Error", response);
        }
    };
}

