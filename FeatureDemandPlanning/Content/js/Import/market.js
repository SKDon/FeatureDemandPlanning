﻿"use strict";

var model = namespace("FeatureDemandPlanning.Import");

model.Market = function (params) {
    var uid = 0;
    var privateStore = {};
    var me = this;

    privateStore[me.id = uid++] = {};
    privateStore[me.id].Config = params.Configuration;
    privateStore[me.id].ModalContentUri = params.ModalContentUri;
    privateStore[me.id].ModalActionUri = params.ModalActionUri;
    privateStore[me.id].Parameters = params;

    me.ModelName = "Market";

    me.initialise = function () {
    };
    me.getActionContentUri = function (action) {
        return privateStore[me.id].ModalContentUri;
    };
    me.getActionModel = function (action) {
        return new FeatureDemandPlanning.Import.MapMarketAction(me.getParameters());
    };
    me.getActionUri = function (action) {
        return privateStore[me.id].ModalActionUri;
    };
    me.getActionTitle = function (action) {
        return "Map Market to OXO";
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

