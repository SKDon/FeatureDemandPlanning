"use strict";

var model = namespace("FeatureDemandPlanning.Import");

model.SpecialFeatureAction = function (params) {
    var uid = 0;
    var privateStore = {};
    var me = this;

    privateStore[me.id = uid++] = {};
    privateStore[me.id].Config = params.Configuration;
    privateStore[me.id].ActionUri = params.ModalActionUri;
    privateStore[me.id].ListAvailableFeaturesUri = params.ListAvailableFeaturesUri;
    privateStore[me.id].SelectedSpecialFeatureTypeId = null;
    privateStore[me.id].SelectedSpecialFeatureType = "";
    privateStore[me.id].AvailableFeatures = [];
    privateStore[me.id].Parameters = params;

    me.action = function () {
        sendData(me.getActionUri(), me.getActionParameters());
    };
    me.displaySelectedFeature = function () {
        $("#" + me.getIdentifierPrefix() + "_SelectedSpecialFeatureTypeId").html(me.getSelectedSpecialFeatureType());
    }
    me.getActionParameters = function () {
        return $.extend({}, getData(), {
            "SpecialFeatureTypeId": me.getSelectedSpecialFeatureTypeId(),
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
    me.getSelectedSpecialFeatureTypeId = function () {
        return privateStore[me.id].SelectedSpecialFeatureTypeId;
    };
    me.getSelectedSpecialFeatureType = function () {
        return privateStore[me.id].SelectedSpecialFeatureType;
    };
    me.itemSelectedEventHandler = function (sender) {
        me.setSelectedSpecialFeatureTypeId(parseInt($(sender.target).attr("data-target")));
        me.setSelectedSpecialFeatureType($(sender.target).attr("data-content"));
        me.displaySelectedFeature();
    };
    me.initialise = function () {
        me.listAvailableFeatures();
        me.registerEvents();
        me.registerSubscribers();
    };
    me.listAvailableFeatures = function () {

    };
    me.listAvailableFeaturesCallback = function (response) {

    };
    me.onSuccessEventHandler = function (sender, eventArgs) {
        $("#Modal_Notify")
            .removeClass("alert-danger")
            .removeClass("alert-warning")
            .addClass("alert-success")
            .html("Feature '" + me.getImportFeatureCode() + "' mapped successfully to '" + me.getSelectedSpecialFeatureType() + "'")
            .show();
        $("#Modal_OK").hide();
        $("#Modal_Cancel").html("Close");
    };
    me.onErrorEventHandler = function (sender, eventArgs) {
        if (eventArgs.IsValidation) {
            $("#Modal_Notify")
                .removeClass("alert-danger")
                .removeClass("alert-success")
                .addClass("alert-warning").html(eventArgs.Message).show();
        }
        else {
            $("#Modal_Notify")
                .removeClass("alert-warning")
                .removeClass("alert-success")
                .addClass("alert-danger").html(eventArgs.Message).show();
        }
    };
    me.registerEvents = function () {
        var prefix = me.getIdentifierPrefix();
        $("#" + prefix + "_FeatureList").find("a.feature-item").on("click", function (e) {
            me.itemSelectedEventHandler(e);
            e.preventDefault();
        });

        $("#Modal_OK").unbind("click").on("click", me.action);
        $(document)
            .unbind("Success").on("Success", function (sender, eventArgs) { $(".subscribers-notify").trigger("OnSuccessDelegate", [eventArgs]); })
            .unbind("Error").on("Error", function (sender, eventArgs) { $(".subscribers-notify").trigger("OnErrorDelegate", [eventArgs]); })
    };
    me.registerSubscribers = function () {
        $("#Modal_Notify")
            .unbind("OnSuccessDelegate").on("OnSuccessDelegate", me.onSuccessEventHandler)
            .unbind("OnErrorDelegate").on("OnErrorDelegate", me.onErrorEventHandler)
    };
    me.setParameters = function (parameters) {
        privateStore[me.id].Parameters = parameters;
    };
    me.setSelectedSpecialFeatureTypeId = function (specialFeatureTypeId) {
        privateStore[me.id].SelectedSpecialFeatureTypeId = specialFeatureTypeId;
    };
    me.setSelectedSpecialFeatureType = function (specialFeatureType) {
        privateStore[me.id].SelectedSpecialFeatureType = specialFeatureType;
    };
    function getData() {
        var params = me.getParameters();
        if (params.Data != undefined)
            return JSON.parse(params.Data)

        return {};
    };
    function sendData(uri, params) {
        $.ajax({
            "dataType": "json",
            "async": true,
            "type": "POST",
            "url": uri,
            "data": params,
            "success": function (json) {
                $(document).trigger("Success", json);
            },
            "error": function (jqXHR, textStatus, errorThrown) {
                $(document).trigger("Error", JSON.parse(jqXHR.responseText));
            }
        });
    };
}