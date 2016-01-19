"use strict";

var model = namespace("FeatureDemandPlanning.Import");

model.MapMarketAction = function (params) {
    var uid = 0;
    var privateStore = {};
    var me = this;

    privateStore[me.id = uid++] = {};
    privateStore[me.id].Config = params.Configuration;
    privateStore[me.id].ActionUri = params.ModalActionUri;
    privateStore[me.id].SelectedMarketId = null;
    privateStore[me.id].SelectedMarket = "";
    privateStore[me.id].SelectedMarketGroup = "";
    privateStore[me.id].Parameters = params;
    privateStore[me.id].IsNoGroup = false;

    me.action = function () {
        sendData(me.getActionUri(), me.getActionParameters());
    };
    me.displaySelectedMarket = function () {
        $("#" + me.getIdentifierPrefix() + "_SelectedMarket").html(me.getSelectedMarket());
    };
    me.displaySelectedMarketGroup = function () {
        var selectedMarketGroup = me.getSelectedMarketGroup();
        if (selectedMarketGroup === "") {
            if (!me.getIsNoGroup()) {
                $("#" + me.getIdentifierPrefix() + "_SelectedMarketGroup").html("Select Market Group");
            }
            else
            {
                $("#" + me.getIdentifierPrefix() + "_SelectedMarketGroup").html("No Group");
            }
        } else {
            $("#" + me.getIdentifierPrefix() + "_SelectedMarketGroup").html(me.getSelectedMarketGroup());
        }
    };
    me.filterMarkets = function () {
        var selectedMarket = $("#" + me.getIdentifierPrefix() + "_SelectedMarket");
        var marketList = $("#" + me.getIdentifierPrefix() + "_MarketList")
        var markets = marketList
            .find("a.market-item")
            .hide()
            .filter("[data-filter='" + me.getSelectedMarketGroup() + "']")
            .show();

        if (markets.length == 0) {
            me.setSelectedMarket("N/A");
            me.displaySelectedMarketGroup();
            selectedMarket.attr("disabled", "disabled");
        }
        else {
            me.setSelectedMarket("");
            me.displaySelectedMarketGroup();
            selectedMarket.removeAttr("disabled");
        }
    };
    me.getActionParameters = function () {
        return $.extend({}, getData(), {
            "MarketId": me.getSelectedMarketId(),
            "ImportMarket": me.getImportMarket(),
            "IsGlobalMapping": me.getIsGlobalMapping()
        });
    };
    me.getIdentifierPrefix = function () {
        return $("#Action_IdentifierPrefix").val();
    };
    me.getImportMarket = function () {
        return $("#" + me.getIdentifierPrefix() + "_ImportMarket").attr("data-target");
    };
    me.getIsNoGroup = function () {
        return privateStore[me.id].IsNoGroup;
    };
    me.getIsGlobalMapping = function () {
        return $("#" + me.getIdentifierPrefix() + "_CheckIsGlobalMapping").is(":checked");
    };
    me.getActionUri = function () {
        return privateStore[me.id].ActionUri;
    };
    me.getParameters = function () {
        return privateStore[me.id].Parameters;
    };
    me.getSelectedMarket = function () {
        return privateStore[me.id].SelectedMarket;
    };
    me.getSelectedMarketGroup = function () {
        return privateStore[me.id].SelectedMarketGroup;
    };
    me.getSelectedMarketId = function () {
        return privateStore[me.id].SelectedMarketId;
    };
    me.marketSelectedEventHandler = function (sender) {
        me.setSelectedMarketId(parseInt($(sender.target).attr("data-target")));
        me.setSelectedMarket($(sender.target).attr("data-content"));
        me.displaySelectedMarket();
    };
    me.marketGroupSelectedEventHandler = function (sender) {
        me.setSelectedMarketGroup($(sender.target).attr("data-content"));
        me.setIsNoGroup(me.getSelectedMarketGroup() === "");
        me.displaySelectedMarketGroup();
        me.filterMarkets();
    };
    me.initialise = function () {
        me.registerEvents();
        me.registerSubscribers();
        me.filterMarkets();
    };
    me.onSuccessEventHandler = function (sender, eventArgs) {
        $("#Modal_Notify")
            .removeClass("alert-danger")
            .removeClass("alert-warning")
            .addClass("alert-success")
            .html("Market '" + me.getImportMarket() + "' mapped successfully to '" + me.getSelectedMarket() + "'")
            .show();
        $("#Modal_OK").hide();
        $("#Modal_Cancel").html("Close");
    };
    me.onErrorEventHandler = function (sender, eventArgs) {
        if (eventArgs.IsValidation) {
            $("#Modal_Notify")
                .removeClass("alert-danger")
                .removeClass("alert-success")
                .addClass("alert-warning").html(eventArgs.Message).show();
        } else {
            $("#Modal_Notify")
                .removeClass("alert-warning")
                .removeClass("alert-success")
                .addClass("alert-danger").html(eventArgs.Message).show();
        }
    };
    me.registerEvents = function () {
        var prefix = me.getIdentifierPrefix();
        $("#" + prefix + "_MarketGroupList").find("a.market-group-item").on("click", function (e) {
            me.marketGroupSelectedEventHandler(e);
            e.preventDefault();
        });
        $("#" + prefix + "_MarketList").find("a.market-item").on("click", function (e) {
            me.marketSelectedEventHandler(e);
            e.preventDefault();
        });
        $("#Modal_OK").unbind("click").on("click", me.action);
        $(document)
            .unbind("Success").on("Success", function (sender, eventArgs) { $(".subscribers-notify").trigger("OnSuccessDelegate", [eventArgs]); })
            .unbind("Error").on("Error", function (sender, eventArgs) { $(".subscribers-notify").trigger("OnErrorDelegate", [eventArgs]); })
    };
    me.registerSubscribers = function () {
        $("#Modal_Notify")
            .unbind("OnSuccessDelegate").on("OnSuccessDelegate", me.onSuccessEventHandler)
            .unbind("OnErrorDelegate").on("OnErrorDelegate", me.onErrorEventHandler)
    };
    me.setParameters = function (parameters) {
        privateStore[me.id].Parameters = parameters;
    };
    me.setSelectedMarketId = function (marketId) {
        privateStore[me.id].SelectedMarketId = marketId;
    };
    me.setSelectedMarket = function (market) {
        privateStore[me.id].SelectedMarket = market;
    };
    me.setSelectedMarketGroup = function (marketGroup) {
        privateStore[me.id].SelectedMarketGroup = marketGroup;
    };
    me.setIsNoGroup = function (isNoGroup) {
        privateStore[me.id].IsNoGroup = isNoGroup;
    };
    function getData() {
        var params = me.getParameters();
        if (params.Data != undefined)
            return JSON.parse(params.Data)

        return {};
    };
    function sendData(uri, params) {
        $.ajax({
            "dataType": "json",
            "async": true,
            "type": "POST",
            "url": uri,
            "data": params,
            "success": function (json) {
                $(document).trigger("Success", json);
            },
            "error": function (jqXHR, textStatus, errorThrown) {
                $(document).trigger("Error", JSON.parse(jqXHR.responseText));
            }
        });
    };
}