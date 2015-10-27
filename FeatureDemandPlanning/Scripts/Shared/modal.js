"use strict";

/* Provides generic modal dialog functionality for a page */

var model = namespace("FeatureDemandPlanning.Modal");

model.Modal = function (params) {
    var uid = 0;
    var privateStore = {};
    var me = this;

    privateStore[me.id = uid++] = {};
    privateStore[me.id].ModalDialogId = params.ModalDialogId;
    privateStore[me.id].ModalContentId = params.ModalContentId;
    privateStore[me.id].ModelParameters = {};
    privateStore[me.id].Config = params.Configuration;
    privateStore[me.id].Model = {};
    privateStore[me.id].ActionModel = {};

    me.ModelName = "Modal";

    me.getActionModel = function () {
        return privateStore[me.id].ActionModel;
    }
    me.getData = function () {
        return JSON.parse(me.getModalParameters().Data);
    };
    me.getModalDialogId = function () {
        return privateStore[me.id].ModalDialogId;
    };
    me.getConfiguration = function () {
        return privateStore[me.id].Configuration;
    };
    me.getModalParameters = function () {
        return privateStore[me.id].ModalParameters;
    };
    me.setActionModel = function (model) {
        return privateStore[me.id].ActionModel;
    }
    me.setModalParameters = function (parameters) {
        privateStore[me.id].ModalParameters = parameters;
    };
    me.getModelContent = function (title, contentUri, data) {
        $.ajax({
            url: contentUri,
            method: "POST",
            async: true,
            dataType: "html",
            contentType: "application/json",
            data: data,
            success: function (response, status, jqXHR) {
                showModalCallback(response, title);
            },
            error: showModalError
        });
    };
    me.getModel = function () {
        return privateStore[me.id].Model;
    };
    me.initialise = function () {
    };
    me.raiseEvents = function (sender, eventArgs) {
        var target = $(sender.target);
        var params = me.getModel().getUpdateParameters();
        if (target.attr("id") == "btnModalOk") {
            $(document).trigger("ModalOk", [params]);
        } else {
            $(document).trigger("ModalCancel", []);
        }
    };
    me.raiseLoadedEvent = function () {
        $(document).trigger("ModalLoaded", me.getData());
    };
    me.registerEvents = function () {
    };
    me.setActionModel = function (model) {
        privateStore[me.id].ActionModel = model;
    };
    me.setModel = function (model) {
        privateStore[me.id].Model = model;
    };
    me.showModal = function (parameters) {
        var dialog = $("#" + me.getModalDialogId());
        var content = dialog.find("#Modal_Content");
        var title = dialog.find("#Modal_Title");
        var notifier = dialog.find("#Modal_Notify");

        content.html("");
        title.html("");
        notifier.html("").hide();

        me.setModalParameters(parameters);
        me.setModel(parameters.Model);
        me.setActionModel(parameters.ActionModel);

        dialog
            .unbind("show.bs.modal").on('show.bs.modal', function () {
                me.getModelContent(parameters.Title, parameters.Uri, parameters.Data);
            })
            .modal();

        $("#Modal_OK").show();
        $("#Modal_Cancel").html("Cancel");
    };
    function showModalCallback(response, title) {
        var dialog = $("#" + me.getModalDialogId());
        var content = dialog.find("#Modal_Content");
        var tit = dialog.find("#Modal_Title");
        var model = me.getModel();
        var actionModel = me.getActionModel();

        tit.html(title);
        content.html(response);

        model.initialise();
        actionModel.setParameters(me.getModalParameters());
        actionModel.initialise();

        me.registerEvents();
        me.raiseLoadedEvent();
    };
    function showModalError(jqXHR, textStatus, errorThrown) {
        var dialog = $("#" + me.getModalDialogId());
        dialog.find("#Modal_Title").html("Error");
        dialog.find("#Modal_Content").html(jqXHR.responseText);
    }
};