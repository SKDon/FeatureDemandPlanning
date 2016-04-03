"use strict";

var model = namespace("FeatureDemandPlanning.Import");

model.MapOxoDerivativeAction = function (params) {
    var uid = 0;
    var privateStore = {};
    var me = this;

    privateStore[me.id = uid++] = {};
    privateStore[me.id].Config = params.Configuration;
    privateStore[me.id].ActionUri = params.ModalActionUri;
    privateStore[me.id].DerivativeCode = params.DerivativeCode;
    privateStore[me.id].SelectedDerivatives = [];
    privateStore[me.id].Parameters = params;

    me.action = function () {
        $("#Modal_Notify").html("").hide();
        $("#Modal_OK").html("Mapping...Wait").attr("disabled", true);
        sendData(me.getActionUri(), me.getActionParameters());
    };
    me.getActionParameters = function () {
        return $.extend({}, getData(), {
            "DerivativeCode": me.getDerivativeCode(),
            "ImportDerivativeCodes": me.getSelectedDerivatives()
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
    me.initialise = function () {
        me.registerEvents();
        me.registerSubscribers();
        $("#Modal_OK").removeAttr("disabled").html("OK");
        $("#" + me.getIdentifierPrefix() + "_DerivativeList").multiselect({
            onChange: function(option, checked) {
                me.setSelectedDerivatives();
            },
            maxHeight: 300,
            enableCaseInsensitiveFiltering: true,
            buttonWidth: 340
        });
    };
    me.getDerivativeCode = function() {
        return $("#" + me.getIdentifierPrefix() + "_DerivativeCode").val();
    };
    me.getSelectedDerivatives = function() {
        return privateStore[me.id].SelectedDerivatives;
    };
    me.setSelectedDerivatives = function() {
        privateStore[me.id].SelectedDerivatives = [];
        var selectedOptions = $("#" + me.getIdentifierPrefix() + "_DerivativeList option:selected");
        selectedOptions.each(function() {
            privateStore[me.id].SelectedDerivatives.push($(this).val());
        });
    }
    me.onSuccessEventHandler = function (sender, eventArgs) {
        $("#Modal_Notify")
            .removeClass("alert-danger")
            .removeClass("alert-warning")
            .addClass("alert-success")
            .html("OXO Brochure Model Code mapped successfully to historic data.")
            .show();
        $("#Modal_OK").hide();
        $("#Modal_Cancel").html("Close").removeAttr("disabled");
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
        $("#Modal_Cancel").html("Close").removeAttr("disabled");
    };
    me.registerEvents = function () {
        var prefix = me.getIdentifierPrefix();
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