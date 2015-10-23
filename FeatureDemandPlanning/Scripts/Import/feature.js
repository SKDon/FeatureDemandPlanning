"use strict";

var model = namespace("FeatureDemandPlanning.Import");

model.Feature = function (params) {
    var uid = 0;
    var privateStore = {};
    var me = this;

    privateStore[me.id = uid++] = {};
    privateStore[me.id].Config = params.Configuration;
    privateStore[me.id].ModalContentUri = params.ModalContentUri;
    //privateStore[me.id].AddFeatureContentUri = params.AddFeatureContentUri;
    privateStore[me.id].AddFeatureActionUri = params.AddFeatureActionUri;
    //privateStore[me.id].AddSpecialFeatureContentUri = params.AddSpecialFeatureContentUri;
    privateStore[me.id].AddSpecialFeatureActionUri = params.AddSpecialFeatureActionUri;
    //privateStore[me.id].MapFeatureContentUri = params.MapFeatureContentUri;
    privateStore[me.id].MapFeatureActionUri = params.MapFeatureActionUri;
    privateStore[me.id].ListAvailableFeaturesUri = params.ListAvailableFeaturesUri;
    privateStore[me.id].AvailableFeatures = [];
    privateStore[me.id].Parameters = {};
    
    me.ModelName = "Feature";

    me.initialise = function () {
        me.listAvailableFeatures();
    };
    me.getActionContentUri = function (action) {
        return privateStore[me.id].ModalContentUri;
        //var uri = "";
        //switch (action) {
        //    case 4:
        //        uri = me.getAddFeatureContentUri();
        //        break;
        //    case 5:
        //        uri = me.getMapFeatureContentUri();
        //        break;
        //    case 9:
        //        uri = me.getAddSpecialFeatureContentUri();
        //        break;
        //    default:
        //        break;
        //}
        //return uri;
    };
    me.getActionUri = function (action) {
        var uri = "";
        switch (action) {
            case 4:
                uri = me.getAddFeatureActionUri();
                break;
            case 5:
                uri = me.getMapFeatureActionUri();
                break;
            case 9:
                uri = me.getAddSpecialFeatureActionUri();
                break;
            default:
                break;
        }
        return uri;
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
            default:
                break;
        }
        return title;
    };
    me.getAvailableFeatures = function () {
        return privateStore[me.id].AvailableFeatures;
    };
    me.setAvailableFeatures = function (features) {
        privateStore[me.id].AvailableFeatures = features.AvailableFeatures;
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
    //me.getAddFeatureContentUri = function () {
    //    return privateStore[me.id].AddFeatureContentUri;
    //};
    me.getAddFeatureActionUri = function () {
        return privateStore[me.id].AddFeatureActionUri;
    };
    //me.getAddSpecialFeatureContentUri = function () {
    //    return privateStore[me.id].AddSpecialFeatureContentUri;
    //};
    me.getAddSpecialFeatureActionUri = function () {
        return privateStore[me.id].AddSpecialFeatureActionUri;
    };
    //me.getMapFeatureContentUri = function () {
    //    return privateStore[me.id].MapFeatureContentUri;
    //};
    me.getMapFeatureActionUri = function () {
        return privateStore[me.id].MapFeatureActionUri;
    };
    me.getAvailableFeaturesUri = function () {
        return privateStore[me.id].ListAvailableFeaturesUri;
    }
    me.getVehicleId = function() {
        return getData().VehicleId;
    };
    me.listAvailableFeatures = function () {
        sendData(me.getAvailableFeaturesUri(), { VehicleId: me.getVehicleId() }, me.setAvailableFeatures);
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

