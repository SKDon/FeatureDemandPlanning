"use strict";

var model = namespace("FeatureDemandPlanning.Import");

model.Trim = function (params) {
    var uid = 0;
    var privateStore = {};
    var me = this;

    privateStore[me.id = uid++] = {};
    privateStore[me.id].Config = params.Configuration;
    privateStore[me.id].AddTrimContentUri = params.AddTrimContentUri;
    privateStore[me.id].AddTrimActionUri = params.AddTrimActionUri;
    privateStore[me.id].MapTrimContentUri = params.MapTrimContentUri;
    privateStore[me.id].MapTrimActionUri = params.MapTrimActionUri;
    privateStore[me.id].ListAvailableTrimUri = params.ListAvailableTrimUri;
    privateStore[me.id].AvailableTrim = [];
    privateStore[me.id].Parameters = {};
    
    me.ModelName = "Trim";

    me.initialise = function () {
        me.listAvailableTrim();
    };
    me.getActionContentUri = function (action) {
        var uri = "";
        switch (action) {
            case 6:
                uri = me.getAddTrimContentUri();
                break;
            case 7:
                uri = me.getMapTrimContentUri();
                break;
            default:
                break;
        }
        return uri;
    };
    me.getActionModel = function (action) {
        var actionModel = null;
        switch (action) {
            case 6:
                actionModel = new FeatureDemandPlanning.Import.AddTrimAction(me.getParameters());
                break;
            case 7:
                actionModel = new FeatureDemandPlanning.Import.MapTrimAction(me.getParameters());
                break;
            default:
                break;
        }
        return actionModel;
    };
    me.getActionUri = function (action) {
        var uri = "";
        switch (action) {
            case 6:
                uri = me.getAddTrimActionUri();
                break;
            case 7:
                uri = me.getMapTrimActionUri();
                break;
            default:
                break;
        }
        return uri;
    };
    me.getActionTitle = function (action) {
        var title = "";
        switch (action) {
            case 6:
                title = "Add New Trim Level";
                break;
            case 7:
                title = "Map Trim Level to OXO";
                break;
            default:
                break;
        }
        return title;
    };
    me.getAvailableTrim = function () {
        return privateStore[me.id].AvailableTrim;
    };
    me.setAvailableTrim = function (trim) {
        privateStore[me.id].AvailableTrim = engines.AvailableTrim;
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
    me.getAvailableTrimUri = function () {
        return privateStore[me.id].ListAvailableTrimUri;
    }
    me.getProgrammeId = function() {
        return getData().ProgrammeId;
    };
    me.listAvailableTrim = function () {
        sendData(me.getAvailableTrimUri(), { ProgrammeId: me.getProgrammeId() }, me.setAvailableTrim);
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

