"use strict";

var model = namespace("FeatureDemandPlanning.Volume");

model.MarketReview = function (params) {
    var uid = 0;
    var privateStore = {};
    var me = this;

    privateStore[me.id = uid++] = {};
    privateStore[me.id].Config = params.Configuration;
    privateStore[me.id].ModalContentUri = params.MarketReviewConfirmUri;
    privateStore[me.id].ModalActionUri = params.MarketReviewUri;
    privateStore[me.id].Parameters = params;
    privateStore[me.id].MarketReviewStatus = null;

    me.ModelName = "MarketReview";

    me.initialise = function () {
    };
    me.getActionContentUri = function (action) {
        return privateStore[me.id].ModalContentUri;
    };
    me.getActionModel = function (action) {
        var actionModel = null;
        switch (action) {
            case 11:
                actionModel = new FeatureDemandPlanning.Volume.MarketReviewAction(me.getParameters());
                actionModel.setMarketReviewStatus(me.getMarketReviewStatus());
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
        return "Market Review";
    };
    me.getConfiguration = function () {
        return privateStore[me.id].Configuration;
    };
    me.getMarketReviewAction = function () {
        return 11; // Market Review
    };
    me.getMarketReviewStatus = function() {
        return privateStore[me.id].MarketReviewStatus;
    };
    me.setMarketReviewStatus = function(marketReviewStatus) {
        privateStore[me.id].MarketReviewStatus = marketReviewStatus;
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

