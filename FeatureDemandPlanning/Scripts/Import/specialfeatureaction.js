"use strict";

var model = namespace("FeatureDemandPlanning.Import");

model.SpecialFeatureAction = function (params) {
    var uid = 0;
    var privateStore = {};
    var me = this;

    privateStore[me.id = uid++] = {};
    privateStore[me.id].Config = params.Configuration;
    privateStore[me.id].ModalContentUri = params.ModalContentUri;
    privateStore[me.id].ModalActionUri = params.ModelActionUri;
    privateStore[me.id].ListAvailableFeaturesUri = params.ListAvailableFeaturesUri;
    privateStore[me.id].AvailableFeatures = [];
    privateStore[me.id].Parameters = {};

    me.initialise = function () {
        me.listAvailableFeatures();
    };
    me.getParameters = function () {
        return privateStore[me.id].Parameters;
    };
    me.getUpdateParameters = function () {
        return $.extend({}, getData(), {
            "FeatureCode": $("#featureCode").val(),
            "ImportFeatureCode": $("#dvImportFeatureCode").attr("data-id")
        });
    };
    me.listAvailableFeatures = function () {

    };
    me.listAvailableFeaturesCallback = function (response) {

    };
    function getData() {
        var params = me.getParameters();
        if (params.Data != undefined)
            return JSON.parse(me.getParameters().Data);

        return {};
    };
}