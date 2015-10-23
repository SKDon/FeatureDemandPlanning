"use strict";

var model = namespace("FeatureDemandPlanning.Import");

model.Market = function (params) {
    var uid = 0;
    var privateStore = {};
    var me = this;

    privateStore[me.id = uid++] = {};
    privateStore[me.id].Config = params.Configuration;
    privateStore[me.id].MapMarketContentUri = params.MapMarketContentUri;
    privateStore[me.id].MapMarketActionUri = params.MapMarketContentUri;
    privateStore[me.id].ListAvailableMarketsUri = params.ListAvailableMarketsUri;
    privateStore[me.id].CurrentMarket = null;
    privateStore[me.id].AvailableMarkets = [];
    privateStore[me.id].Parameters = {};
    
    me.ModelName = "Market";

    me.initialise = function () {
        me.listAvailableMarkets();
    };
    me.getActionUri = function (actionId) {
        var uri = "";
        switch (actionId) {
            case 1:
                uri = me.getMapMarketActionUri();
                break;
            default:
                break;
        }
        return uri;
    };
    me.getActionContentUri = function (actionId) {
        var uri = "";
        switch (actionId) {
            case 1:
                uri = me.getMapMarketContentUri();
                break;
            default:
                break;
        }
        return uri;
    };
    me.getActionTitle = function (actionId) {
        var title = "";
        switch (actionId) {
            case 1:
                title = "Map Market to OXO";
                break;
            default:
                break;
        }
        return title;
    };
    me.getAvailableMarkets = function () {
        var availableMarkets = [];
        for (var i = 0; i < privateStore[me.id].AvailableMarkets.length; i++)
        {
            availableMarkets.push(privateStore[me.id].AvailableMarkets[i].Name);
        }
        return availableMarkets;
    };
    me.setAvailableMarkets = function (markets) {
        privateStore[me.id].AvailableMarkets = markets.AvailableMarkets;
    };
    me.getConfiguration = function () {
        return privateStore[me.id].Configuration;
    };
    me.getParameters = function () {
        return privateStore[me.id].Parameters;
    };
    me.setParameters = function (parameters) {
        privateStore[me.id].Parameters = parameters;
    }
    me.getMapMarketContentUri = function () {
        return privateStore[me.id].MapMarketContentUri;
    };
    me.getMapMarketActionUri = function () {
        return privateStore[me.id].MapMarketActionUri;
    };
    me.getAvailableMarketsUri = function () {
        return privateStore[me.id].ListAvailableMarketsUri;
    };
    me.getMarketIdFromName = function (marketName) {
        var availableMarketId = 0;
        for (var i = 0; i < privateStore[me.id].AvailableMarkets; i++) {
            if (marketName == privateStore[me.id].AvailableMarkets[i].Name) {
                availableMarketId = privateStore[me.id].AvailableMarkets[i].Id;
                break;
            }
        }
        return availableMarketId;
    };
    me.getProgrammeId = function() {
        return getData().ProgrammeId;
    };
    me.listAvailableMarkets = function () {
        sendData(me.getAvailableMarketsUri(), { ProgrammeId: me.getProgrammeId() }, me.setAvailableMarkets);
    };
    me.mapMarket = function (importMarket, mapMarketId, callback) {
        sendData(me.getMapMarketActionUri(), { ImportMarket: importMarket, MapMarketId: mapMarketId }, callback);
    };
    function getData() {
        var params = me.getParameters();
        if (params.Data != undefined)
            return JSON.parse(me.getParameters().Data);

        return {};
    };
    function sendData(uri, params, callback) {
        $.ajax({
            "dataType": "json",
            "async": true,
            "type": "POST",
            "url": uri,
            "data": params,
            "success": function (json) {
                callback(json)
            }
        });
    };
}

