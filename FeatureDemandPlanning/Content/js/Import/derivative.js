"use strict";

var model = namespace("FeatureDemandPlanning.Import");

model.Derivative = function (params) {
    var uid = 0;
    var privateStore = {};
    var me = this;

    privateStore[me.id = uid++] = {};
    privateStore[me.id].Config = params.Configuration;
    privateStore[me.id].ModalContentUri = params.ModalContentUri;
    privateStore[me.id].ModalActionUri = params.ModalActionUri;
    privateStore[me.id].Parameters = params;

    me.ModelName = "Derivative";

    me.initialise = function () {
    };
    me.getActionContentUri = function (action) {
        return privateStore[me.id].ModalContentUri;
    };
    me.getActionModel = function (action) {
        var actionModel = null;
        switch (action) {
            case 2:
                actionModel = new FeatureDemandPlanning.Import.AddDerivativeAction(me.getParameters());
                break;
            case 3:
                actionModel = new FeatureDemandPlanning.Import.MapDerivativeAction(me.getParameters());
                break;
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
            case 2:
                title = "Add New Derivative";
                break;
            case 3:
                title = "Map Derivative to OXO";
                break;
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
    me.getVehicleId = function () {
        return getData().VehicleId;
    };
    me.setParameters = function (parameters) {
        privateStore[me.id].Parameters = parameters;
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

