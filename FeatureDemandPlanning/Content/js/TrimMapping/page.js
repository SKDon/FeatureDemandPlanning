"use strict";

var page = namespace("FeatureDemandPlanning.Trim");

page.TrimMappingsPage = function (models) {
    var uid = 0;
    var privateStore = {};
    var me = this;

    privateStore[me.id = uid++] = {};
    privateStore[me.id].DataTable = null;
    privateStore[me.id].Models = models;
    privateStore[me.id].SelectedCarLine = ""
    privateStore[me.id].SelectedCarLineDescription = "";
    privateStore[me.id].SelectedModelYear = "";
    privateStore[me.id].SelectedGateway = "";

    me.carLineSelectedEventHandler = function (sender) {
        me.setSelectedCarLine($(sender.target).attr("data-target"));
        me.setSelectedCarLineDescription($(sender.target).attr("data-content"));
        me.displaySelectedCarLine();
        me.filterModelYears();
        me.filterGateways();
        me.redrawDataTable();
    };
    me.displaySelectedCarLine = function () {
        $("#" + me.getIdentifierPrefix() + "_SelectedCarLine").html(me.getSelectedCarLineDescription());
    }
    me.displaySelectedModelYear = function () {
        var selectedModelYear = me.getSelectedModelYear();
        if (selectedModelYear == "") {
            selectedModelYear = "Select Model Year";
        }
        $("#" + me.getIdentifierPrefix() + "_SelectedModelYear").html(selectedModelYear);
    };
    me.displaySelectedGateway = function () {
        var selectedGateway = me.getSelectedGateway();
        if (selectedGateway == "") {
            selectedGateway = "Select Gateway";
        }
        $("#" + me.getIdentifierPrefix() + "_SelectedGateway").html(selectedGateway);
    };
    me.filterModelYears = function () {
        var selectedModelYear = $("#" + me.getIdentifierPrefix() + "_SelectedModelYear");
        var modelYearList = $("#" + me.getIdentifierPrefix() + "_ModelYearList")
        var modelYears = modelYearList
            .find("a.model-year-item")
            .hide()
            .filter("[data-filter='" + me.getSelectedCarLine() + "']")
            .show();

        if (modelYears.length == 0) {
            me.setSelectedModelYear("N/A");
            me.displaySelectedModelYear();
            selectedModelYear.attr("disabled", "disabled");
        }
        else {
            me.setSelectedModelYear("");
            me.displaySelectedModelYear();
            selectedModelYear.removeAttr("disabled");
        }
    };
    me.filterGateways = function () {
        var selectedGateway = $("#" + me.getIdentifierPrefix() + "_SelectedGateway");
        var gatewayList = $("#" + me.getIdentifierPrefix() + "_GatewayList")
        var gateways = gatewayList
            .find("a.gateway-item")
            .hide()
            .filter("[data-filter='" + me.getSelectedCarLine() + "']")
            .show();

        if (gateways.length == 0) {
            me.setSelectedGateway("N/A");
            me.displaySelectedGateway();
            selectedGateway.attr("disabled", "disabled");
        }
        else {
            me.setSelectedGateway("");
            me.displaySelectedGateway();
            selectedGateway.removeAttr("disabled");
        }
    };
    me.gatewaySelectedEventHandler = function (sender) {
        me.setSelectedGateway($(sender.target).attr("data-target"));
        me.displaySelectedGateway();
        me.redrawDataTable();
    };
    me.getSelectedCarLine = function () {
        return privateStore[me.id].SelectedCarLine;
    };
    me.getSelectedCarLineDescription = function () {
        return privateStore[me.id].SelectedCarLineDescription;
    };
    me.getSelectedModelYear = function () {
        return privateStore[me.id].SelectedModelYear;
    };
    me.getSelectedGateway = function () {
        return privateStore[me.id].SelectedGateway;
    };
    me.actionTriggered = function (invokedOn, action) {
        var eventArgs = {
            TrimMappingId: $(this).attr("data-target"),
            TrimCode: $(this).attr("data-content"),
            Action: parseInt($(this).attr("data-role"))
        };
        $(document).trigger("Action", eventArgs);
    }
    me.bindContextMenu = function () {
        $(".dataTable td").contextMenu({
            menuSelector: "#contextMenu",
            dynamicContent: me.getContextMenu,
            contentIdentifier: me.getTrimMappingId,
            menuSelected: me.actionTriggered
        });
    };
    me.configureDataTables = function () {

        var trimsUri = getTrimMappingModel().getTrimMappingsUri();
        var trimIndex = 0;
        var trimCodeIndex = 5;

        $(".dataTable").DataTable({
            "serverSide": true,
            "pagingType": "full_numbers",
            "ajax": me.getData,
            "processing": true,
            "sDom": "ltip",
            "aoColumns": [
                {
                    "sTitle": "",
                    "sName": "DERIVATIVE_ID",
                    "bSearchable": false,
                    "bSortable": false,
                    "bVisible": false
                }
                , {
                    "sTitle": "Created On",
                    "sName": "CREATED_ON",
                    "bSearchable": true,
                    "bSortable": true,
                    "sClass": "text-center"
                }
                , {
                    "sTitle": "Created By",
                    "sName": "CREATED_BY",
                    "bSearchable": true,
                    "bSortable": true
                }
                , {
                    "sTitle": "Programme",
                    "sName": "PROGRAMME",
                    "bSearchable": true,
                    "bSortable": true
                }
                , {
                    "sTitle": "Gateway",
                    "sName": "GATEWAY",
                    "bSearchable": true,
                    "bSortable": true,
                    "sClass": "text-center"
                }
                , {
                    "sTitle": "BMC",
                    "sName": "BMC",
                    "bSearchable": true,
                    "bSortable": true,
                    "sClass": "text-center"
                }
                , {
                    "sTitle": "Import Trim",
                    "sName": "DERIVATIVE",
                    "bSearchable": true,
                    "bSortable": true,
                    "sClass": "text-center"
                }
                , {
                    "sTitle": "Mapping",
                    "sName": "DERIVATIVE",
                    "bSearchable": true,
                    "bSortable": true,
                    "sClass": "text-center"
                }
                , {
                    "sTitle": "Level",
                    "sName": "LEVEL",
                    "bSearchable": true,
                    "bSortable": true,
                    "sClass": "text-center"
                }
                , {
                    "sTitle": "DPCK",
                    "sName": "DPCK",
                    "bSearchable": true,
                    "bSortable": true,
                    "sClass": "text-center"
                }
            ],
            "fnCreatedRow": function (row, data, index) {
                var trimMappingId = data[trimIndex];
                var trimCode = data[trimCodeIndex];
                $(row).attr("data-target", trimMappingId);
                $(row).attr("data-content", trimCode);
            },
            "fnDrawCallback": function (oSettings) {
                //$(document).trigger("Results", me.getSummary());
                me.bindContextMenu();
            }
        });
    };
    me.getContextMenu = function (trimMappingId) {
        var params = { TrimMappingId: trimMappingId };
        $("#contextMenu").html("");
        $.ajax({
            "dataType": "html",
            "async": true,
            "type": "POST",
            "url": getTrimMappingModel().getActionsUri(),
            "data": params,
            "success": function (response) {
                $("#contextMenu").html(response);
            },
            "error": function (jqXHR, textStatus, errorThrown) {
                alert(errorThrown);
            }
        });
    };
    me.getDataTable = function () {
        if (privateStore[me.id].DataTable == null) {
            me.configureDataTables();
        }
        return privateStore[me.id].DataTable;
    };
    me.getData = function (data, callback, settings) {
        var params = me.getParameters(data);
        var model = getTrimMappingModel();
        var uri = model.getTrimMappingsUri();
        settings.jqXHR = $.ajax({
            "dataType": "json",
            "type": "POST",
            "url": uri,
            "data": params,
            "success": function (json) {
                callback(json);
                me.updatePaging();
                me.updateTotals();
            }
        });
    };
    me.getFilterMessage = function () {
        return $("#" + me.getIdentifierPrefix() + "_FilterMessage").val();
    };
    me.getIdentifierPrefix = function () {
        return $("#Page_IdentifierPrefix").val();
    };
    me.getParameters = function (data) {
        var filter = getFilter();
        var params = $.extend({}, data, {
            "TrimMappingId": me.getTrimMappingId(),
            "CarLine": me.getSelectedCarLine(),
            "ModelYear": me.getSelectedModelYear(),
            "Gateway": me.getSelectedGateway(),
            "FilterMessage": me.getFilterMessage()
        });
        return params;
    };
    me.getTrimMappingId = function (cell) {
        return $(cell).closest("tr").attr("data-target");
    };
    me.getTrimCode = function (cell) {
        return $(cell).closest("tr").attr("data-content");
    };
    me.initialise = function () {
        me.registerEvents();
        me.registerSubscribers();

        $(privateStore[me.id].Models).each(function () {
            this.initialise();
        });
        me.loadData();
        me.filterModelYears();
        me.filterGateways();
    };
    me.loadData = function () {
        me.configureDataTables(getFilter());
    };
    me.modelYearSelectedEventHandler = function (sender) {
        me.setSelectedModelYear($(sender.target).attr("data-target"));
        me.displaySelectedModelYear();
        me.filterGateways();
        me.redrawDataTable();
    };
    me.onActionEventHandler = function (sender, eventArgs) {
        var action = eventArgs.Action;
        var model = getModelForAction(action);
        var actionModel = model.getActionModel(action);

        if (actionModel.isModalAction()) {
            getModal().showModal({
                Title: model.getActionTitle(action, eventArgs.TrimCode),
                Uri: model.getActionContentUri(action),
                Data: JSON.stringify(eventArgs),
                Model: model,
                ActionModel: actionModel
            });
        }
        else {
            actionModel.actionImmediate(eventArgs);
        }
    };
    me.onFilterChangedEventHandler = function (sender, eventArgs) {
        var filter = $("#" + me.getIdentifierPrefix() + "_FilterMessage").val();
        var filterLength = filter.length;
        if (filterLength === 0 || filterLength > 2) {
            me.redrawDataTable();
        }
    };
    me.onSuccessEventHandler = function (sender, eventArgs) {
        me.redrawDataTable();
    };
    me.redrawDataTable = function () {
        $(".dataTable").DataTable().draw();
    };
    me.registerEvents = function () {
        var prefix = me.getIdentifierPrefix();

        $(document)
            .unbind("Success").on("Success", function (sender, eventArgs) { $(".subscribers-notify").trigger("OnSuccessDelegate", [eventArgs]); })
            .unbind("Error").on("Error", function (sender, eventArgs) { $(".subscribers-notify").trigger("OnErrorDelegate", [eventArgs]); })
            .unbind("Results").on("Results", function (sender, eventArgs) { $(".subscribers-notify").trigger("OnResultsDelegate", [eventArgs]); })
            .unbind("Updated").on("Updated", function (sender, eventArgs) { $(".subscribers-notify").trigger("OnUpdatedDelegate", [eventArgs]); })
            .unbind("Action").on("Action", function (sender, eventArgs) { $(".subscribers-notify").trigger("OnActionDelegate", [eventArgs]); })
            .unbind("ModalLoaded").on("ModalLoaded", function (sender, eventArgs) { $(".subscribers-notify").trigger("OnModalLoadedDelegate", [eventArgs]); })
            .unbind("ModalOk").on("ModalOk", function (sender, eventArgs) { $(".subscribers-notify").trigger("OnModalOkDelegate", [eventArgs]); })

        $("#" + prefix + "_CarLineList").find("a.car-line-item").on("click", function (e) {
            me.carLineSelectedEventHandler(e);
            e.preventDefault();
        });
        $("#" + prefix + "_ModelYearList").find("a.model-year-item").on("click", function (e) {
            me.modelYearSelectedEventHandler(e);
            e.preventDefault();
        });
        $("#" + prefix + "_GatewayList").find("a.gateway-item").on("click", function (e) {
            me.gatewaySelectedEventHandler(e);
            e.preventDefault();
        });
    };
    me.registerSubscribers = function () {
        var prefix = me.getIdentifierPrefix();

        $("#notifier")
            .unbind("OnSuccessDelegate").on("OnSuccessDelegate", me.onSuccessEventHandler)
            .unbind("OnErrorDelegate").on("OnErrorDelegate", me.onErrorEventHandler)
            .unbind("OnUpdatedDelegate").on("OnUpdatedDelegate", me.onUpdatedEventHandler)
            .unbind("OnFilterCompleteDelegate").on("OnFilterCompleteDelegate", me.onFilterCompleteEventHandler)
            .unbind("OnActionDelegate").on("OnActionDelegate", me.onActionEventHandler)
            .unbind("OnModalLoadedDelegate").on("OnModalLoadedDelegate", me.onModalLoadedEventHandler)
            .unbind("OnModalOkDelegate").on("OnModalOkDelegate", me.onModalOKEventHandler);

        $("#" + prefix + "_FilterMessage").on("keyup", me.onFilterChangedEventHandler);
    };
    me.setDataTable = function (dataTable) {
        privateStore[me.id].DataTable = dataTable
    };
    me.setSelectedCarLine = function (carLine) {
        privateStore[me.id].SelectedCarLine = carLine;
    };
    me.setSelectedCarLineDescription = function (carLine) {
        privateStore[me.id].SelectedCarLineDescription = carLine;
    };
    me.setSelectedModelYear = function (modelYear) {
        privateStore[me.id].SelectedModelYear = modelYear;
    };
    me.setSelectedGateway = function (gateway) {
        privateStore[me.id].SelectedGateway = gateway;
    };
    me.updatePaging = function () {
        var info = $(".dataTable").DataTable().page.info();
        var prefix = me.getIdentifierPrefix();
        var pageIndex = info.page + 1;
        var totalPages = info.pages;
        var total = info.recordsTotal;
        $(".results-paging").html("Page " + pageIndex + " of " + totalPages);
    };
    me.updateTotals = function () {
        var info = $(".dataTable").DataTable().page.info();
        var prefix = me.getIdentifierPrefix();
        var total = info.recordsTotal;
        $(".results-total").html(total + " Mapped Trim Levels");
    }
    function getModal() {
        return getModel("Modal");
    };
    function getModelForAction(actionId) {
        return getTrimMappingModel();
    }
    function getModels() {
        return privateStore[me.id].Models;
    };
    function getModel(modelName) {
        var model = null;
        $(getModels()).each(function () {
            if (this.ModelName == modelName) {
                model = this;
                return false;
            }
        });
        return model;
    };
    function getTrimMappingModel() {
        return getModel("TrimMapping");
    };
    function getFilter(pageSize, pageIndex) {
        var model = getTrimMappingModel();
        var pageSize = model.getPageSize();
        var pageIndex = model.getPageIndex();
        var filter = new FeatureDemandPlanning.Trim.TrimMappingFilter();

        filter.PageIndex = pageIndex;
        filter.PageSize = pageSize;

        return filter;
    }
}