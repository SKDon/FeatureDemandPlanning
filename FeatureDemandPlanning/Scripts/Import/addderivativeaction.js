"use strict";

var model = namespace("FeatureDemandPlanning.Import");

model.AddDerivativeAction = function (params) {
    var uid = 0;
    var privateStore = {};
    var me = this;

    privateStore[me.id = uid++] = {};
    privateStore[me.id].Config = params.Configuration;
    privateStore[me.id].ActionUri = params.ModalActionUri;
    privateStore[me.id].SelectedBodyId = null;
    privateStore[me.id].SelectedEngineId = null;
    privateStore[me.id].SelectedTransmissionId = null;
    privateStore[me.id].SelectedBody = "";
    privateStore[me.id].SelectedEngine = "";
    privateStore[me.id].SelectedTransmission = "";
    privateStore[me.id].Parameters = params;

    me.action = function () {
        sendData(me.getActionUri(), me.getActionParameters());
    };
    me.displaySelectedBody = function () {
        $("#" + me.getIdentifierPrefix() + "_SelectedBody").html(me.getSelectedBody());
    }
    me.displaySelectedEngine = function () {
        $("#" + me.getIdentifierPrefix() + "_SelectedEngine").html(me.getSelectedEngine());
    }
    me.displaySelectedTransmission = function () {
        $("#" + me.getIdentifierPrefix() + "_SelectedTransmission").html(me.getSelectedTransmission());
    }
    me.getActionParameters = function () {
        return $.extend({}, getData(), {
            "DerivativeCode": me.getImportDerivativeCode(),
            "ImportDerivativeCode": me.getImportDerivativeCode(),
            "BodyId": me.getSelectedBodyId(),
            "EngineId": me.getSelectedEngineId(),
            "TransmissionId": me.getSelectedTransmissionId()
        });
    };
    me.getIdentifierPrefix = function () {
        return $("#Action_IdentifierPrefix").val();
    };
    me.getImportDerivativeCode = function () {
        return $("#" + me.getIdentifierPrefix() + "_ImportDerivativeCode").attr("data-target");
    };
    me.getActionUri = function () {
        return privateStore[me.id].ActionUri;
    };
    me.getParameters = function () {
        return privateStore[me.id].Parameters;
    };
    me.getSelectedDerivativeCode = function () {
        return me.getImportDerivativeCode();
    };
    me.getSelectedBody = function () {
        return privateStore[me.id].SelectedBody;
    };
    me.getSelectedEngine = function () {
        return privateStore[me.id].SelectedEngine;
    };
    me.getSelectedTransmission = function () {
        return privateStore[me.id].SelectedTransmission;
    };
    me.getSelectedBodyId = function () {
        return privateStore[me.id].SelectedBodyId;
    };
    me.getSelectedEngineId = function () {
        return privateStore[me.id].SelectedEngineId;
    };
    me.getSelectedTransmissionId = function () {
        return privateStore[me.id].SelectedTransmissionId;
    };
    me.bodySelectedEventHandler = function (sender) {
        me.setSelectedBodyId(parseInt($(sender.target).attr("data-target")));
        me.setSelectedBody($(sender.target).attr("data-content"));
        me.displaySelectedBody();
    };
    me.engineSelectedEventHandler = function (sender) {
        me.setSelectedEngineId(parseInt($(sender.target).attr("data-target")));
        me.setSelectedEngine($(sender.target).attr("data-content"));
        me.displaySelectedEngine();
    };
    me.transmissionSelectedEventHandler = function (sender) {
        me.setSelectedTransmissionId(parseInt($(sender.target).attr("data-target")));
        me.setSelectedTransmission($(sender.target).attr("data-content"));
        me.displaySelectedTransmission();
    };
    me.initialise = function () {
        me.registerEvents();
        me.registerSubscribers();
    };
    me.onSuccessEventHandler = function (sender, eventArgs) {
        $("#Modal_Notify")
            .removeClass("alert-danger")
            .removeClass("alert-warning")
            .addClass("alert-success")
            .html("New derivative '" + me.getImportDerivativeCode() + "' added successfully")
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
        $("#" + prefix + "_BodyList").find("a.body-item").on("click", function (e) {
            me.bodySelectedEventHandler(e);
            e.preventDefault();
        });
        $("#" + prefix + "_EngineList").find("a.engine-item").on("click", function (e) {
            me.engineSelectedEventHandler(e);
            e.preventDefault();
        });
        $("#" + prefix + "_TransmissionList").find("a.transmission-item").on("click", function (e) {
            me.transmissionSelectedEventHandler(e);
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
    me.setSelectedBodyId = function (bodyId) {
        privateStore[me.id].SelectedBodyId = bodyId;
    };
    me.setSelectedEngineId = function (engineId) {
        privateStore[me.id].SelectedEngineId = engineId;
    };
    me.setSelectedTransmissionId = function (transmissionId) {
        privateStore[me.id].SelectedTransmissionId = transmissionId;
    };
    me.setSelectedBody = function (body) {
        privateStore[me.id].SelectedBody = body;
    };
    me.setSelectedEngine = function (engine) {
        privateStore[me.id].SelectedEngine = engine;
    };
    me.setSelectedTransmission = function (transmission) {
        privateStore[me.id].SelectedTransmission = transmission;
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