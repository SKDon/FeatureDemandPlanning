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
        $("#Modal_Notify").html("").hide();
        $("#Modal_OK").html("Mapping...Wait").attr("disabled", true);
        sendData(me.getActionUri(), me.getActionParameters());
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
        me.registerSubscribers();
        $("#Modal_OK").removeAttr("disabled").html("OK");
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
            .html("Feature '" + me.getImportFeatureCode() + "' mapped successfully to '" + me.getSelectedFeatureCode() + "'")
            .show();
        $("#Modal_OK").hide();
        $("#Modal_Cancel").html("Close");
        $(document).trigger("Updated", {});
    };
    me.onErrorEventHandler = function (sender, eventArgs) {
        if (eventArgs.IsValidation)
        {
            $("#Modal_Notify")
                .removeClass("alert-danger")
                .removeClass("alert-success")
                .addClass("alert-warning").html(eventArgs.Message).show();
        }
        else
        {
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