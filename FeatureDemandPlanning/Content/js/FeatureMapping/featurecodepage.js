"use strict";

var page = namespace("FeatureDemandPlanning.FeatureCode");

page.FeatureCodePage = function (models) {
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
    me.actionTriggered = function (invokedOn, action) {
        var eventArgs = {
            DerivativeMappingId: $(this).attr("data-target"),
            DerivativeCode: $(this).attr("data-content"),
            Action: parseInt($(this).attr("data-role"))
        };
        $(document).trigger("Action", eventArgs);
    }
    me.bindContextMenu = function () {
        $(".dataTable td").contextMenu({
            menuSelector: "#contextMenu",
            dynamicContent: me.getContextMenu,
            contentIdentifier: me.getDerivativeMappingId,
            menuSelected: me.actionTriggered
        });
    };
    me.configureDataTables = function () {

        var featureCodeIdentifierIndex = 0;
        var featureCodeIndex = 4;

        $(".dataTable").DataTable({
            "serverSide": true,
            "pagingType": "full_numbers",
            "ajax": me.getData,
            "processing": true,
            "sDom": "ltip",
            "aoColumns": [
            {
                "sTitle": "FeatureCodeIdentifier",
                "sName": "FEATURE_CODE_IDENTIFIER",
                "bSearchable": false,
                "bVisible": false
            },
            {
                "sTitle": "Programme",
                "sName": "PROGRAMME",
                "bSearchable": true,
                "bSortable": false
            }, {
                "sTitle": "Gateway",
                "sName": "GATEWAY",
                "bSearchable": true,
                "bSortable": false,
                "sClass": "text-center"
            }, {
                "sTitle": "Document",
                "sName": "DOCUMENT",
                "bSearchable": true,
                "bSortable": false
            }, {
                "sTitle": "Feature Code",
                "sName": "FEATURE_CODE",
                "bSearchable": true,
                "bSortable": false,
                "sClass": "text-center feature-code-editable",
                "sWidth": "10%"
            }, {
                "sTitle": "Description",
                "sName": "DESCRIPTION",
                "bSearchable": true,
                "bSortable": false
            }],
            "fnCreatedRow": function (row, data, index) {
                var featureCodeIdentifier = data[featureCodeIdentifierIndex];
                $(row).attr("data-target", featureCodeIdentifier);

                var originalValue = data[featureCodeIndex];
                $(row).attr("data-original-value", originalValue);
            },
            "fnDrawCallback": function (oSettings) {
                //$(document).trigger("Results", me.getSummary());
                //me.bindContextMenu();
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
        var model = getFeatureCodeModel();
        var uri = model.getFeatureCodeUri();
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
    me.getDocumentId = function () {
        var documentId = $("#" + me.getIdentifierPrefix() + "_DocumentId").val();
        if (documentId !== "") {
            return parseInt(documentId);
        }
        return null;
    }
    me.getFilterMessage = function () {
        return $("#" + me.getIdentifierPrefix() + "_FilterMessage").val();
    };
    me.getIdentifierPrefix = function () {
        return $("#Page_IdentifierPrefix").val();
    };
    me.getParameters = function (data) {
        var modelYear = me.getSelectedModelYear();
        if (modelYear === "N/A") {
            modelYear = "";
        }
        var gateway = me.getSelectedGateway();
        if (gateway === "N/A") {
            gateway = "";
        }
        var params = $.extend({}, data, {
            "CarLine": me.getSelectedCarLine(),
            "ModelYear": modelYear,
            "Gateway": gateway,
            "FilterMessage": me.getFilterMessage(),
            "DocumentId": me.getDocumentId()
        });
        return params;
    };
    me.getFeatureCode = function (cell) {
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
        $(".feature-code-editable").editable(me.cellEditCallback,
        {
            tooltip: "Click to edit feature code",
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

        var data;
        if (identifiers[1].indexOf("P") !== -1) {

            var packId = parseInt(identifiers[1].substring(1));
            data = {
                DocumentId: parseInt(identifiers[0]),
                FeaturePackId: packId,
                FeatureCode: formattedValue
            };

        } else {
            
            var featureId = parseInt(identifiers[1].substring(1));
            data = {
                DocumentId: parseInt(identifiers[0]),
                FeatureId: featureId,
                FeatureCode: formattedValue
            };
        }
      
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
                Title: model.getActionTitle(action, eventArgs.DerivativeCode),
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
        getFeatureCodeModel().saveData(data, callback);
    };
    me.saveCallback = function() {
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
        $(".results-total").html(total + " Features");
    }
    function getModal() {
        return getModel("Modal");
    };
    function getModelForAction(actionId) {
        return getDerivativeMappingModel();
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
    function getFeatureCodeModel() {
        return getModel("FeatureCode");
    };
    function getFilter() {
        var model = getFeatureCodeModel();
        var pageSize = model.getPageSize();
        var pageIndex = model.getPageIndex();
        var filter = new FeatureDemandPlanning.FeatureCode.FeatureCodeFilter();

        filter.PageIndex = pageIndex;
        filter.PageSize = pageSize;

        return filter;
    }
}