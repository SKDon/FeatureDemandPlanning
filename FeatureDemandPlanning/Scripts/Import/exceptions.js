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
    privateStore[me.id].AddFeatureContentUri = params.AddFeatureContentUri;
    privateStore[me.id].AddFeatureActionUri = params.AddFeatureActionUri;
    privateStore[me.id].AddSpecialFeatureContentUri = params.AddSpecialFeatureContentUri;
    privateStore[me.id].AddSpecialFeatureActionUri = params.AddSpecialFeatureActionUri;
    privateStore[me.id].MapFeatureContentUri = params.MapFeatureContentUri;
    privateStore[me.id].MapFeatureActionUri = params.MapFeatureActionUri;
    privateStore[me.id].MapMarketContentUri = params.MapMarketContentUri;
    privateStore[me.id].MapMarketActionUri = params.MapMarketContentUri;
    privateStore[me.id].AddDerivativeContentUri = params.AddDerivativeContentUri;
    privateStore[me.id].AddDerivativeActionUri = params.AddDerivativeActionUri;
    privateStore[me.id].MapDerivativeContentUri = params.MapDerivativeContentUri;
    privateStore[me.id].MapDerivativeActionUri = params.MapDerivativeActionUri;
    privateStore[me.id].AddTrimContentUri = params.AddTrimContentUri;
    privateStore[me.id].AddTrimActionUri = params.AddTrimActionUri;
    privateStore[me.id].MapTrimContentUri = params.MapTrimContentUri;
    privateStore[me.id].IgnoreContentUri = params.IgnoreContentUri;
    privateStore[me.id].IgnoreActionUri = params.IgnoreActionUri;
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
    };
    me.getActionContentUri = function (action) {
        var params = { ExceptionId: action.ExceptionId };
        var uri = "";
        switch (action.ActionId) {
            case 1:
                uri = me.getMapMarketContentUri();
                break;
            case 2:
                uri = me.getAddDerivativeContentUri();
                break;
            case 3:
                uri = me.getMapDerivativeContentUri();
                break;
            case 6:
                uri = me.getAddTrimContentUri();
                break;
            case 7:
                uri = me.getMapTrimContentUri();
                break;
            case 4:
                uri = me.getAddFeatureContentUri();
                break;
            case 5:
                uri = me.getMapFeatureContentUri();
                break;
            case 8:
                uri = me.getIgnoreContentUri();
                break;
            case 9:
                uri = me.getAddSpecialFeatureContentUri();
                break;
            default:
                uri = "";
                break;
        }
        return uri;
    };
    me.getProcessActionUri = function (action) {
        var uri = "";
        switch (action.ActionId) {
            case 1:
                uri = me.getMapMarketActionUri();
                break;
            case 2:
                uri = me.getAddDerivativeActionUri();
                break;
            case 3:
                uri = me.getMapDerivativeActionUri();
                break;
            case 6:
                uri = me.getAddTrimActionUri();
                break;
            case 7:
                uri = me.getMapTrimActionUri();
                break;
            case 4:
                uri = me.getAddFeatureActionUri();
                break;
            case 5:
                uri = me.getMapFeatureActionUri();
                break;
            case 8:
                uri = me.getIgnoreActionUri();
                break;
            case 9:
                uri = me.getAddSpecialFeatureActionUri();
                break;
            default:
                uri = "";
                break;
        }
        return uri;
    };
    me.getActionTitle = function (action) {
        var params = { ExceptionId: action.ExceptionId };
        var title = "";
        switch (action.ActionId) {
            case 1:
                title = "Map Market to OXO";
                break;
            case 2:
                title = "Add New Derivative";
                break;
            case 3:
                title = "Map Derivative to OXO";
                break;
            case 6:
                title = "Add New Trim";
                break;
            case 7:
                title = "Map Trim to OXO";
                break;
            case 4:
                title = "Add New Feature";
                break;
            case 5:
                title = "Map Feature to OXO";
                break;
            case 8:
                title = "Ignore Error";
                break;
            case 9:
                title = "Add New Special Feature";
                break;
            default:
                title = "";
                break;
        }
        return title;
    };
    me.getExceptionsUri = function () {
        var importQueueId =  me.getImportQueueId();
        var uri = privateStore[me.id].ExceptionsUri
        //if (importQueueId != null) {
        //    uri = uri + "?importQueueId=" + importQueueId
        //}
        return uri;
    };
    me.getAddFeatureContentUri = function () {
        return privateStore[me.id].AddFeatureContentUri;
    };
    me.getAddFeatureActionUri = function () {
        return privateStore[me.id].AddFeatureActionUri;
    };
    me.getAddSpecialFeatureContentUri = function () {
        return privateStore[me.id].AddSpecialFeatureContentUri;
    };
    me.getAddSpecialFeatureActionUri = function () {
        return privateStore[me.id].AddSpecialFeatureActionUri;
    };
    me.getMapFeatureContentUri = function () {
        return privateStore[me.id].MapFeatureContentUri;
    };
    me.getMapFeatureActionUri = function () {
        return privateStore[me.id].MapFeatureContentUri;
    };
    me.getAddDerivativeContentUri = function () {
        return privateStore[me.id].AddDerivativeContentUri;
    };
    me.getAddDerivativeActionUri = function () {
        return privateStore[me.id].AddDerivativeActionUri;
    };
    me.getMapDerivativeContentUri = function () {
        return privateStore[me.id].MapDerivativeContentUri;
    };
    me.getMapDerivativeActionUri = function () {
        return privateStore[me.id].MapDerivativeActionUri;
    };
    me.getMapMarketContentUri = function () {
        return privateStore[me.id].MapMarketContentUri;
    };
    me.getMapMarketActionUri = function () {
        return privateStore[me.id].MapMarketActionUri;
    };
    me.getAddTrimContentUri = function () {
        return privateStore[me.id].AddTrimContentUri;
    };
    me.getAddTrimActionUri = function () {
        return privateStore[me.id].AddTrimActionUri;
    };
    me.getMapTrimContentUri = function () {
        return privateStore[me.id].MapTrimContentUri;
    };
    me.getMapTrimActionUri = function () {
        return privateStore[me.id].MapTrimActionUri;
    };
    me.getIgnoreContentUri = function () {
        return privateStore[me.id].IgnoreContentUri;
    };
    me.getIgnoreActionUri = function () {
        return privateStore[me.id].IgnoreActionUri;
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

