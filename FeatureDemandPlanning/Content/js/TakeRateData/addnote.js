"use strict";

var model = namespace("FeatureDemandPlanning.Volume");

model.AddNote = function(params) {
    var uid = 0;
    var privateStore = {};
    var me = this;

    privateStore[me.id = uid++] = {};
    privateStore[me.id].Config = params.Configuration;
    privateStore[me.id].ModalContentUri = params.ModalContentUri;
    privateStore[me.id].ModalActionUri = params.ModalActionUri;
    privateStore[me.id].Parameters = params;

    me.ModelName = "AddNote";

    me.initialise = function() {
    };
    me.getActionContentUri = function () {
        return privateStore[me.id].ModalContentUri;
    };
    me.getActionModel = function (action) {
        var actionModel = null;
        switch (action) {
            case 8:
                actionModel = new FeatureDemandPlanning.Volume.AddNoteAction(me.getParameters());
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
        return "Add Note";
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
    me.getVehicleId = function () {
        return getData().VehicleId;
    };
    me.setParameters = function (parameters) {
        privateStore[me.id].Parameters = parameters;
    };
    function getData() {
        var params = me.getParameters();
        if (params.Data != undefined)
            return JSON.parse(me.getParameters().Data);

        return {};
    };
}

