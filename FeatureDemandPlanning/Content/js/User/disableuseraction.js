"use strict";

var model = namespace("FeatureDemandPlanning.User");

model.DisableUserAction = function (params) {
    var uid = 0;
    var privateStore = {};
    var me = this;

    privateStore[me.id = uid++] = {};
    privateStore[me.id].Config = params.Configuration;
    privateStore[me.id].ActionUri = params.ModalActionUri;
    privateStore[me.id].Parameters = params;

    me.action = function () {
        sendData(me.getActionUri(), me.getActionParameters());
    };
    me.actionImmediate = function (params) {
        sendData(me.getActionUri(), params);
    };
    me.getActionParameters = function () {
        return $.extend({}, getData(), {
            "CDSId": me.getCDSId(),
            "IsActive": false
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
    me.getCDSId = function () {
        return $("#" + me.getIdentifierPrefix() + "_CDSId").val();
    };
    me.initialise = function () {
        me.registerEvents();
        me.registerSubscribers();
    };
    me.isModalAction = function () {
        return false;
    };
    me.registerEvents = function () {
        $(document)
            .unbind("Success").on("Success", function (sender, eventArgs) { $(".subscribers-notify").trigger("OnSuccessDelegate", [eventArgs]); })
            .unbind("Error").on("Error", function (sender, eventArgs) { $(".subscribers-notify").trigger("OnErrorDelegate", [eventArgs]); })
    };
    me.registerSubscribers = function () {
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
                // This is if the action succeeded, but we have trappable errors such as validation errors
                if (json.Success) {
                    $(document).trigger("Success", json);
                }
                else {
                    $(document).trigger("Error", json);
                }
            },
            "error": function (jqXHR, textStatus, errorThrown) {
                // This error handler is called if an unexpected status code is thrown from the call
                $(document).trigger("Error", JSON.parse(jqXHR.responseText));
            }
        });
    };
}