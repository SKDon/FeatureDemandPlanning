"use strict";

var page = namespace("FeatureDemandPlanning.MarketReview");

page.MarketReviewPage = function (models) {
    var uid = 0;
    var privateStore = {};
    var me = this;

    privateStore[me.id = uid++] = {};
    privateStore[me.id].DataTable = null;
    privateStore[me.id].Models = models;
    
    me.actionTriggered = function (invokedOn, action) {
        var eventArgs = {
            ForecastId: parseInt($(this).attr("data-target")),
            Action: parseInt($(this).attr("data-role"))
        };
        $(document).trigger("Action", eventArgs);
    };
    me.bindContextMenu = function () {
        $("#" + me.getIdentifierPrefix() + "_MarketReviewTable td").contextMenu({
            menuSelector: "#contextMenu",
            dynamicContent: me.getContextMenu,
            contentIdentifier: me.getTakeRateId,
            menuSelected: me.actionTriggered
        });
    };
    me.configureDataTables = function () {

        var takeRateUri = getMarketReviewModel().getTakeRateUri();
        var takeRateIndex = 0;
        var marketIndex = 1;

        $("#" + me.getIdentifierPrefix() + "_MarketReviewTable").DataTable({
            "serverSide": true,
            "pagingType": "full_numbers",
            "processing": true,
            "ajax": me.getData,
            "sDom": "ltp",
            "aoColumns": [
                {
                    "sName": "TAKE_RATE_ID",
                    "bVisible": false
                },
                {
                    "sName": "MARKET_ID",
                    "bVisible": false
                },
                {
                    "sName": "CREATED_ON",
                    "bSearchable": true,
                    "bSortable": false,
                    "sClass": "text-center",
                    "render": function (data, type, full) {
                        return "<a href='" + takeRateUri + "?TakeRateId=" + full[takeRateIndex] + "&MarketId=" + full[marketIndex] + "'>" + data + "</a>";
                    }
                }
                ,
                {
                    "sName": "CREATED_BY",
                    "bSearchable": true,
                    "bSortable": true,
                    "sClass": "text-center",
                    "render": function (data, type, full) {
                        return "<a href='" + takeRateUri + "?TakeRateId=" + full[takeRateIndex] + "&MarketId=" + full[marketIndex] + "'>" + data + "</a>";
                    }
                },
                {
                    "sName": "PROGRAMME",
                    "bSearchable": true,
                    "bSortable": true,
                    "render": function (data, type, full) {
                        return "<a href='" + takeRateUri + "?TakeRateId=" + full[takeRateIndex] + "&MarketId=" + full[marketIndex] + "'>" + data + "</a>";
                    }
                },
                {
                    "sName": "GATEWAY",
                    "bSearchable": true,
                    "bSortable": true,
                    "sClass": "text-center",
                    "render": function (data, type, full) {
                        return "<a href='" + takeRateUri + "?TakeRateId=" + full[takeRateIndex] + "&MarketId=" + full[marketIndex] + "'>" + data + "</a>";
                    }
                },
                {
                    "sName": "VERSION",
                    "bSearchable": true,
                    "bSortable": true,
                    "sClass": "text-center",
                    "render": function (data, type, full) {
                        return "<a href='" + takeRateUri + "?TakeRateId=" + full[takeRateIndex] + "&MarketId=" + full[marketIndex] + "'>" + data + "</a>";
                    }
                },
                {
                    "sName": "STATUS",
                    "bSearchable": true,
                    "bSortable": true,
                    "sClass": "text-center",
                    "render": function (data, type, full) {
                        return "<a href='" + takeRateUri + "?TakeRateId=" + full[takeRateIndex] + "&MarketId=" + full[marketIndex] + "'>" + data + "</a>";
                    }
                },
                {
                    "sName": "MARKET",
                    "bSearchable": true,
                    "bSortable": true,
                    "sClass": "text-center",
                    "render": function (data, type, full) {
                        return "<a href='" + takeRateUri + "?TakeRateId=" + full[takeRateIndex] + "&MarketId=" + full[marketIndex] + "'>" + data + "</a>";
                    }
                }
            ]
        });
    };
    me.getData = function (data, callback, settings) {
        var params = me.getParameters(data);
        var model = getMarketReviewModel();
        var uri = model.getMarketReviewsUri();
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
    me.getParameters = function (data) {
        var filter = getFilter();
        var params = $.extend({}, data, {
            "FilterMessage": me.getFilterMessage()
        });
        return params;
    };
    me.getTakeRateId = function () {
        return null;
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
    me.getSummary = function () {
        var table = $("#" + me.getIdentifierPrefix() + "_MarketReviewTable").DataTable();
        var info = table.page.info();
        var model = getMarketReviewModel();

        model.setTotalRecords(info.recordsTotal);
        model.setTotalDisplayRecords(info.recordsDisplay);
        model.setPageIndex(info.page);
        model.setPageSize(info.length);
        model.setTotalPages(info.pages);

        return model;
    };
    me.loadData = function () {
        me.configureDataTables(getFilter());
    };
    me.onSuccessEventHandler = function (sender, eventArgs) {
    };
    me.onErrorEventHandler = function (sender, eventArgs) {
    };
    me.onUpdatedEventHandler = function (sender, eventArgs) {
    };
    me.onResultsEventHandler = function (sender, eventArgs) {
    };
    me.onForecastSummaryEventHandler = function (sender, eventArgs) {
        var summary = eventArgs;
        $("#spnTotalRows").html(summary.getTotalRecords());
    };
    me.onFilteredRecordsEventHandler = function (sender, eventArgs) {
        var summary = eventArgs;
        if (summary.getTotalRecords() > 0) {
            $("#spnFilteredRecords").html("Page " + (summary.getPageIndex() + 1) + " of " + summary.getTotalPages() + " (" + summary.getTotalRecords() + " total records)");
        }
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
    me.onActionCallback = function (response) {
        me.redrawDataTable();
    };
    me.onFilterChangedEventHandler = function (sender, eventArgs) {
        var filter = $("#" + me.getIdentifierPrefix() + "_FilterMessage").val();
        var filterLength = filter.length;
        if (filterLength === 0 || filterLength > 2) {
            me.redrawDataTable();
        }
    };
    me.onModalLoadedEventHandler = function (sender, eventArgs) {
        var actionId = eventArgs.Action;
        switch (actionId) {
            default:
                break;
        }
    };
    me.registerEvents = function () {
        $(document)
            .unbind("Success").on("Success", function(sender, eventArgs) { $(".subscribers-notify").trigger("OnSuccessDelegate", [eventArgs]); })
            .unbind("Error").on("Error", function(sender, eventArgs) { $(".subscribers-notify").trigger("OnErrorDelegate", [eventArgs]); })
            .unbind("Results").on("Results", function(sender, eventArgs) { $(".subscribers-notify").trigger("OnResultsDelegate", [eventArgs]); })
            .unbind("Updated").on("Updated", function(sender, eventArgs) { $(".subscribers-notify").trigger("OnUpdatedDelegate", [eventArgs]); })
            .unbind("Action").on("Action", function(sender, eventArgs) { $(".subscribers-notify").trigger("OnActionDelegate", [eventArgs]); })
            .unbind("ModalLoaded").on("ModalLoaded", function(sender, eventArgs) { $(".subscribers-notify").trigger("OnModalLoadedDelegate", [eventArgs]); })
            .unbind("ModalOk").on("ModalOk", function(sender, eventArgs) { $(".subscribers-notify").trigger("OnModalOkDelegate", [eventArgs]); });
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
    me.redrawDataTable = function () {
        $("#" + me.getIdentifierPrefix() + "_MarketReviewTable").DataTable().draw();
    };
    me.setDataTable = function (dataTable) {
        privateStore[me.id].DataTable = dataTable;
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
    function getMarketReviewModel() {
        return getModel("MarketReview");
    };
    function getModelForAction(actionId) {
        return getMarketReviewModel();
    };
    function getFilter() {
        var model = getMarketReviewModel();
        var pageSize = model.getPageSize();
        var pageIndex = model.getPageIndex();
        var filter = new FeatureDemandPlanning.TakeRate.TakeRateFilter();

        filter.PageIndex = pageIndex;
        filter.PageSize = pageSize;

        return filter;
    };
}