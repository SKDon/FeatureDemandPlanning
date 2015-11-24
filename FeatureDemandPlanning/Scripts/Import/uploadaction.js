"use strict";

var model = namespace("FeatureDemandPlanning.Import");

model.UploadAction = function (params, model) {
    var uid = 0;
    var privateStore = {};
    var me = this;

    privateStore[me.id = uid++] = {};
    privateStore[me.id].Config = params.Configuration;
    privateStore[me.id].ActionUri = params.UploadUri;
    privateStore[me.id].Parameters = params;
    privateStore[me.id].Model = model;

    me.action = function () {
        $("#Modal_OK").html("Uploading...Wait").attr("disabled", true);
        sendData(me.getActionUri(), me.getActionParameters());
    };
    me.getActionParameters = function () {
        var formData = new FormData();
        var model = getModel();
        
        formData.append("fileToUpload", model.getSelectedFile());
        formData.append("carLine", model.getSelectedCarLine());
        formData.append("modelYear", model.getSelectedModelYear());
        formData.append("gateway", model.getSelectedGateway());
       
        return formData;
    };
    me.getIdentifierPrefix = function () {
        return $("#Action_IdentifierPrefix").val();
    };
    me.getActionUri = function () {
        return privateStore[me.id].ActionUri;
    };
    me.getImportFile = function () {
        return getModel().getSelectedFile().name;
    };
    me.getParameters = function () {
        return privateStore[me.id].Parameters;
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
            .html("PPO File '" + me.getImportFile() + "' uploaded successfully")
            .show();
        $("#Modal_OK").hide();
        $("#Modal_Cancel").html("Close");
    };
    me.onErrorEventHandler = function (sender, eventArgs) {
        $("#Modal_OK").removeAttr("disabled").html("OK");
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
    function getModel() {
        return privateStore[me.id].Model;
    };
    function sendData(uri, params) {
        $.ajax({
            "async": true,
            "type": "POST",
            "url": uri,
            "data": params,
            "processData": false,
            "contentType": false,
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