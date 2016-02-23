"use strict";

var model = namespace("FeatureDemandPlanning.Volume");

model.History = function (params) {
    var uid = 0;
    var privateStore = {};
    var me = this;

    privateStore[me.id = uid++] = {};
    privateStore[me.id].Config = params.Configuration;
    privateStore[me.id].ModalContentUri = params.PersistChangesetConfirmUri;
    privateStore[me.id].ModalActionUri = params.PersistChangesetUri;
    privateStore[me.id].Parameters = params;

    me.ModelName = "History";

    me.initialise = function () {
    };
    me.getActionContentUri = function (action) {
        return privateStore[me.id].ModalContentUri;
    };
    me.getFilterAction = function() {
        return 12;
    };
    me.getActionModel = function (action) {
        var actionModel = null;
        switch (action) {
            case 7:
                actionModel = new FeatureDemandPlanning.Volume.HistoryAction(me.getParameters());
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
        return "Change History";
    };
    me.getConfiguration = function () {
        return privateStore[me.id].Configuration;
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

