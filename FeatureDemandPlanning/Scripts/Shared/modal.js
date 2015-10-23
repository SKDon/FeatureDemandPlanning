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

    me.ModelName = "Modal";

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
        if (target.attr("id") == "btnModalOk") {
            $(document).trigger("ModalOk", [eventArgs]);
        } else {
            $(document).trigger("ModalCancel", [eventArgs]);
        }
    };
    me.raiseLoadedEvent = function () {
        $(document).trigger("ModalLoaded", me.getData());
    };
    me.registerEvents = function () {
        var dialog = $("#" + me.getModalDialogId());
        dialog.find(".modal-button").unbind("click").on("click", me.raiseEvents)
    };
    me.setModel = function (model) {
        privateStore[me.id].Model = model;
    };
    me.showModal = function (parameters) {
        var dialog = $("#" + me.getModalDialogId());
        dialog.find(".modal-title").html("");
        dialog.find(".modal-body").html("");
        me.setModalParameters(parameters);
        me.setModel(parameters.Model);
        $("#" + me.getModalDialogId()).unbind("show.bs.modal").on('show.bs.modal', function () {
            me.getModelContent(parameters.Title, parameters.Uri, parameters.Data);
        }).modal();
    };
    function showModalCallback(response, title) {
        var dialog = $("#" + me.getModalDialogId());
        var model = me.getModel();

        dialog.find(".modal-title").html(title);
        dialog.find(".modal-body").html(response);

        model.setParameters(me.getModalParameters());
        model.initialise();

        me.registerEvents();
        me.raiseLoadedEvent();
    };
    function showModalError(jqXHR, textStatus, errorThrown) {
        var dialog = $("#" + me.getModalDialogId());
        dialog.find(".modal-title").html("Error");
        dialog.find(".modal-body").html(errorThrown);
    }
};