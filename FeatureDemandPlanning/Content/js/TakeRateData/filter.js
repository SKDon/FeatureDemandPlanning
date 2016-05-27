"use strict";

var model = namespace("FeatureDemandPlanning.Volume");

model.Filter = function (params) {
    var uid = 0;
    var privateStore = {};
    var me = this;

    privateStore[me.id = uid++] = {};
    privateStore[me.id].Config = params.Configuration;
    privateStore[me.id].ModalContentUri = params.FilterUri;
    privateStore[me.id].ModalActionUri = null;
    privateStore[me.id].Parameters = params;
    privateStore[me.id].CurrentFilter = "";

    me.ModelName = "Filter";

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
            case 12:
                actionModel = new FeatureDemandPlanning.Volume.FilterAction(me.getParameters());
                break;
            default:
                break;
        }
        return actionModel;
    };
    me.getActionUri = function () {
        return privateStore[me.id].ModalActionUri;
    };
    me.getConfiguration = function () {
        return privateStore[me.id].Configuration;
    };
    me.getParameters = function () {
        return privateStore[me.id].Parameters;
    };
    me.getUpdateParameters = function() {
        return $.extend({}, getData(), {
        
        });
    };
    me.getCurrentFilter = function() {
        return privateStore[me.id].CurrentFilter;
    };
    me.setCurrentFilter = function(filter) {
        privateStore[me.id].CurrentFilter = filter;
        //$.jCookies({
        //    name: "Filter",
        //    value: filter
        //});
    };
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

