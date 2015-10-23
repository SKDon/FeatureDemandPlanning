"use strict";

var model = namespace("FeatureDemandPlanning.Import");

model.Derivative = function (params) {
    var uid = 0;
    var privateStore = {};
    var me = this;

    privateStore[me.id = uid++] = {};
    privateStore[me.id].Config = params.Configuration;
    privateStore[me.id].AddDerivativeContentUri = params.AddDerivativeContentUri;
    privateStore[me.id].AddDerivativeActionUri = params.AddDerivativeActionUri;
    privateStore[me.id].MapDerivativeContentUri = params.MapDerivativeContentUri;
    privateStore[me.id].MapDerivativeActionUri = params.MapDerivativeActionUri;
    privateStore[me.id].ListAvailableBodiesUri = params.ListAvailableBodiesUri;
    privateStore[me.id].ListAvailableEnginesUri = params.ListAvailableEnginesUri;
    privateStore[me.id].ListAvailableTransmissionsUri = params.ListAvailableTransmissionsUri;
    privateStore[me.id].AvailableBodies = [];
    privateStore[me.id].AvailableEngines = [];
    privateStore[me.id].AvailableTransmissions = [];
    privateStore[me.id].Parameters = {};
    
    me.ModelName = "Derivative";

    me.initialise = function () {
        me.listAvailableBodies();
        me.listAvailableEngines();
        me.listAvailableTransmissions();
    };
    me.getActionContentUri = function (action) {
        var uri = "";
        switch (action) {
            case 2:
                uri = me.getAddDerivativeContentUri();
                break;
            case 3:
                uri = me.getMapDerivativeContentUri();
                break;
            default:
                break;
        }
        return uri;
    };
    me.getActionUri = function (action) {
        var uri = "";
        switch (action) {
            case 2:
                uri = me.getAddDerivativeActionUri();
                break;
            case 3:
                uri = me.getMapDerivativeActionUri();
                break;
            default:
                break;
        }
        return uri;
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
    me.getAvailableBodies = function () {
        return privateStore[me.id].AvailableBodies;
    };
    me.getAvailableEngines = function () {
        return privateStore[me.id].AvailableEngines;
    };
    me.getAvailableTransmissions = function () {
        return privateStore[me.id].AvailableTransmissions;
    };
    me.setAvailableBodies = function (bodies) {
        privateStore[me.id].AvailableBodies = features.AvailableBodies;
    };
    me.setAvailableEngines = function (engines) {
        privateStore[me.id].AvailableEngines = engines.AvailableEngines;
    };
    me.setAvailableTransmissions = function (transmissions) {
        privateStore[me.id].AvailableTransmissions = transmissions.AvailableTransmissions;
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
    me.getAddDerivativeContentUri = function () {
        return privateStore[me.id].AddDerivativeContentUri;
    };
    me.getAddDerivativeActionUri = function () {
        return privateStore[me.id].AddDerivativeActionUri;
    };
    me.getMapDerivativeContentUri = function () {
        return privateStore[me.id].MapDerivativeContentUri;
    };
    me.getMapDerivativeActionUri = function () {
        return privateStore[me.id].MapDerivativeActionUri;
    };
    me.getAvailableBodiesUri = function () {
        return privateStore[me.id].ListAvailableBodiesUri;
    };
    me.getAvailableEnginesUri = function () {
        return privateStore[me.id].ListAvailableEnginesUri;
    };
    me.getAvailableTransmissionsUri = function () {
        return privateStore[me.id].ListAvailableTransmissionsUri;
    };
    me.getVehicleId = function() {
        return getData().VehicleId;
    };
    me.getProgrammeId = function () {
        return getData().ProgrammeId;
    };
    me.listAvailableBodies = function () {
        sendData(me.getAvailableBodiesUri(), { ProgrammeId: me.getProgrammeId() }, me.setAvailableBodies);
    };
    me.listAvailableEngines = function () {
        sendData(me.getAvailableEnginesUri(), { ProgrammeId: me.getProgrammeId() }, me.setAvailableEngines);
    };
    me.listAvailableTransmissions = function () {
        sendData(me.getAvailableBodiesUri(), { ProgrammeId: me.getProgrammeId() }, me.setAvailableTransmissions);
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

