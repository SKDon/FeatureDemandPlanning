"use strict";

var page = namespace("FeatureDemandPlanning.Import");

page.ExceptionsPage = function (models) {
    var uid = 0;
    var privateStore = {};
    var me = this;

    privateStore[me.id = uid++] = {};
    privateStore[me.id].DataTable = null;
    privateStore[me.id].Models = models;

    me.initialise = function () {
        me.registerEvents();
        me.registerSubscribers();

        $(privateStore[me.id].Models).each(function () {
            this.initialise();
        });
        me.loadData();
    };
    me.setDataTable = function (dataTable) {
        privateStore[me.id].DataTable = dataTable;
    };
    me.getDataTable = function () {
        if (privateStore[me.id].DataTable == null)
        {
            me.configureDataTables();
        }
        return privateStore[me.id].DataTable;
    };
    me.getExceptionType = function () {
        return parseInt($("#ddlExceptionType").val());
    };
    me.getFilterMessage = function () {
        return $("#txtFilterMessage").val();
    };
    me.loadData = function () {
        me.configureDataTables(getFilter());
    };
    me.getData = function (data, callback, settings) {
        var params = me.getParameters(data);
        var model = getExceptionsModel();
        var uri = model.getExceptionsUri();
        settings.jqXHR = $.ajax({
            "dataType": "json",
            "type": "POST",
            "url": uri,
            "data": params,
            "success": function (json) {
                // Additional data not provided by the regular datatables implementation
                model.setTotalSuccessRecords(json.TotalSuccess);
                model.setTotalFailRecords(json.TotalFail);
                callback(json);
            }
        });
    };
    me.getContextMenu = function (exceptionId) {
        var params = { ExceptionId: exceptionId };
        $.ajax({
            "dataType": "html",
            "async": true,
            "type": "POST",
            "url": getExceptionsModel().getActionsUri(),
            "data": params,
            "success": function (response) {
                $("#contextMenu").html(response);
            }
        });
    };
    me.getParameters = function (data) {
        var filter = getFilter();
        var params = $.extend({}, data, {
            "ImportQueueId": filter.ImportQueueId,
            "ExceptionType": filter.ExceptionType,
            "FilterMessage": filter.FilterMessage,
            "ProgrammeId": filter.ProgrammeId
        });
        return params;
    };
    me.configureDataTables = function (filter) {
        $("#tblImportExceptions").DataTable({
            "serverSide": true,
            "pagingType": "full_numbers",
            "processing": true,
            "ajax": me.getData,
            "sDom": "ltip",
            "aoColumns": [
                {
                    "sName": "IMPORT_EXCEPTION_ID",
                    "bVisible": false
                },
                {
                    "sName": "LINE_NUMBER",
                    "bSearchable": true,
                    "bSortable": false,
                    "sClass": "text-right"
                }
                ,
                {
                    "sName": "ERROR_TYPE_DESCRIPTION",
                    "bSearchable": true,
                    "bSortable": true
                },
                {
                    "sName": "ERROR_MESSAGE",
                    "bSearchable": true,
                    "bSortable": true
                },
                {
                    "sName": "ERROR_ON",
                    "bSearchable": false,
                    "bSortable": true,
                    "sClass": "text-center"
                }
            ],
            "fnCreatedRow": function (row, data, index) {
                var importExceptionId = data[0];
                $(row).attr("data-import-exception-id", importExceptionId);
            },
            "fnDrawCallback": function (oSettings) {
                $(document).trigger("Results", me.getSummary());
                me.bindContextMenu();
                $("#pnlImportExceptions").show();
            }
        });
    };
    me.getExceptionId = function (cell) {
        return $(cell).closest("tr").attr("data-import-exception-id");
    };
    me.bindContextMenu = function () {
        $("#tblImportExceptions td").contextMenu({
            menuSelector: "#contextMenu",
            dynamicContent: me.getContextMenu,
            contentIdentifier: me.getExceptionId,
            menuSelected: me.actionTriggered
        });
    };
    me.getSummary = function () {
        var table = $("#tblImportExceptions").DataTable();
        var info = table.page.info();
        var model = getExceptionsModel();
        
        model.setTotalRecords(info.recordsTotal);
        model.setTotalDisplayRecords(info.recordsDisplay);
        model.setPageIndex(info.page);
        model.setPageSize(info.length);
        model.setTotalPages(info.pages);

        return model;
    };
    me.registerEvents = function () {
        $(document)
            .unbind("Success").on("Success", function (sender, eventArgs) { $(".subscribers-notify").trigger("OnSuccessDelegate", [eventArgs]); })
            .unbind("Error").on("Error", function (sender, eventArgs) { $(".subscribers-notify").trigger("OnErrorDelegate", [eventArgs]); })
            .unbind("Results").on("Results", function (sender, eventArgs) { $(".subscribers-notify").trigger("OnResultsDelegate", [eventArgs]); })
            .unbind("Updated").on("Updated", function (sender, eventArgs) { $(".subscribers-notify").trigger("OnUpdatedDelegate", [eventArgs]); })
            .unbind("Action").on("Action", function (sender, eventArgs) { $(".subscribers-notify").trigger("OnActionDelegate", [eventArgs]); })
            .unbind("ModalLoaded").on("ModalLoaded", function (sender, eventArgs) { $(".subscribers-notify").trigger("OnModalLoadedDelegate", [eventArgs]); })
            .unbind("ModalOk").on("ModalOk", function (sender, eventArgs) { $(".subscribers-notify").trigger("OnModalOkDelegate", [eventArgs]); })
    };
    me.registerSubscribers = function () {
        $("#notifier")
            .unbind("OnSuccessDelegate").on("OnSuccessDelegate", me.onSuccessEventHandler)
            .unbind("OnErrorDelegate").on("OnErrorDelegate", me.onErrorEventHandler)
            .unbind("OnUpdatedDelegate").on("OnUpdatedDelegate", me.onUpdatedEventHandler)
            .unbind("OnFilterCompleteDelegate").on("OnFilterCompleteDelegate", me.onFilterCompleteEventHandler)
            .unbind("OnActionDelegate").on("OnActionDelegate", me.onActionEventHandler)
            .unbind("OnModalLoadedDelegate").on("OnModalLoadedDelegate", me.onModalLoadedEventHandler)
            .unbind("OnModalOkDelegate").on("OnModalOkDelegate", me.onModalOKEventHandler)

        $("#dvImportSummary").on("OnResultsDelegate", me.onImportSummaryEventHandler);
        $("#spnFilteredRecords").on("OnResultsDelegate", me.onFilteredRecordsEventHandler);
        $("#dvFilter").on("FilterCompleteEventHandler", me.onFilterCompleteEventHandler);
        $("#ddlExceptionType").on("change", me.onFilterChangedEventHandler);
        $("#txtFilterMessage").on("keyup", function (sender, eventArgs) {
            var length = $("#txtFilterMessage").val().length;
            if (length == 0 || length > 2) {
                me.onFilterChangedEventHandler(sender, eventArgs);
            }
        });
    };
    me.onSuccessEventHandler = function (sender, eventArgs) {
    };
    me.onErrorEventHandler = function (sender, eventArgs) {
    };
    me.onUpdatedEventHandler = function (sender, eventArgs) {
    };
    me.onResultsEventHandler = function (sender, eventArgs) {
    };
    me.onImportSummaryEventHandler = function (sender, eventArgs) {
        var summary = eventArgs;
        $("#spnLinesFailed").html(summary.getTotalFailRecords());
        $("#spnLinesImported").html(summary.getTotalSuccessRecords());
        $("#spnTotalRows").html(summary.getTotalFailRecords() + summary.getTotalSuccessRecords());
    };
    me.onFilteredRecordsEventHandler = function (sender, eventArgs) {
        var summary = eventArgs;
        if (summary.getTotalRecords() > 0) {
            $("#spnFilteredRecords").html("Page " + (summary.getPageIndex() + 1) + " of " + summary.getTotalPages() + " (" + summary.getTotalRecords() + " total records)");
        }
    };
    me.onFilterChangedEventHandler = function (sender, eventArgs) {
        me.redrawDataTable();
    };
    me.actionTriggered = function (invokedOn, action) {
        var eventArgs = {
            ExceptionId: parseInt($(this).attr("data-target")),
            Action: parseInt($(this).attr("data-role")),
            ProgrammeId: getExceptionsModel().getProgrammeId()
        };
        $(document).trigger("Action", eventArgs);
    }
    me.onActionEventHandler = function (sender, eventArgs) {
        var action = eventArgs.Action;
        var model = getModelForAction(action);
        var actionModel = model.getActionModel(action);

        getModal().showModal({
            Title: model.getActionTitle(action),
            Uri: model.getActionContentUri(action),
            Data: JSON.stringify(eventArgs),
            Model: model,
            ActionModel: actionModel
        });
    };
    me.onActionCallback = function (response) {
        me.redrawDataTable();
    };
    me.onModalLoadedEventHandler = function (sender, eventArgs) {
        var actionId = eventArgs.Action;
        switch (actionId) {
            case 1: me.initialiseMapMarketModal();
                break;
            default:
                break;
        }
    };
    me.onModalOKEventHandler = function (parameters) {
        alert("Modal OK");
    };
    me.redrawDataTable = function () {
        $("#tblImportExceptions").DataTable().draw();
    };
    
    // TO DO move this to the market.js file
    me.initialiseMapMarketModal = function () {
        var selector = $("#txtMapMarketName").typeahead({
            source: getMarketModel().getAvailableMarkets(),
            minLength: 1,
            items: 10
        });
    };
    function getModal() {
        return getModel("Modal");
    };
    function getModels() {
        return privateStore[me.id].Models;
    };
    function getModel(modelName) {
        var model = null;
        $(getModels()).each(function () {
            if (this.ModelName == modelName) {
                model = this;
                return false;
            }
        });
        return model;
    };
    function getExceptionsModel() {
        return getModel("Exceptions");
    };
    function getMarketModel() {
        return getModel("Market");
    };
    function getDerivativeModel() {
        return getModel("Derivative");
    }
    function getTrimModel() {
        return getModel("Trim");
    }
    function getFeatureModel() {
        return getModel("Feature");
    }
    function getIgnoreModel() {
        return getModel("Ignore");
    }
    function getModelForAction(actionId) {
        var model = null;
        switch (actionId) {
            case 1:
                model = getMarketModel();
                break;
            case 2:
            case 3:
                model = getDerivativeModel();
                break;
            case 4:
            case 5:
                model = getFeatureModel();
                break;
            case 6:
            case 7:
                model = getTrimModel();
                break;
            case 8:
                model = getIgnoreModel();
                break;
            case 9:
                model = getFeatureModel();
            default:
                break;
        };
        return model;
    }
    function getFilter() {
        var model = getExceptionsModel();
        var pageSize = model.getPageSize();
        var pageIndex = model.getPageIndex();
        var filter = new FeatureDemandPlanning.Import.ExceptionsFilter();

        filter.ImportQueueId = model.getImportQueueId();
        filter.ExceptionType = me.getExceptionType();
        filter.FilterMessage = me.getFilterMessage();
        filter.PageIndex = pageIndex;
        filter.PageSize = pageSize;

        return filter;
    }
}