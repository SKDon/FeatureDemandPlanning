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
        privateStore[me.id].DataTable = dataTable
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
            "async": false,
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
            "FilterMessage": filter.FilterMessage
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
            }
        });
        //me.setDataTable(dt);
        //return dt;
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
    me.actionTriggered = function (invokedOn, action) {
        var eventArgs = {
            ExceptionId: parseInt($(action).attr("data-target")),
            ActionId: parseInt($(action).attr("data-action"))
        };
        $(document).trigger("Action", eventArgs);
    }
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
            .unbind("Success").on("Success", function (sender, eventArgs) { $(".subscribers-notifySuccess").trigger("OnSuccessDelegate", [eventArgs]); })
            .unbind("Error").on("Error", function (sender, eventArgs) { $(".subscribers-notifyError").trigger("OnErrorDelegate", [eventArgs]); })
            .unbind("Results").on("Results", function (sender, eventArgs) { $(".subscribers-notifyResults").trigger("OnResultsDelegate", [eventArgs]); })
            .unbind("Updated").on("Updated", function (sender, eventArgs) { $(".subscribers-notifyUpdated").trigger("OnUpdatedDelegate", [eventArgs]); })
            .unbind("Action").on("Action", function (sender, eventArgs) { $(".subscribers-notifyAction").trigger("OnActionDelegate", [eventArgs]); })
    };
    me.registerSubscribers = function () {
        $("#notifier")
            .unbind("OnSuccessDelegate").on("OnSuccessDelegate", me.onSuccessEventHandler)
            .unbind("OnErrorDelegate").on("OnErrorDelegate", me.onErrorEventHandler)
            .unbind("OnUpdatedDelegate").on("OnUpdatedDelegate", me.onUpdatedEventHandler)
            .unbind("OnFilterCompleteDelegate").on("OnFilterCompleteDelegate", me.onFilterCompleteEventHandler)
            .unbind("OnActionDelegate").on("OnActionDelegate", me.onActionEventHandler);

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
    me.onActionEventHandler = function (sender, eventArgs) {
        var model = getExceptionsModel();
        getModal().showModal({
            title: model.getActionTitle(eventArgs),
            uri: model.getActionContentUri(eventArgs),
            data: JSON.stringify(eventArgs),
            model: model
        });
    };
    me.onActionCallback = function (response) {
        
        me.redrawDataTable();
    };
    me.redrawDataTable = function () {
        $("#tblImportExceptions").DataTable().draw();
    }
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
    function getFilter() {
        var model = getExceptionsModel();
        var pageSize = model.getPageSize();
        var pageIndex = model.getPageIndex();
        var filter = new FeatureDemandPlanning.Import.ExceptionsFilter();

        filter.ImportQueueId = model.getImportQueueId();
        filter.ExceptionType = me.getExceptionType();
        filter.FilterMessage = me.getFilterMessage()
        filter.PageIndex = pageIndex;
        filter.PageSize = pageSize;

        return filter;
    }
}