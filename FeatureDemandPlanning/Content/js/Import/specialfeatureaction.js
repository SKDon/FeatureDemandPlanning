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
    privateStore[me.id].SelectedFeatures = [];
    privateStore[me.id].Parameters = params;

    me.action = function () {
        $("#Modal_Notify").html("").hide();
        $("#Modal_OK").html("Adding...Wait").attr("disabled", true);
        sendData(me.getActionUri(), me.getActionParameters());
    };
    me.getActionParameters = function () {
        return $.extend({}, getData(), {
            "SpecialFeatureTypeId": me.getSpecialFeatureTypeId(),
            "ImportFeatureCodes": me.getSelectedFeatures()
        });
    };
    me.getIdentifierPrefix = function () {
        return $("#Action_IdentifierPrefix").val();
    };
    me.getActionUri = function () {
        return privateStore[me.id].ActionUri;
    };
    me.getParameters = function () {
        return privateStore[me.id].Parameters;
    };
    me.getSpecialFeatureTypeId = function () {
        return parseInt($("#" + me.getIdentifierPrefix() + "_SpecialFeatureTypeId").val());
    };
    me.initialise = function () {
        me.registerEvents();
        me.registerSubscribers();
        $("#Modal_OK").removeAttr("disabled").html("OK");
        $("#" + me.getIdentifierPrefix() + "_FeatureList").multiselect({
            onChange: function (option, checked) {
                me.setSelectedFeatures();
            },
            maxHeight: 200
        });
    };
    me.getSelectedFeatures = function () {
        return privateStore[me.id].SelectedFeatures;
    };
    me.setSelectedFeatures = function () {
        privateStore[me.id].SelectedFeatures = [];
        var selectedOptions = $("#" + me.getIdentifierPrefix() + "_FeatureList option:selected");
        selectedOptions.each(function () {
            privateStore[me.id].SelectedFeatures.push($(this).val());
        });
    }
    me.onSuccessEventHandler = function () {
        $("#Modal_Notify")
            .removeClass("alert-danger")
            .removeClass("alert-warning")
            .addClass("alert-success")
            .html("Special Feature mapped successfully.")
            .show();
        $("#Modal_OK").hide();
        $("#Modal_Cancel").html("Close");
        $(document).trigger("Updated", {});
    };
    me.onErrorEventHandler = function (sender, eventArgs) {
        if (eventArgs.IsValidation) {
            $("#Modal_Notify")
                .removeClass("alert-danger")
                .removeClass("alert-success")
                .addClass("alert-warning").html(eventArgs.Message).show();
        } else {
            $("#Modal_Notify")
                .removeClass("alert-warning")
                .removeClass("alert-success")
                .addClass("alert-danger").html(eventArgs.Message).show();
        }
        $("#Modal_OK").hide();
        $("#Modal_Cancel").html("Close");
    };
    me.registerEvents = function () {
        var prefix = me.getIdentifierPrefix();
        $("#" + prefix + "_SpecialFeatureList").find("a.special-feature-item").on("click", function (e) {
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
            .unbind("OnErrorDelegate").on("OnErrorDelegate", me.onErrorEventHandler);
    };
    me.setParameters = function (parameters) {
        privateStore[me.id].Parameters = parameters;
    };
    function getData() {
        var params = me.getParameters();
        if (params.Data != undefined)
            return JSON.parse(params.Data);

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
            "error": function (jqXhr) {
                $(document).trigger("Error", JSON.parse(jqXhr.responseText));
            }
        });
    };
}