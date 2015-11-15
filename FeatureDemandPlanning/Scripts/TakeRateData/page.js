"use strict";

var page = namespace("FeatureDemandPlanning.TakeRate");

page.TakeRateDataPage = function (models) {
    var uid = 0, privateStore = {}, me = this;

    privateStore[me.id = uid++] = {};
    privateStore[me.id].DataTable = null;
    privateStore[me.id].Models = models;

    me.actionTriggered = function () {
        var eventArgs = {
            CDSId: $(this).attr("data-target"),
            Action: parseInt($(this).attr("data-role"))
        };
        $(document).trigger("Action", eventArgs);
    }
    me.bindContextMenu = function () {
        $("#" + me.getIdentifierPrefix() + "_TakeRateData td").contextMenu({
            menuSelector: "#contextMenu",
            dynamicContent: me.getContextMenu,
            contentIdentifier: me.getFeatureId,
            menuSelected: me.actionTriggered
        });
    };
    me.configureDataTables = function () {
        var prefix = me.getIdentifierPrefix();
        $("#" + prefix + "_TakeRateData").DataTable({
            "serverSide": true,
            "pagingType": "full_numbers",
            "ajax": me.getData,
            "processing": true,
            "sDom": "ltip",
            "aoColumns": [
                {
                    "sTitle": "",
                    "sName": "USER_ID",
                    "bSearchable": false,
                    "bSortable": false,
                    "bVisible": false
                }
                , {
                    "sTitle": "Username",
                    "sName": "USERNAME",
                    "bSearchable": true,
                    "bSortable": true,
                    "sClass": "text-center"
                }
                , {
                    "sTitle": "Full Name",
                    "sName": "FULL_NAME",
                    "bSearchable": true,
                    "bSortable": true
                }
                , {
                    "sTitle": "Programmes",
                    "sName": "PROGRAMMES",
                    "bSearchable": true,
                    "bSortable": true
                }
                , {
                    "sTitle": "Active?",
                    "sName": "IS_ACTIVE",
                    "bSearchable": true,
                    "bSortable": true,
                    "sClass": "text-center",
                    "render": function (data, type, full) {
                        var index = 4;
                        var iconClassName = full[index] === "YES" ? "glyphicon glyphicon-ok" : "glyphicon glyphicon-remove";
                        return "<span class=\"" + iconClassName + "\"></span>";
                    }
                }
                , {
                    "sTitle": "Admin?",
                    "sName": "IS_ADMIN",
                    "bSearchable": true,
                    "bSortable": true,
                    "sClass": "text-center",
                    "render": function (data, type, full) {
                        var index = 5;
                        var iconClassName = full[index] === "YES" ? "glyphicon glyphicon-ok" : "glyphicon glyphicon-remove";
                        return "<span class=\"" + iconClassName + "\"></span>";
                    }
                }
            ],
            "fnCreatedRow": function (row, data) {
                var cdsId = data[1];
                $(row).attr("data-target", cdsId);
            },
            "fnDrawCallback": function () {
                //$(document).trigger("Results", me.getSummary());
                me.bindContextMenu();
            }
        });
    };
    me.getContextMenu = function (cdsId) {
        var params = { CDSId: cdsId };
        $("#contextMenu").html("");
        $.ajax({
            "dataType": "html",
            "async": true,
            "type": "POST",
            "url": getTakeRateModel().getActionsUri(),
            "data": params,
            "success": function (response) {
                $("#contextMenu").html(response);
            }
        });
    };
    me.getData = function (data, callback, settings) {
        var params = me.getParameters(data);
        var model = getTakeRateModel();
        var uri = model.getVolumeDataUri();
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
    me.getDataTable = function () {
        if (privateStore[me.id].DataTable == null) {
            me.configureDataTables();
        }
        return privateStore[me.id].DataTable;
    };
    me.getFilterMessage = function () {
        return $("#" + me.getIdentifierPrefix() + "_FilterMessage").val();
    };
    me.getIdentifierPrefix = function () {
        return $("#Page_IdentifierPrefix").val();
    };
    me.getParameters = function (data) {
        var params = $.extend({}, data, {
            "FilterMessage": me.getFilterMessage()
        });
        return params;
    };
    me.initialise = function () {
        me.registerEvents();
        me.registerSubscribers();
        $(privateStore[me.id].Models).each(function () {
            this.initialise();
        });
        me.loadData();
    };
    me.loadData = function() {
        me.configureDataTables(getFilter());
    };
    me.onActionEventHandler = function (sender, eventArgs) {
        var action = eventArgs.Action;
        var model = getModelForAction(action);
        var actionModel = model.getActionModel(action);

        if (actionModel.isModalAction()) {
            getModal().showModal({
                Title: model.getActionTitle(action, eventArgs.CDSId),
                Uri: model.getActionContentUri(action),
                Data: JSON.stringify(eventArgs),
                Model: model,
                ActionModel: actionModel
            });
        }
        else {
            actionModel.actionImmediate(eventArgs);
        }
    };
    me.onFilterChangedEventHandler = function () {
        var filter = $("#" + me.getIdentifierPrefix() + "_FilterMessage").val();
        var filterLength = filter.length;
        if (filterLength === 0 || filterLength > 2) {
            me.redrawDataTable();
        }
    };
    me.onSuccessEventHandler = function () {
        me.redrawDataTable();
    };
    me.redrawDataTable = function () {
        $("#" + me.getIdentifierPrefix() + "_TakeRateData").DataTable().draw();
    };
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

        $("#" + prefix + "_AddUserButton").on("click", function (e) {
            var eventArgs = {
                Action: parseInt($(this).attr("data-role")),
            };
            $(document).trigger("Action", eventArgs);
        });
    };
    me.registerSubscribers = function () {
        var prefix = me.getIdentifierPrefix();
        $("#notifier")
            .unbind("OnSuccessDelegate").on("OnSuccessDelegate", me.onSuccessEventHandler)
            .unbind("OnErrorDelegate").on("OnErrorDelegate", me.onErrorEventHandler)
            .unbind("OnUpdatedDelegate").on("OnUpdatedDelegate", me.onUpdatedEventHandler)
            .unbind("OnFilterCompleteDelegate").on("OnFilterCompleteDelegate", me.onFilterCompleteEventHandler)
            .unbind("OnActionDelegate").on("OnActionDelegate", me.onActionEventHandler)
            .unbind("OnModalLoadedDelegate").on("OnModalLoadedDelegate", me.onModalLoadedEventHandler)
            .unbind("OnModalOkDelegate").on("OnModalOkDelegate", me.onModalOKEventHandler);

        $("#" + prefix + "_FilterMessage").on("keyup", me.onFilterChangedEventHandler);
    };
    me.onFilterChangedEventHandler = function () {
        var filter = $("#" + me.getIdentifierPrefix() + "_FilterMessage").val();
        var filterLength = filter.length;
        if (filterLength === 0 || filterLength > 2) {
            me.redrawDataTable();
        }
    };
    me.onSuccessEventHandler = function () {
        me.redrawDataTable();
    };
    me.setDataTable = function (dataTable) {
        privateStore[me.id].DataTable = dataTable;
    };
    function getFilter() {
        var model = getTakeRateModel();
        var pageSize = model.getPageSize();
        var pageIndex = model.getPageIndex();
        var filter = new FeatureDemandPlanning.TakeRate.TakeRateDataFilter();

        filter.PageIndex = pageIndex;
        filter.PageSize = pageSize;

        return filter;
    }
    function getModal() {
        return getModel("Modal");
    };
    function getModelForAction() {
        return getTakeRateModel();
    };
    function getModel(modelName) {
        var model = null;
        $(getModels()).each(function () {
            if (this.ModelName === modelName) {
                model = this;
                return false;
            }
        });
        return model;
    };
    function getModels() {
        return privateStore[me.id].Models;
    };
    function getTakeRateModel() {
        return getModel("TakeRateData");
    };
};