"use strict";

var model = namespace("FeatureDemandPlanning.Import");

model.Process = function (params) {
    var uid = 0;
    var privateStore = {};
    var me = this;

    privateStore[me.id = uid++] = {};
    privateStore[me.id].Config = params.Configuration;
    privateStore[me.id].ModalContentUri = params.ModalContentUri;
    privateStore[me.id].ModalActionUri = params.ModalActionUri;
    privateStore[me.id].ProcessDataUri = params.ProcessDataUri;
    privateStore[me.id].Parameters = params;
    
    me.ModelName = "Process";

    me.initialise = function () {
        //me.listAvailableFeatures();
    };
    me.getActionContentUri = function (action) {
        return privateStore[me.id].ModalContentUri;
    };
    me.getActionModel = function (action) {
        var actionModel = null;
        switch (action) {
            case 17:
                actionModel = new FeatureDemandPlanning.Import.ProcessDataAction(me.getParameters());
                break;
            default:
                break;
        }
        return actionModel;
    };
    me.getActionUri = function (action) {
        return privateStore[me.id].ModalActionUri;
    };
    me.getActionTitle = function (action) {
        var title = "";
        switch (action) {
            case 17:
                title = "Process Take Rate Data";
                break;
            default:
                break;
        }
        return title;
    };
    me.getProcessDataUri = function () {
        return privateStore[me.id].ProcessDataUri;
    };
    me.getConfiguration = function () {
        return privateStore[me.id].Configuration;
    };
    me.getParameters = function () {
        return privateStore[me.id].Parameters;
    };
    me.getUpdateParameters = function() {
        getData();
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

