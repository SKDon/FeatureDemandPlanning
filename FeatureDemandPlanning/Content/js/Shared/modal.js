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
    me.setActionModel = function () {
        return privateStore[me.id].ActionModel;
    }
    me.setModalParameters = function (parameters) {
        privateStore[me.id].ModalParameters = parameters;
    };
    me.getModelContent = function (title, contentUri, data) {
        var dialog = $("#" + me.getModalDialogId());
        var tit = dialog.find("#Modal_Title");
        tit.html(title);
        
        $.ajax({
            url: contentUri,
            method: "POST",
            async: true,
            dataType: "html",
            contentType: "application/json",
            data: data,
            success: function (response) {
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
    me.raiseLoadedEvent = function () {
        $(document).trigger("ModalLoaded", me.getData());
    };
    me.registerEvents = function () {
    };
    me.registerConfirmEvents = function(confirmCallback) {
        $("#Modal_OK").on("click", function () {
            $("#" + me.getModalDialogId()).modal("hide");
            confirmCallback(me.getModalParameters().Data);
        });
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
        var ok = dialog.find("#Modal_OK");
        var cancel = dialog.find("#Modal_Cancel");

        content.html("");
        title.html("");
        notifier.html("").hide();

        me.setModalParameters(parameters);
        me.setModel(parameters.Model);
        me.setActionModel(parameters.ActionModel);

        dialog
            .unbind("shown.bs.modal").on("shown.bs.modal", function () {
                me.getModelContent(parameters.Title, parameters.Uri, parameters.Data);
            })
            .modal({
                backdrop: "static",
                keyboard: false
            });

        ok.html("OK").show();
        cancel.html("Cancel");
    };
    me.showConfirm = function(title, message, confirmCallback) {
        var dialog = $("#" + me.getModalDialogId());
        dialog
            .unbind("shown.bs.modal").on("shown.bs.modal", function () {
                me.getConfirmContent(title, message, confirmCallback);
            })
            .modal({
                backdrop: "static",
                keyboard: false
            });

        $("#Modal_OK").show();
        $("#Modal_Cancel").html("Cancel");
    };
    me.showAlert = function(title, message, type) {
        var dialog = $("#" + me.getModalDialogId());
        dialog
            .unbind("shown.bs.modal").on("shown.bs.modal", function () {
                me.getAlertContent(title, message, type);
            })
            .modal({
                backdrop: "static",
                keyboard: false
            });

        $("#Modal_OK").hide();
        $("#Modal_Cancel").html("OK");
    }
    me.showConfirmExtended = function(title, contentFn, confirmCallback) {
        contentFn(title, confirmCallback);
    };
    me.getConfirmContent = function(title, message, confirmCallback) {
        var dialog = $("#" + me.getModalDialogId());
        var content = dialog.find("#Modal_Content");
        var titleSelector = dialog.find("#Modal_Title");
        var notifier = dialog.find("#Modal_Notify");
        titleSelector.html(title);

        content.html(me.getConfirmHtml(message));
        titleSelector.html(title);
        notifier.html("").hide();

        me.registerConfirmEvents(confirmCallback);
    };
    me.getAlertContent = function(title, message, type) {
        var dialog = $("#" + me.getModalDialogId());
        var content = dialog.find("#Modal_Content");
        var titleSelector = dialog.find("#Modal_Title");
        var notifier = dialog.find("#Modal_Notify");
        titleSelector.html(title);

        switch (type) {
            case 1:
                content.html(me.getAlertInfoHtml(message));
                break;
            case 2:
                content.html(me.getAlertWarningHtml(message));
                break;
            case 3:
                content.html(me.getAlertSuccessHtml(message));
                break;
            default:
                content.html(me.getAlertInfoHtml(message));
                break;
        }
        
        titleSelector.html(title);
        notifier.html("").hide();
    };
    me.getConfirmHtml = function(message) {
        return "<div class=\"alert alert-info alert-less-margin\">" + message + "</div>";
    };
    me.getConfirmExtendedHtml = function(message, additionalContent) {
        return "<div class=\"alert alert-info alert-less-margin\">" + message + "</div><div>" + additionalContent + "</div>";
    };
    me.getAlertInfoHtml = function(message) {
        return "<div class=\"alert alert-info alert-less-margin\">" + message + "</div>";
    };
    me.getAlertSuccessHtml = function (message) {
        return "<div class=\"alert alert-success alert-less-margin\">" + message + "</div>";
    };
    me.getAlertWarningHtml = function (message) {
        return "<div class=\"alert alert-warning alert-less-margin\">" + message + "</div>";
    };
    function showModalCallback(response) {
        var dialog = $("#" + me.getModalDialogId());
        var content = dialog.find("#Modal_Content");
        
        var model = me.getModel();
        var actionModel = me.getActionModel();

        content.html(response);

        model.initialise();
        if (actionModel != null) {
            actionModel.setParameters(me.getModalParameters());
            actionModel.initialise();
        }

        me.registerEvents();
        me.raiseLoadedEvent();
    };
    function showModalError(jqXhr) {
        var dialog = $("#" + me.getModalDialogId());
        dialog.find("#Modal_Title").html("Error");
        dialog.find("#Modal_Content").html(jqXhr.responseText);
    }
};