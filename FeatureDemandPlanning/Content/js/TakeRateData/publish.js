"use strict";

var model = namespace("FeatureDemandPlanning.Volume");

model.Publish = function (params) {
    var uid = 0;
    var privateStore = {};
    var me = this;

    privateStore[me.id = uid++] = {};
    privateStore[me.id].Config = params.Configuration;
    privateStore[me.id].ModalContentUri = params.PublishConfirmUri;
    privateStore[me.id].ModalActionUri = params.PublishUri;
    privateStore[me.id].Parameters = params;

    me.ModelName = "Publish";

    me.initialise = function () {
    };
    me.getActionContentUri = function (action) {
        return privateStore[me.id].ModalContentUri;
    };
    me.getActionModel = function (action) {
        var actionModel = null;
        switch (action) {
            case 18:
                actionModel = new FeatureDemandPlanning.Volume.PublishAction(me.getParameters());
                break;
            default:
                break;
        }
        return actionModel;
    };
    me.getActionUri = function () {
        return privateStore[me.id].ModalActionUri;
    };
    me.getActionTitle = function () {
        return "Publish";
    };
    me.getConfiguration = function () {
        return privateStore[me.id].Configuration;
    };
    me.getPublishAction = function () {
        return 18; // Market Review
    };
    me.getParameters = function () {
        return privateStore[me.id].Parameters;
    };
    me.getUpdateParameters = function () {
        return $.extend({}, getData(), {
        });
    }
    me.setParameters = function (parameters) {
        privateStore[me.id].Parameters = parameters;
    };
    function getData() {
        var p = me.getParameters();
        if (p.Data != undefined)
            return JSON.parse(p.Data);

        return {};
    };
}

