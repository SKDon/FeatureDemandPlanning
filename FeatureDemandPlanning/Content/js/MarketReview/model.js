"use strict";

var model = namespace("FeatureDemandPlanning.MarketReview");

model.MarketReview = function (params) {
    var uid = 0;
    var privateStore = {};
    var me = this;

    privateStore[me.id = uid++] = {};
    privateStore[me.id].Config = params.Configuration;
    privateStore[me.id].MarketReviewsUri = params.MarketReviewsUri;
    privateStore[me.id].TakeRateUri = params.TakeRateUri;
    privateStore[me.id].TakeRateId = params.TakeRateId;
    privateStore[me.id].PageSize = params.PageSize;
    privateStore[me.id].PageIndex = params.PageIndex;
    privateStore[me.id].TotalPages = 0;
    privateStore[me.id].TotalRecords = 0;
    privateStore[me.id].TotalDisplayRecords = 0;

    me.ModelName = "MarketReview";

    me.initialise = function () {
        var me = this;
        $(document).trigger("notifySuccess", me);
    };
    me.filterResults = function () {
        $(document).trigger("FilterComplete");
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
    me.getActionsUri = function () {
        return privateStore[me.id].ActionsUri;
    };
    me.getActionContentUri = function (action) {
        return "";
    };
    me.getProcessActionUri = function (action) {
        return "";
    };
    me.getActionTitle = function (action) {
        return "Market Review Action";
    };
    me.getTakeRateUri = function () {
        return privateStore[me.id].TakeRateUri;
    };
    me.getMarketReviewsUri = function () {
        return privateStore[me.id].MarketReviewsUri;
    };
    me.getTakeRateId = function () {
        return privateStore[me.id].TakeRateId;
    };
    me.getTotalPages = function () {
        return privateStore[me.id].TotalPages;
    };
    me.getTotalRecords = function () {
        return privateStore[me.id].TotalRecords;
    };
    me.getTotalDisplayRecords = function () {
        return privateStore[me.id].TotalDisplayRecords;
    };
    me.setPageIndex = function (pageIndex) {
        privateStore[me.id].PageIndex = pageIndex;
    };
    me.setPageSize = function (pageSize) {
        privateStore[me.id].PageSize = pageSize;
    };
    me.setTotalPages = function (totalPages) {
        privateStore[me.id].TotalPages = totalPages;
    };
    me.setTotalRecords = function (totalRecords) {
        privateStore[me.id].TotalRecords = totalRecords;
    };
    me.setTotalDisplayRecords = function (totalDisplayRecords) {
        privateStore[me.id].TotalDisplayRecords = totalDisplayRecords;
    };
}

