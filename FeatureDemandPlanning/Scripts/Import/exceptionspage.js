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
    me.getData = function (sSource, aoData, fnCallback, oSettings) {
        oSettings.jqXHR = $.ajax({
            "dataType": "json",
            "type": "POST",
            "url": getExceptionsModel().getExceptionsUri(),
            "data": aoData,
            "success": fnCallback
        });
    };
    me.getParameters = function (aoData) {
        var filter = getFilter();
        aoData.push({
            "name": "ImportQueueId",
            "value": filter.ImportQueueId
        });
        aoData.push({
            "name": "ExceptionType",
            "value": filter.ExceptionType
        });
        aoData.push({
            "name": "FilterMessage",
            "value": filter.FilterMessage
        });
    };
    me.configureDataTables = function (filter) {
        var tblImportExceptions = $("#tblImportExceptions");
        
        var dt = tblImportExceptions.dataTable({
            "bServerSide": true,
            "fnServerData": me.getData,
            "fnServerParams": me.getParameters,
            "bProcessing": false,
            "iDisplayLength": filter.PageSize,
            "sDom": "ltip",
            "aoColumns": [
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
                },
                {
                    "sName": "ACTION",
                    "bSearchable": false,
                    "bSortable": false
                }
            ],
            "fnCreatedRow": function (row, data, index) {
                var importExceptionId = data[0];
                $(row).attr("data-import-exception-id", importExceptionId);
            },
            "fnDrawCallback": me.onResultsEventHandler
        });
        me.setDataTable(dt);
        return dt;
    }
    me.registerEvents = function () {
        $(document)
            .unbind("Success").on("Success", function (sender, eventArgs) { $(".subscribers-notifySuccess").trigger("OnSuccessDelegate", [eventArgs]); })
            .unbind("Error").on("Error", function (sender, eventArgs) { $(".subscribers-notifyError").trigger("OnErrorDelegate", [eventArgs]); })
            .unbind("Results").on("Results", function (sender, eventArgs) { $(".subscribers-notifyResults").trigger("OnResultsDelegate", [eventArgs]); })
            .unbind("Updated").on("Updated", function (sender, eventArgs) { $(".subscribers-notifyUpdated").trigger("OnUpdatedDelegate", [eventArgs]); })
    };
    me.registerSubscribers = function () {
        $("#notifier")
            .unbind("OnSuccessDelegate").on("OnSuccessDelegate", me.onSuccessEventHandler)
            .unbind("OnErrorDelegate").on("OnErrorDelegate", me.onErrorEventHandler)
            .unbind("OnUpdatedDelegate").on("OnUpdatedDelegate", me.onUpdatedEventHandler)
            .unbind("OnResultsDelegate").on("OnResultsDelegate", me.onResultsEventHandler)
            .unbind("OnFilterCompleteDelegate").on("OnFilterCompleteDelegate", me.onFilterCompleteEventHandler);

        $("#tblImportExceptions td").contextMenu({
            menuSelector: "#tblImportExceptionsContextMenu",
            menuSelected: function (invokedOn, selectedMenu) {
                var msg = "You selected the menu item '" + selectedMenu.text() +
                    "' on the value '" + invokedOn.text() + "'";
                alert(msg);
            }
        });
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
    me.onResultsEventHandler = function (oSettings) {
        alert("updating summary");
    };
    me.onFilterChangedEventHandler = function (sender, eventArgs) {
        me.getDataTable().fnDraw();
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