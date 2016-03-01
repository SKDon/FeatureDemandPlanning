"use strict";

var model = namespace("FeatureDemandPlanning.TakeRate");

model.TakeRates = function (params) {
	var uid = 0;
	var privateStore = {};
	var me = this;

	privateStore[me.id = uid++] = {};
	privateStore[me.id].Config = params.Configuration;
	privateStore[me.id].ActionsUri = params.ActionsUri;
	privateStore[me.id].TakeRatesUri = params.TakeRatesUri;
	privateStore[me.id].TakeRateUri = params.TakeRateUri;
	privateStore[me.id].TakeRateId = params.TakeRateId;
	privateStore[me.id].ModalContentUri = params.ModalContentUri;
	privateStore[me.id].ModalActionUri = params.ModalActionUri;
	privateStore[me.id].PageSize = params.PageSize;
	privateStore[me.id].PageIndex = params.PageIndex;
	privateStore[me.id].TotalPages = 0;
	privateStore[me.id].TotalRecords = 0;
	privateStore[me.id].TotalDisplayRecords = 0;
	privateStore[me.id].Parameters = params;

	me.ModelName = "TakeRates";

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
		return privateStore[me.id].PageIndex
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
	    switch (action) {
	        case 14:
	            return "Clone Take Rate File";
	    }
	    return "Take Rate Action";
	};
	me.getTakeRateUri = function () {
		return privateStore[me.id].TakeRateUri;
	};
	me.getTakeRatesUri = function () {
		return privateStore[me.id].TakeRatesUri;
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
	me.getActionsUri = function () {
		return privateStore[me.id].ActionsUri;
	};
	me.getActionModel = function (action) {
		var actionModel = null;
		switch (action) {
			case 14:
				actionModel = new FeatureDemandPlanning.Volume.CloneAction(me.getParameters());
				break;
			default:
				break;
		}
		return actionModel;
	};
	me.getActionContentUri = function (action) {
		return privateStore[me.id].ModalContentUri;
	};
	me.getParameters = function () {
		return privateStore[me.id].Parameters;
	};
	function genericErrorCallback(response) {
		if (response.status == 400) {
			var json = JSON.parse(response.responseText);
			privateStore[me.id].IsValid = false;
			$(document).trigger("Validation", [json]);
		} else {
			$(document).trigger("Error", response);
		}
	};
}

