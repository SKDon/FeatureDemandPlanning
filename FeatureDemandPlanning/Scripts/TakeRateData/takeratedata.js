"use strict";

var model = namespace("FeatureDemandPlanning.TakeRate");

model.TakeRateDataFilter = function () {
    var me = this;
    me.CDSId = "";
    me.FilterMessage = "";
    me.HideInactiveUsers = true;
};
model.TakeRateData = function (params) {
    var uid = 0;
    var privateStore = {};
    var me = this;

    privateStore[me.id = uid++] = {};
    privateStore[me.id].TakeRateDataUri = params.TakeRateDataUri;
    privateStore[me.id].ActionsUri = params.ActionsUri;
    privateStore[me.id].Configuration = params.Configuration;
    privateStore[me.id].ModalContentUri = params.ModalContentUri;
    privateStore[me.id].ModalActionUri = params.ModalActionUri;
    privateStore[me.id].PageSize = params.PageSize;
    privateStore[me.id].PageIndex = params.PageIndex;
    privateStore[me.id].Parameters = params;

    me.ModelName = "TakeRateData";

    me.getActionContentUri = function () {
        return privateStore[me.id].ModalContentUri;
    };
    me.getActionModel = function () {
        return null;
    };
    me.getActionTitle = function () {
        return "Action Title";
    };
    me.getActionsUri = function () {
        return privateStore[me.id].ActionsUri;
    };
    me.getActionUri = function () {
        return privateStore[me.id].ModalActionUri;
    };
    me.getConfiguration = function () {
        return privateStore[me.id].Configuration;
    };
    me.getPageSize = function () {
        return privateStore[me.id].PageSize;
    };
    me.getPageIndex = function () {
        return privateStore[me.id].PageIndex;
    };
    me.getParameters = function () {
        return privateStore[me.id].Parameters;
    };
    me.getTakeRateDataUri = function () {
        return privateStore[me.id].TakeRateDataUri;
    };
    me.initialise = function () {
        $(document).trigger("notifySuccess", me);
    };
}

