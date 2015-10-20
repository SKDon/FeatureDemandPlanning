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
    privateStore[me.id].ActionsUri = params.ActionsUri;
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
    privateStore[me.id].TotalPages = 0;
    privateStore[me.id].TotalRecords = 0;
    privateStore[me.id].TotalDisplayRecords = 0;
    privateStore[me.id].TotalSuccessRecords = 0;
    privateStore[me.id].TotalFailRecords = 0;

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
    me.getActionsUri = function () {
        return privateStore[me.id].ActionsUri;
    }
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
    me.getImportQueueId = function () {
        return privateStore[me.id].ImportQueueId;
    };
    me.getTotalPages = function () {
        return privateStore[me.id].TotalPages;
    };
    me.getTotalRecords = function () {
        return privateStore[me.id].TotalRecords;
    };
    me.getTotalSuccessRecords = function () {
        return privateStore[me.id].TotalSuccessRecords;
    };
    me.getTotalFailRecords = function () {
        return privateStore[me.id].TotalFailRecords;
    };
    me.getTotalDisplayRecords = function () {
        return privateStore[me.id].TotalDisplayRecords;
    };
    me.setPageIndex = function (pageIndex) {
        privateStore[me.id].PageIndex = pageIndex;
    };
    me.setPageSize = function (pageSize) {
        privateStore[me.id].PageSize = pageSize;
    };
    me.setTotalPages = function (totalPages) {
        privateStore[me.id].TotalPages = totalPages;
    };
    me.setTotalRecords = function (totalRecords) {
        privateStore[me.id].TotalRecords = totalRecords;
    };
    me.setTotalSuccessRecords = function (totalSuccessRecords) {
        privateStore[me.id].TotalSuccessRecords = totalSuccessRecords;
    };
    me.setTotalFailRecords = function (totalFailRecords) {
        privateStore[me.id].TotalFailRecords = totalFailRecords;
    };
    me.setTotalDisplayRecords = function (totalDisplayRecords) {
        privateStore[me.id].TotalDisplayRecords = totalDisplayRecords;
    };
    me.processAction = function (action, callback) {
        var params = { ExceptionId: action.ExceptionId };
        var uri = "";
        switch (action.ActionId) {
            case 8:
                uri = me.getIgnoreUri();
                break;
            default:
                break;
        }
        $.ajax({
            "dataType": "json",
            "async": false,
            "type": "POST",
            "url": uri,
            "data": params,
            "success": function (json) {
                callback(json);
            }
        });
    };
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

