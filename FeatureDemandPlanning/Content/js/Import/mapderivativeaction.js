"use strict";

var model = namespace("FeatureDemandPlanning.Import");

model.MapDerivativeAction = function (params) {
    var uid = 0;
    var privateStore = {};
    var me = this;

    privateStore[me.id = uid++] = {};
    privateStore[me.id].Config = params.Configuration;
    privateStore[me.id].ActionUri = params.ModalActionUri;
    privateStore[me.id].SelectedDerivativeCode = "";
    privateStore[me.id].SelectedDerivative = "";
    privateStore[me.id].Parameters = params;

    me.action = function () {
        $("#Modal_Notify").html("").hide();
        $("#Modal_OK").html("Mapping...Wait").attr("disabled", true);
        sendData(me.getActionUri(), me.getActionParameters());
    };
    me.displaySelectedDerivative = function () {
        $("#" + me.getIdentifierPrefix() + "_SelectedDerivative").html(me.getSelectedDerivative());
    };
    me.getActionParameters = function () {
        return $.extend({}, getData(), {
            "DerivativeCode": me.getSelectedDerivativeCode(),
            "ImportDerivativeCode": me.getImportDerivativeCode()
        });
    };
    me.getIdentifierPrefix = function () {
        return $("#Action_IdentifierPrefix").val();
    };
    me.getImportDerivativeCode = function () {
        return $("#" + me.getIdentifierPrefix() + "_ImportDerivativeCode").val();
    };
    me.getActionUri = function () {
        return privateStore[me.id].ActionUri;
    };
    me.getParameters = function () {
        return privateStore[me.id].Parameters;
    };
    me.getSelectedDerivative = function () {
        return privateStore[me.id].SelectedDerivative;
    };
    me.getSelectedDerivativeCode = function () {
        return privateStore[me.id].SelectedDerivativeCode;
    };
    me.derivativeSelectedEventHandler = function (sender) {
        me.setSelectedDerivativeCode($(sender.target).attr("data-target"));
        me.setSelectedDerivative($(sender.target).attr("data-content"));
        me.displaySelectedDerivative();
    };
    me.initialise = function () {
        me.registerEvents();
        me.registerSubscribers();
        $("#Modal_OK").removeAttr("disabled").html("OK");
    };
    me.onSuccessEventHandler = function (sender, eventArgs) {
        $("#Modal_Notify")
            .removeClass("alert-danger")
            .removeClass("alert-warning")
            .addClass("alert-success")
            .html("Import Brochure Model Code '" + me.getImportDerivativeCode() + "' mapped successfully to '" + me.getSelectedDerivative() + "'")
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
            $("#Modal_OK").removeAttr("disabled").html("OK");
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
    me.setSelectedDerivativeCode = function (derivativeCode) {
        privateStore[me.id].SelectedDerivativeCode = derivativeCode;
    };
    me.setSelectedDerivative = function (derivative) {
        privateStore[me.id].SelectedDerivative = derivative;
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
            "error": function (jqXHR, textStatus, errorThrown) {
                $(document).trigger("Error", JSON.parse(jqXHR.responseText));
            }
        });
    };
}