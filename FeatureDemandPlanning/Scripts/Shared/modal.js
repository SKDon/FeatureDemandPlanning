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
    privateStore[me.id].ModelConfiguration = {};
    privateStore[me.id].Config = params.Configuration;
    privateStore[me.id].Model = {};

    me.ModelName = "Modal";

    me.getData = function () {
        return JSON.parse(me.getModalConfiguration().data);
    };
    me.getModalDialogId = function () {
        return privateStore[me.id].ModalDialogId;
    };
    me.getModalConfiguration = function () {
        return privateStore[me.id].ModalConfiguration;
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
    }
    me.registerEvents = function () {
        var dialog = $("#" + me.getModalDialogId());
        dialog.find(".modal-button").unbind("click").on("click", me.raiseEvents)
    };
    me.setModel = function (model) {
        privateStore[me.id].Model = model;
    };
    me.setModalConfiguration = function (modalConfiguration) {
        privateStore[me.id].ModalConfiguration = modalConfiguration;
    };
    me.showModal = function (modalConfiguration) {
        var dialog = $("#" + me.getModalDialogId());
        dialog.find(".modal-title").html("");
        dialog.find(".modal-body").html("");
        me.setModalConfiguration(modalConfiguration);
        me.setModel(modalConfiguration.model);
        $("#" + me.getModalDialogId()).unbind("show.bs.modal").on('show.bs.modal', function () {
            me.getModelContent(modalConfiguration.title, modalConfiguration.uri, modalConfiguration.data);
        }).modal();
    };
    function showModalCallback(response, title) {
        var dialog = $("#" + me.getModalDialogId());
        dialog.find(".modal-title").html(title);
        dialog.find(".modal-body").html(response);
        me.getModel().initialise(me.getData());
        me.registerEvents();
    };
    function showModalError(jqXHR, textStatus, errorThrown) {
        var dialog = $("#" + me.getModalDialogId());
        dialog.find(".modal-title").html("Error");
        dialog.find(".modal-body").html(errorThrown);
    }
};