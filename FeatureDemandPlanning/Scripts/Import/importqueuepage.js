"use strict";

var page = namespace("FeatureDemandPlanning.Import");

page.ImportQueuePage = function (models) {
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
        settings.jqXHR = $.ajax({
            "dataType": "json",
            "type": "POST",
            "url": uri,
            "data": params,
            "success": function (json) {
                callback(json);
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
    me.configureDataTables = function () {

        var exceptionsUri = getExceptionsModel().getExceptionsUri();
        var importQueueIndex = 5;

        $("#tblImportQueue").DataTable({
            "serverSide": true,
            "pagingType": "full_numbers",
            "ajax": me.getData,
            "processing": true,
            "sDom": "ltip",
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
                    "sTitle": "Vehicle",
                    "sName": "VEHICLE_DESCRIPTION",
                    "bSearchable": true,
                    "bSortable": true
                }
                ,{
                    "sTitle": "File Path",
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
                    "sTitle": "Errors",
                    "sName": "ERRORS",
                    "bSearchable": false,
                    "bSortable": false,
                    "sClass": "text-center",
                    "render": function (data, type, full, meta) {
                        var uri = exceptionsUri + "?importQueueId=" + full[importQueueIndex];
                        return "<a href='" + uri + "'>View</a>";
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