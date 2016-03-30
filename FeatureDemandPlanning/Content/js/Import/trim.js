"use strict";

var model = namespace("FeatureDemandPlanning.Import");

model.Trim = function (params) {
    var uid = 0;
    var privateStore = {};
    var me = this;

    privateStore[me.id = uid++] = {};
    privateStore[me.id].Config = params.Configuration;
    privateStore[me.id].ModalContentUri = params.ModalContentUri;
    privateStore[me.id].ModalActionUri = params.ModalActionUri;
    privateStore[me.id].Parameters = params;
    
    me.ModelName = "Trim";

    me.initialise = function () {
    };
    me.getActionContentUri = function (action) {
        return privateStore[me.id].ModalContentUri;
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
            case 15:
                actionModel = new FeatureDemandPlanning.Import.MapOxoTrimAction(me.getParameters());
            default:
                break;
        }
        return actionModel;
    };
    me.getActionUri = function (action) {
        return privateStore[me.id].ModalActionUri;
    };
    me.getActionTitle = function (action) {
        var title = "";
        switch (action) {
            case 6:
                title = "Add New Trim Level";
                break;
            case 7:
                title = "Map Historic Trim Level to OXO DPCK";
                break;
            case 15:
                title = "Map OXO Model to Historic Trim Level";
            default:
                break;
        }
        return title;
    };
    me.getConfiguration = function () {
        return privateStore[me.id].Configuration;
    };
    me.getParameters = function () {
        return privateStore[me.id].Parameters;
    };
    me.setParameters = function (parameters) {
        privateStore[me.id].Parameters = parameters;
    };
    me.getProgrammeId = function() {
        return getData().ProgrammeId;
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

