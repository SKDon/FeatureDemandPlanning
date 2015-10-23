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
    privateStore[me.id].AddTrimContentUri = params.AddTrimContentUri;
    privateStore[me.id].AddTrimActionUri = params.AddTrimActionUri;
    privateStore[me.id].MapTrimContentUri = params.MapTrimContentUri;
    privateStore[me.id].IgnoreContentUri = params.IgnoreContentUri;
    privateStore[me.id].IgnoreActionUri = params.IgnoreActionUri;
    privateStore[me.id].ImportQueueId = params.ImportQueueId;
    privateStore[me.id].ProgrammeId = params.ProgrammeId;
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
            case 6:
                uri = me.getAddTrimContentUri();
                break;
            case 7:
                uri = me.getMapTrimContentUri();
                break;
            case 8:
                uri = me.getIgnoreContentUri();
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
            case 6:
                uri = me.getAddTrimActionUri();
                break;
            case 7:
                uri = me.getMapTrimActionUri();
                break;
            case 8:
                uri = me.getIgnoreActionUri();
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
            case 6:
                title = "Add New Trim";
                break;
            case 7:
                title = "Map Trim to OXO";
                break;
            case 8:
                title = "Ignore Error";
                break;
            default:
                title = "";
                break;
        }
        return title;
    };
    me.getExceptionsUri = function () {
        return privateStore[me.id].ExceptionsUri;
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
    me.getProgrammeId = function () {
        return privateStore[me.id].ProgrammeId;
    }
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

