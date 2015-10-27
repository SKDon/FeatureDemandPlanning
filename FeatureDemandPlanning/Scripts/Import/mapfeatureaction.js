"use strict";

var model = namespace("FeatureDemandPlanning.Import");

model.MapFeatureAction = function (params) {
    var uid = 0;
    var privateStore = {};
    var me = this;

    privateStore[me.id = uid++] = {};
    privateStore[me.id].Config = params.Configuration;
    privateStore[me.id].ActionUri = params.ModalActionUri;
    privateStore[me.id].ListAvailableFeaturesUri = params.ListAvailableFeaturesUri;
    privateStore[me.id].SelectedFeatureCode = null;
    privateStore[me.id].SelectedFeatureDescription = "";
    privateStore[me.id].AvailableFeatures = [];
    privateStore[me.id].Parameters = params;

    me.action = function () {
        sendData(me.getActionUri(), me.getActionParameters(), me.actionCallback);
    };
    me.actionCallback = function (json) {
        alert("hell yeah");
    };
    me.displaySelectedFeature = function () {
        $("#" + me.getIdentifierPrefix() + "_SelectedFeature").html(me.getSelectedFeatureDescription());
    }
    me.getActionParameters = function () {
        return $.extend({}, getData(), {
            "FeatureCode": me.getSelectedFeatureCode(),
            "ImportFeatureCode": me.getImportFeatureCode()
        });
    };
    me.getIdentifierPrefix = function () {
        return $("#Action_IdentifierPrefix").val();
    };
    me.getImportFeatureCode = function () {
        return $("#" + me.getIdentifierPrefix() + "_ImportFeatureCode").attr("data-target");
    };
    me.getActionUri = function () {
        return privateStore[me.id].ActionUri;
    };
    me.getParameters = function () {
        return privateStore[me.id].Parameters;
    };
    me.getSelectedFeatureCode = function () {
        return privateStore[me.id].SelectedFeatureCode;
    };
    me.getSelectedFeatureDescription = function () {
        return privateStore[me.id].SelectedFeatureDescription;
    };
    me.itemSelectedEventHandler = function (sender) {
        me.setSelectedFeatureCode($(sender.target).attr("data-target"));
        me.setSelectedFeatureDescription($(sender.target).attr("data-content"));
        me.displaySelectedFeature();
    };
    me.initialise = function () {
        me.listAvailableFeatures();
        me.registerEvents();
    };
    me.listAvailableFeatures = function () {

    };
    me.listAvailableFeaturesCallback = function (response) {

    };
    me.registerEvents = function () {
        var prefix = me.getIdentifierPrefix();
        $("#" + prefix + "_FeatureList").find("a.feature-item").on("click", function (e) {
            me.itemSelectedEventHandler(e);
            e.preventDefault();
        });

        $("#Modal_OK").unbind("click").on("click", me.action);
    };
    me.setParameters = function (parameters) {
        privateStore[me.id].Parameters = parameters;
    };
    me.setSelectedFeatureCode = function (featureCode) {
        privateStore[me.id].SelectedFeatureCode = featureCode;
    };
    me.setSelectedFeatureDescription = function (featureDescription) {
        privateStore[me.id].SelectedFeatureDescription = featureDescription;
    };
    function getData() {
        var params = me.getParameters();
        if (params.Data != undefined)
            return JSON.parse(params.Data)

        return {};
    };
    function sendData(uri, params, callback) {
        $.ajax({
            "dataType": "json",
            "async": true,
            "type": "POST",
            "url": uri,
            "data": params,
            "success": callback,
            "error": function (jqXHR, textStatus, errorThrown) {
                alert(jqXHR.responseText);
            }
        });
    };
}