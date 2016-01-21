"use strict";

var page = namespace("FeatureDemandPlanning.Import");

page.ImportQueuePage = function (models) {
    var uid = 0;
    var privateStore = {};
    var me = this;

    privateStore[me.id = uid++] = {};
    privateStore[me.id].DataTable = null;
    privateStore[me.id].Models = models;
    privateStore[me.id].Timer = null;
    privateStore[me.id].SelectedImportStatus = "";
    privateStore[me.id].SelectedImportStatusId = 0;

    me.displaySelectedImportStatus = function () {
        $("#" + me.getIdentifierPrefix() + "_SelectedImportStatus").html(me.getSelectedImportStatus());
    };
    me.getSelectedImportStatus = function () {
        return privateStore[me.id].SelectedImportStatus;
    };
    me.getSelectedImportStatusId = function () {
        return privateStore[me.id].SelectedImportStatusId;
    };
    me.importStatusSelectedEventHandler = function (sender) {
        me.setSelectedImportStatusId(parseInt($(sender.target).attr("data-target")));
        me.setSelectedImportStatus($(sender.target).attr("data-content"));
        me.displaySelectedImportStatus();
        me.redrawDataTable();
    };
    me.setSelectedImportStatus = function (importStatus) {
        privateStore[me.id].SelectedImportStatus = importStatus;
    };
    me.setSelectedImportStatusId = function (importStatusId) {
        privateStore[me.id].SelectedImportStatusId = importStatusId;
    };
    me.cancelTimer = function () {
        var timer = me.getTimer();
        if (timer != null) {
            clearTimeout(timer);
            timer = null;
        }
    };
    me.getTimer = function () {
        return privateStore[me.id].Timer;
    };
    me.setTimer = function (timer) {
        privateStore[me.id].Timer = timer;
    };
    me.initialise = function () {
        me.registerEvents();
        me.registerSubscribers();

        $(privateStore[me.id].Models).each(function () {
            this.initialise();
        });
        me.loadData();
    };
    me.getIdentifierPrefix = function () {
        return $("#Page_IdentifierPrefix").val();
    };
    me.setDataTable = function (dataTable) {
        privateStore[me.id].DataTable = dataTable
    };
    me.getDataTable = function () {
        if (privateStore[me.id].DataTable == null) {
            me.configureDataTables();
        }
        return privateStore[me.id].DataTable;
    };
    me.loadData = function () {
        me.configureDataTables(getFilter());
    };
    me.getData = function (data, callback, settings) {
        var params = me.getParameters(data);
        var model = getImportQueueModel();
        var uri = model.getImportQueueUri();
        
        me.cancelTimer();

        settings.jqXHR = $.ajax({
            "dataType": "json",
            "type": "POST",
            "url": uri,
            "data": params,
            "success": function (json) {
                callback(json);
                me.updatePaging();
                me.updateTotals();
                me.setTimer(setTimeout(function () {
                   me.redrawDataTable();
                }, 10000));
            }
        });
    };
    me.getFilterMessage = function () {
        return $("#" + me.getIdentifierPrefix() + "_FilterMessage").val();
    };
    me.getParameters = function (data) {
        var filter = getFilter();
        var params = $.extend({}, data, {
            "ImportQueueId": filter.ImportQueueId,
            "ImportStatusId": me.getSelectedImportStatusId(),
            "FilterMessage": me.getFilterMessage()
        });
        return params;
    };
    me.configureDataTables = function () {

        var exceptionsUri = getExceptionsModel().getExceptionsUri();
        var importQueueIndex = 5;
        var hasErrorsIndex = 6;
        var errorCountIndex = 7;

        $(".dataTable").DataTable({
            "serverSide": true,
            "responsive": true,
            "pagingType": "full_numbers",
            "ajax": me.getData,
            "processing": true,
            "dom": "ltp",
            "order": [["0", "desc"]],
            "aoColumns": [
                {
                    "sTitle": "Uploaded On",
                    "sName": "UPLOADED_ON",
                    "bSearchable": true,
                    "bSortable": true,
                    "sClass": "text-center"
                }
                ,{
                    "sTitle": "Uploaded By",
                    "sName": "UPLOADED_BY",
                    "bSearchable": true,
                    "bSortable": true
                }
                ,{
                    "sTitle": "Vehicle / OXO Document Version",
                    "sName": "VEHICLE_DESCRIPTION",
                    "bSearchable": true,
                    "bSortable": true
                }
                ,{
                    "sTitle": "File Name",
                    "sName": "FILE_PATH",
                    "bSearchable": true,
                    "bSortable": true
                }
                ,{
                    "sTitle": "Status",
                    "sName": "STATUS",
                    "bSearchable": true,
                    "bSortable": true,
                    "sClass": "text-center",
                }
                ,{
                    "sTitle": "Data Errors",
                    "sName": "ERRORS",
                    "bSearchable": false,
                    "bSortable": false,
                    "sClass": "text-center",
                    "render": function (data, type, full, meta) {
                        var hasErrors = full[hasErrorsIndex];
                        var errorCount = parseInt(full[errorCountIndex]);
                        if (hasErrors == "NO") {
                            return "-";
                        }
                        var uri = exceptionsUri + "?importQueueId=" + full[importQueueIndex];
                        return "<a href='" + uri + "'>" + errorCount + " Errors</a>";
                    }
                }
            ],
            "fnCreatedRow": function (row, data, index) {
                // Don't like hard-coding indexes in this way. Must be a better way
                var importQueueId = data[0];

                $(row).attr("data-importQueueId", importQueueId);
            },
            "fnDrawCallback": function (oSettings) {
                //$(document).trigger("Results", me.getSummary());
                //me.bindContextMenu();
            }
        });

        //me.setDataTable(dt);
    }
    me.registerEvents = function () {
        var prefix = me.getIdentifierPrefix();
        $(document)
            .unbind("Success").on("Success", function (sender, eventArgs) { $(".subscribers-notify").trigger("OnSuccessDelegate", [eventArgs]); })
            .unbind("Error").on("Error", function (sender, eventArgs) { $(".subscribers-notify").trigger("OnErrorDelegate", [eventArgs]); })
            .unbind("Results").on("Results", function (sender, eventArgs) { $(".subscribers-notify").trigger("OnResultsDelegate", [eventArgs]); })
            .unbind("Updated").on("Updated", function (sender, eventArgs) { $(".subscribers-notify").trigger("OnUpdatedDelegate", [eventArgs]); })
            .unbind("Action").on("Action", function (sender, eventArgs) { $(".subscribers-notify").trigger("OnActionDelegate", [eventArgs]); })
            .unbind("ModalLoaded").on("ModalLoaded", function (sender, eventArgs) { $(".subscribers-notify").trigger("OnModalLoadedDelegate", [eventArgs]); })
            .unbind("ModalOk").on("ModalOk", function (sender, eventArgs) { $(".subscribers-notify").trigger("OnModalOkDelegate", [eventArgs]); })

        $("#" + prefix + "_UploadButton").on("click", function (e) {
            var eventArgs = {
                Action: parseInt($(this).attr("data-role")),
            };
            $(document).trigger("Action", eventArgs);
        });

        $("#" + prefix + "_ImportStatusList").find("a.status-item").on("click", function (e) {
            me.importStatusSelectedEventHandler(e);
            e.preventDefault();
        });
    };
    me.registerSubscribers = function () {
        var prefix = me.getIdentifierPrefix();
        $("#notifier")
            .unbind("OnSuccessDelegate").on("OnSuccessDelegate", me.onSuccessEventHandler)
            .unbind("OnErrorDelegate").on("OnErrorDelegate", me.onErrorEventHandler)
            //.unbind("OnUpdatedDelegate").on("OnUpdatedDelegate", me.onUpdatedEventHandler)
            //.unbind("OnFilterCompleteDelegate").on("OnFilterCompleteDelegate", me.onFilterCompleteEventHandler)
            .unbind("OnActionDelegate").on("OnActionDelegate", me.onActionEventHandler)
            //.unbind("OnModalLoadedDelegate").on("OnModalLoadedDelegate", me.onModalLoadedEventHandler)
            //.unbind("OnModalOkDelegate").on("OnModalOkDelegate", me.onModalOKEventHandler);

        $("#" + prefix + "_FilterMessage").on("keyup", me.onFilterChangedEventHandler);
    };
    me.loadImportQueue = function (pageSize, pageIndex) {
        var filter = getFilter(pageSize, pageIndex);
        $(document).trigger("notifyFilterComplete", filter)
    };
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
    me.onErrorEventHandler = function(sender, eventArgs) {

    };
    me.onFilterChangedEventHandler = function (sender, eventArgs) {
        var filter = $("#" + me.getIdentifierPrefix() + "_FilterMessage").val();
        var filterLength = filter.length;
        if (filterLength === 0 || filterLength > 2) {
            me.redrawDataTable();
        }
    };
    me.onSuccessEventHandler = function (sender, eventArgs) {
        me.redrawDataTable();
    };
    me.redrawDataTable = function () {
        $(".dataTable").DataTable().draw();
    };
    me.updatePaging = function () {
        var info = $(".dataTable").DataTable().page.info();
        var prefix = me.getIdentifierPrefix();
        var pageIndex = info.page + 1;
        var totalPages = info.pages;
        var total = info.recordsTotal;
        $(".results-paging").html("Page " + pageIndex + " of " + totalPages);
    };
    me.updateTotals = function () {
        var info = $(".dataTable").DataTable().page.info();
        var prefix = me.getIdentifierPrefix();
        var total = info.recordsTotal;
        $(".results-total").html(total + " Import Items");
    }
    function getModal() {
        return getModel("Modal");
    };
    function getModelForAction(actionId) {
        var model = null;
        switch (actionId) {
            case 100:
                model = getUploadModel();
                break;
            default:
                break;
        }
        return model;
    }
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
    function getImportQueueModel() {
        return getModel("ImportQueue");
    };
    function getExceptionsModel() {
        return getModel("Exceptions");
    };
    function getUploadModel() {
        return getModel("Upload");
    };
    function getFilter(pageSize, pageIndex) {
        var model = getImportQueueModel();
        var filter = {
            PageIndex: pageIndex,
            PageSize: pageSize
        };

        return filter;
    }
}