"use strict";

var model = namespace("FeatureDemandPlanning.Volume");

model.AddNoteAction = function (params) {
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
    me.getActionParameters = function () {
        var actionParameters = getData();
        $.extend(actionParameters, { Comment: me.getComment() });
        return actionParameters;
    };
    me.getChangeset = function () {
        return getData().Changeset;
    };
    me.getIdentifierPrefix = function () {
        return $("#Action_IdentifierPrefix").val();
    };
    me.getActionUri = function () {
        return privateStore[me.id].ActionUri;
    };
    me.getComment = function () {
        return $("#" + me.getIdentifierPrefix() + "_NoteText").val().trim();
    };
    me.getParameters = function () {
        return privateStore[me.id].Parameters;
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
            .html("Note added successfully")
            .show();
        $("#Modal_OK").hide();
        $("#Modal_Cancel").html("Close");
        $(document).trigger("NoteAdded");
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
            "error": function (jqXHR, textStatus, errorThrown) {
                $(document).trigger("Error", jqXHR.responseJSON);
            }
        });
    };
}