"use strict";

var page = namespace("FeatureDemandPlanning.Dpck");

page.DpckPage = function (models) {
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
    privateStore[me.id].SelectedDocument = "";
    privateStore[me.id].SelectedDocument = null;
    privateStore[me.id].SelectedDocumentDescription = "";
    privateStore[me.id].SaveData = null;
    privateStore[me.id].EditedCell = null;
    privateStore[me.id].OriginalValue = null;

    me.carLineSelectedEventHandler = function (sender) {
        me.setSelectedCarLine($(sender.target).attr("data-target"));
        me.setSelectedCarLineDescription($(sender.target).attr("data-content"));
        me.displaySelectedCarLine();
        me.filterModelYears();
        me.filterGateways();
        me.filterDocuments();
        me.redrawDataTable();
    };
    me.documentSelectedEventHandler = function (sender) {
        me.setSelectedDocument($(sender.target).attr("data-target"));
        me.setSelectedDocumentDescription($(sender.target).attr("data-content"));
        me.displaySelectedCarLine();
        me.filterModelYears();
        me.filterGateways();
        me.filterDocuments();
        me.redrawDataTable();
    };
    me.displaySelectedCarLine = function() {
        $("#" + me.getIdentifierPrefix() + "_SelectedCarLine").html(me.getSelectedCarLineDescription());
    };
    me.displaySelectedDocument = function () {
        $("#" + me.getIdentifierPrefix() + "_SelectedDocument").html(me.getSelectedDocumentDescription());
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
        var gatewayList = $("#" + me.getIdentifierPrefix() + "_GatewayList");
        var gateways = gatewayList
            .find("a.gateway-item")
            .hide()
            .filter("[data-filter='" + me.getSelectedCarLine() + "']")
            .show();

        if (gateways.length === 0) {
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
    me.filterDocuments = function () {
        var selectedDocument = $("#" + me.getIdentifierPrefix() + "_SelectedDocument");
        var documentList = $("#" + me.getIdentifierPrefix() + "_DocumentList");
        var documents = documentList
            .find("a.document-item")
            .hide()
            .filter("[data-filter='" + me.getSelectedCarLine() + "|" + me.getSelectedModelYear() + "|" + me.getSelectedGateway() + "']")
            .show();

        if (documents.length === 0) {
            me.setSelectedDocument("N/A");
            me.displaySelectedDocument();
            selectedDocument.attr("disabled", "disabled");
        }
        else {
            me.setSelectedDocument("");
            me.displaySelectedDocument();
            selectedDocument.removeAttr("disabled");
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
    me.getSelectedDocument = function() {
        return privateStore[me.id].SelectedDocument;
    };
    me.getSelectedDocumentDescription = function() {
        return privateStore[me.id].SelectedDocumentDescription;
    };
    me.getSelectedModelYear = function () {
        return privateStore[me.id].SelectedModelYear;
    };
    me.getSelectedGateway = function () {
        return privateStore[me.id].SelectedGateway;
    };
    me.configureDataTables = function () {

        var trimIdentifierIndex = 0;
        var dpckCodeIndex = 4;

        $(".dataTable").DataTable({
            "serverSide": true,
            "pagingType": "full_numbers",
            "ajax": me.getData,
            "processing": true,
            "sDom": "ltip",
            "aoColumns": [
                  {
                      "sTitle": "TrimIdentifier",
                      "sName": "TRIM_IDENTIFIER",
                      "bSearchable": false,
                      "bVisible": false
                  },
                 {
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
                    "sTitle": "Document",
                    "sName": "DOCUMENT",
                    "bSearchable": true,
                    "bSortable": true
                }
                , {
                    "sTitle": "DPCK",
                    "sName": "DPCK",
                    "bSearchable": true,
                    "bSortable": true,
                    "sClass": "text-center dpck-editable",
                    "sWidth": "10%"
                }
                ,
                {
                    "sTitle": "Name",
                    "sName": "NAME",
                    "bSearchable": true,
                    "bSortable": true,
                    "sClass": "text-center"
                }
                ,
                {
                    "sTitle": "Level",
                    "sName": "LEVEL",
                    "bSearchable": true,
                    "bSortable": true,
                    "sClass": "text-center"
                }
            ],
            "fnCreatedRow": function (row, data, index) {
                var trimIdentifier = data[trimIdentifierIndex];
                $(row).attr("data-target", trimIdentifier);

                var originalValue = data[dpckCodeIndex];
                $(row).attr("data-original-value", originalValue);
            },
            "fnDrawCallback": function (oSettings) {
                me.configureCellEditing();
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
        var model = getDpckModel();
        var uri = model.getDpckUri();
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
        var modelYear = me.getSelectedModelYear();
        if (modelYear === "N/A") {
            modelYear = "";
        }
        var gateway = me.getSelectedGateway();
        if (gateway === "N/A") {
            gateway = "";
        }
        var params = $.extend({}, data, {
            "TrimMappingId": me.getTrimMappingId(),
            "CarLine": me.getSelectedCarLine(),
            "ModelYear": modelYear,
            "Gateway": gateway,
            "FilterMessage": me.getFilterMessage()
        });
        return params;
    };
    me.getTrimMappingId = function (cell) {
        return $(cell).closest("tr").attr("data-target");
    };
    me.getDpckCode = function (cell) {
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
    me.configureCellEditing = function () {
        $(".dpck-editable").editable(me.cellEditCallback,
        {
            tooltip: "Click to edit trim code (DPCK)",
            cssclass: "editable-cell",
            data: me.parseInputData,
            select: true,
            onblur: "submit",
            maxlength: 5
        });
    };
    me.cellEditCallback = function (value) {

        var target = $(this).closest("tr").attr("data-target");
        var identifiers = target.split("|");
        var originalValue = $(this).closest("tr").attr("data-original-value");

        privateStore[me.id].OriginalValue = originalValue;
        privateStore[me.id].EditedCell = this;

        var formattedValue = me.parseCellValue(value);

        var data = {
            DocumentId: parseInt(identifiers[0]),
            TrimId: parseInt(identifiers[1]),
            Dpck: formattedValue
        };
      
        $(document).trigger("EditCell", data);

        return formattedValue;
    };
    me.parseInputData = function (value) {
        var parsedValue = value.replace("%", "");
        parsedValue = parsedValue.replace("-", "");
        var trimmedValue = $.trim(parsedValue);
        return trimmedValue.toUpperCase();
    };
    me.parseCellValue = function (value) {
        if (value === null || value === "")
            return "";

        return $.trim(value).toUpperCase();
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
                Title: model.getActionTitle(action, eventArgs.Dpck),
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
    me.onErrorEventHandler = function (sender, eventArgs) {
        var html = "<div class=\"alert alert-dismissible alert-danger\">" + eventArgs.Message + "</div>";
        me.scrollToNotify();
        me.fadeInNotify(html);

        var revert = privateStore[me.id].EditedCell;
        var originalValue = privateStore[me.id].OriginalValue;
        if (revert !== null) {

            if (originalValue === undefined || originalValue === "") {
                originalValue = "Click to edit";
            }
            $(revert).html(originalValue);
            privateStore[me.id].EditedCell = null;
            privateStore[me.id].OriginalValue = null;
        }
    };
    me.fadeInNotify = function (displayHtml) {
        var control = $("#notifier");
        if (control.is(":visible")) {
            control.fadeOut("slow", function () {
                control.html(displayHtml);
                if (displayHtml !== "") control.fadeIn("slow");
            });
        } else {
            if (displayHtml !== "") control.fadeIn("slow");
        }
    };
    me.scrollToNotify = function () {
        $("html, body").animate({
            scrollTop: $("#notifier").offset().top - 80
        }, 500);
    };
    me.onFilterChangedEventHandler = function (sender, eventArgs) {
        var filter = $("#" + me.getIdentifierPrefix() + "_FilterMessage").val();
        var filterLength = filter.length;
        if (filterLength === 0 || filterLength > 2) {
            me.redrawDataTable();
        }
    };
    me.onSuccessEventHandler = function (sender, eventArgs) {
        $("#notifier").hide();
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
            .unbind("EditCell").on("EditCell", function (sender, eventArgs) { $(".subscribers-notify").trigger("OnEditCellDelegate", [eventArgs]); })

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
            .unbind("OnEditCellDelegate").on("OnEditCellDelegate", me.onEditCellEventHandler)
            .unbind("OnModalOkDelegate").on("OnModalOkDelegate", me.onModalOKEventHandler);

        $("#" + prefix + "_FilterMessage").on("keyup", me.onFilterChangedEventHandler);
    };
    me.onEditCellEventHandler = function(sender, eventArgs) {
        me.setDataToSave(eventArgs);
        me.saveData(me.saveCallback);
    };
    me.saveData = function(callback) {
        var data = me.getDataToSave();
        getDpckModel().saveData(data, callback);
    };
    me.saveCallback = function () {
        $("#notifier").hide();
        me.setDataToSave(null);
    };
    me.getDataToSave = function() {
        return privateStore[me.id].SaveData;
    }
    me.setDataToSave = function(data) {
        privateStore[me.id].SaveData = data;
    };
    me.setDataTable = function (dataTable) {
        privateStore[me.id].DataTable = dataTable;
    };
    me.setSelectedCarLine = function (carLine) {
        privateStore[me.id].SelectedCarLine = carLine;
    };
    me.setSelectedCarLineDescription = function (carLine) {
        privateStore[me.id].SelectedCarLineDescription = carLine;
    };
    me.setSelectedDocument = function(document) {
        privateStore[me.id].SelectedDocument = document;
    };
    me.setSelectedDocumentDescription = function(documentDescription) {
        privateStore[me.id].SelectedDocumentDescription = documentDescription;
    };
    me.setSelectedModelYear = function (modelYear) {
        privateStore[me.id].SelectedModelYear = modelYear;
    };
    me.setSelectedGateway = function (gateway) {
        privateStore[me.id].SelectedGateway = gateway;
    };
    me.updatePaging = function () {
        var info = $(".dataTable").DataTable().page.info();
        var pageIndex = info.page + 1;
        var totalPages = info.pages;
        $(".results-paging").html("Page " + pageIndex + " of " + totalPages);
    };
    me.updateTotals = function () {
        var info = $(".dataTable").DataTable().page.info();
        var total = info.recordsTotal;
        $(".results-total").html(total + " Trim Levels");
    }
    function getModal() {
        return getModel("Modal");
    };
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
    function getDpckModel() {
        return getModel("Dpck");
    };
    function getFilter() {
        var model = getDpckModel();
        var pageSize = model.getPageSize();
        var pageIndex = model.getPageIndex();
        var filter = new FeatureDemandPlanning.Dpck.DpckFilter();

        filter.PageIndex = pageIndex;
        filter.PageSize = pageSize;

        return filter;
    }
}