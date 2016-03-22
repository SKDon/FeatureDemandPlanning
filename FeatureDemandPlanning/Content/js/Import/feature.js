"use strict";

var model = namespace("FeatureDemandPlanning.Import");

model.Feature = function (params) {
    var uid = 0;
    var privateStore = {};
    var me = this;

    privateStore[me.id = uid++] = {};
    privateStore[me.id].Config = params.Configuration;
    privateStore[me.id].ModalContentUri = params.ModalContentUri;
    privateStore[me.id].ModalActionUri = params.ModalActionUri;
    privateStore[me.id].ListAvailableFeaturesUri = params.ListAvailableFeaturesUri;
    privateStore[me.id].AvailableFeatures = [];
    privateStore[me.id].Parameters = params;
    
    me.ModelName = "Feature";

    me.initialise = function () {
        //me.listAvailableFeatures();
    };
    me.getActionContentUri = function (action) {
        return privateStore[me.id].ModalContentUri;
    };
    me.getActionModel = function (action) {
        var actionModel = null;
        switch (action) {
            case 4:
                actionModel = new FeatureDemandPlanning.Import.AddFeatureAction(me.getParameters());
                break;
            case 5:
                actionModel = new FeatureDemandPlanning.Import.MapFeatureAction(me.getParameters());
                break;
            case 9:
                actionModel = new FeatureDemandPlanning.Import.SpecialFeatureAction(me.getParameters());
                break;
            case 16:
                actionModel = new FeatureDemandPlanning.Import.MapOxoFeatureAction(me.getParameters());
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
            case 4:
                title = "Add New Feature";
                break;
            case 5:
                title = "Map Feature to OXO";
                break;
            case 9:
                title = "Add New Special Feature";
                break;
            case 16:
                title = "Map OXO Feature Code to Historic";
            default:
                break;
        }
        return title;
    };
    me.getAvailableFeatures = function () {
        return privateStore[me.id].AvailableFeatures;
    };
    me.getAvailableFeaturesUri = function () {
        return privateStore[me.id].ListAvailableFeaturesUri;
    };
    me.getConfiguration = function () {
        return privateStore[me.id].Configuration;
    };
    me.getParameters = function () {
        return privateStore[me.id].Parameters;
    };
    me.getUpdateParameters = function () {
        return $.extend({}, getData(), {
            //"FeatureCode": $("#featureCode").val(),
            "ImportFeatureCode": $("#dvImportFeatureCode").attr("data-id")
        });
    }
    me.getVehicleId = function () {
        return getData().VehicleId;
    };
    me.listAvailableFeatures = function () {
        sendData(me.getAvailableFeaturesUri(), { VehicleId: me.getVehicleId() }, me.setAvailableFeatures);
    };
    me.setAvailableFeatures = function (features) {
        privateStore[me.id].AvailableFeatures = features.AvailableFeatures;
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

