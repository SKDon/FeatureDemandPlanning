"use strict";

var model = namespace("FeatureDemandPlanning.Import");

model.AddTrimAction = function (params) {
    var uid = 0;
    var privateStore = {};
    var me = this;

    privateStore[me.id = uid++] = {};
    privateStore[me.id].Config = params.Configuration;
    privateStore[me.id].ActionUri = params.ModalActionUri;
    privateStore[me.id].SelectedTrimLevel = null;
    privateStore[me.id].SelectedTrimLevelDescription = "";
    privateStore[me.id].SelectedDerivativeCode = "";
    privateStore[me.id].SelectedDerivative = "";
    privateStore[me.id].Parameters = params;

    me.action = function () {
        $("#Modal_Notify").html("").hide();
        $("#Modal_OK").html("Adding...Wait").attr("disabled", true);
        sendData(me.getActionUri(), me.getActionParameters());
    };
    me.displaySelectedTrimLevel = function () {
        $("#" + me.getIdentifierPrefix() + "_SelectedTrimLevel").html(me.getSelectedTrimLevelDescription());
    };
    me.displaySelectedDerivative = function () {
        $("#" + me.getIdentifierPrefix() + "_SelectedDerivative").html(me.getSelectedDerivative());
    };
    me.getActionParameters = function () {
        return $.extend({}, getData(), {
            "DerivativeCode": me.getSelectedDerivativeCode(),
            "TrimName": me.getImportTrim(),
            "TrimLevel": me.getSelectedTrimLevelDescription(),
            "TrimAbbreviation": me.getAbbreviation(),
            "DPCK": me.getDPCK()
        });
    };
    me.getIdentifierPrefix = function () {
        return $("#Action_IdentifierPrefix").val();
    };
    me.getImportTrim = function () {
        return $("#" + me.getIdentifierPrefix() + "_ImportTrim").attr("data-target");
    };
    me.getActionUri = function () {
        return privateStore[me.id].ActionUri;
    };
    me.getParameters = function () {
        return privateStore[me.id].Parameters;
    };
    me.getAbbreviation = function () {
        return $("#" + me.getIdentifierPrefix() + "_TextAbbreviation").val();
    };
    me.getDPCK = function () {
        return $("#" + me.getIdentifierPrefix() + "_TextDPCK").val();
    };
    me.getSelectedDerivativeCode = function () {
        return privateStore[me.id].SelectedDerivativeCode;
    };
    me.getSelectedDerivative = function () {
        return privateStore[me.id].SelectedDerivative;
    };
    me.getSelectedTrim = function () {
        return me.getImportTrim();
    };
    me.getSelectedTrim = function () {
        return me.getImportTrim();
    };
    me.getSelectedTrimLevel = function () {
        return privateStore[me.id].SelectedTrimLevel;
    };
    me.getSelectedTrimLevelDescription = function () {
        return privateStore[me.id].SelectedTrimLevelDescription;
    };
    me.derivativeSelectedEventHandler = function (sender) {
        me.setSelectedDerivativeCode($(sender.target).attr("data-target"));
        me.setSelectedDerivative($(sender.target).attr("data-content"));
        me.displaySelectedDerivative();
    };
    me.trimLevelSelectedEventHandler = function (sender) {
        me.setSelectedTrimLevel(parseInt($(sender.target).attr("data-target")));
        me.setSelectedTrimLevelDescription($(sender.target).attr("data-content"));
        me.displaySelectedTrimLevel();
    };
    me.initialise = function () {
        me.registerEvents();
        me.registerSubscribers();
        me.setSelectedDerivativeCode($("#" + me.getIdentifierPrefix() + "_InitialSelectedDerivative").val());
        $("#Modal_OK").removeAttr("disabled").html("OK");
    };
    me.onSuccessEventHandler = function (sender, eventArgs) {
        $("#Modal_Notify")
            .removeClass("alert-danger")
            .removeClass("alert-warning")
            .addClass("alert-success")
            .html("New trim '" + me.getImportTrim() + " (" + me.getSelectedTrimLevelDescription() + ")' added successfully")
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
        } else {
            $("#Modal_Notify")
                .removeClass("alert-warning")
                .removeClass("alert-success")
                .addClass("alert-danger").html(eventArgs.Message).show();
        }
    };
    me.registerEvents = function () {
        var prefix = me.getIdentifierPrefix();
        $("#" + prefix + "_DerivativeList").find("a.derivative-item").on("click", function (e) {
            me.derivativeSelectedEventHandler(e);
            e.preventDefault();
        });
        $("#" + prefix + "_TrimLevelList").find("a.trimlevel-item").on("click", function (e) {
            me.trimLevelSelectedEventHandler(e);
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
    me.setSelectedDerivativeCode = function (derivativeCode) {
        privateStore[me.id].SelectedDerivativeCode = derivativeCode;
    };
    me.setSelectedDerivative = function (derivative) {
        privateStore[me.id].SelectedDerivative = derivative;
    };
    me.setSelectedTrimLevel = function (trimLevel) {
        privateStore[me.id].SelectedTrimLevel = trimLevel;
    };
    me.setSelectedTrimLevelDescription = function (trimLevelDescription) {
        privateStore[me.id].SelectedTrimLevelDescription = trimLevelDescription;
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