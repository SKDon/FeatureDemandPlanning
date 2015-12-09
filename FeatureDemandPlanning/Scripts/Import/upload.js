"use strict";

var model = namespace("FeatureDemandPlanning.Import");

model.UploadParameters = function () {
    var me = this;
    me.Action = 0;
    me.UploadFile = null;
    me.CarLine = "";
    me.ModelYear = "";
    me.Gateway = "";
    me.DocumentId = null;
}

model.Upload = function (params) {
    var uid = 0;
    var privateStore = {};
    var me = this;

    privateStore[me.id = uid++] = {};
    privateStore[me.id].Config = params.Configuration;
    privateStore[me.id].ModalContentUri = params.ModalContentUri;
    privateStore[me.id].ModalActionUri = params.ModalActionUri;
    privateStore[me.id].UploadUri = params.UploadUri;
    privateStore[me.id].SelectedCarLine = ""
    privateStore[me.id].SelectedCarLineDescription = "";
    privateStore[me.id].SelectedModelYear = "";
    privateStore[me.id].SelectedGateway = "";
    privateStore[me.id].SelectedDocument = "";
    privateStore[me.id].SelectedDocumentId = null;
    privateStore[me.id].Parameters = params;

    me.ModelName = "Upload";

    me.carLineSelectedEventHandler = function (sender) {
        me.setSelectedCarLine($(sender.target).attr("data-target"));
        me.setSelectedCarLineDescription($(sender.target).attr("data-content"));
        me.displaySelectedCarLine();
        me.filterModelYears();
        me.filterGateways();
        me.filterDocuments();
    };
    me.displaySelectedCarLine = function () {
        $("#" + me.getIdentifierPrefix() + "_SelectedCarLine").html(me.getSelectedCarLineDescription());
    }
    me.displaySelectedModelYear = function () {
        var selectedModelYear = me.getSelectedModelYear();
        if (selectedModelYear === "") {
            selectedModelYear = "Select Model Year";
        }
        $("#" + me.getIdentifierPrefix() + "_SelectedModelYear").html(selectedModelYear);
    };
    me.displaySelectedGateway = function () {
        var selectedGateway = me.getSelectedGateway();
        if (selectedGateway === "") {
            selectedGateway = "Select Gateway";
        }
        $("#" + me.getIdentifierPrefix() + "_SelectedGateway").html(selectedGateway);
    };
    me.displaySelectedDocument = function () {
        var selectedDocument = me.getSelectedDocument();
        if (selectedDocument === "") {
            selectedDocument = "Select Document";
        }
        $("#" + me.getIdentifierPrefix() + "_SelectedDocument").html(selectedDocument);
    };
    me.documentSelectedEventHandler = function (sender) {
        me.setSelectedDocumentId(parseInt($(sender.target).attr("data-target")));
        me.setSelectedDocument($(sender.target).attr("data-content"));
        me.displaySelectedDocument();
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
            .filter("[data-filter='" + me.getSelectedCarLine() + "|" + me.getSelectedModelYear() + "']")
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
    me.filterDocuments = function() {
        var selectedDocument = $("#" + me.getIdentifierPrefix() + "_SelectedDocument");
        var documentList = $("#" + me.getIdentifierPrefix() + "_DocumentList")
        var documents = documentList
            .find("a.document-item")
            .hide()
            .filter("[data-filter='" + me.getSelectedCarLine() + "|" + me.getSelectedModelYear() + "|" + me.getSelectedGateway() + "']")
            .show();

        if (documents.length === 0) {
            me.setSelectedDocument("N/A");
            me.displaySelectedDocument();
            selectedDocument.attr("disabled", "disabled");
            return;
        }
            me.setSelectedDocument("");
            me.displaySelectedDocument();
            selectedDocument.removeAttr("disabled");
    };
    me.gatewaySelectedEventHandler = function (sender) {
        me.setSelectedGateway($(sender.target).attr("data-target"));
        me.displaySelectedGateway();
        me.filterDocuments();
    };
    me.getActionContentUri = function (action) {
        return privateStore[me.id].ModalContentUri;
    };
    me.getActionModel = function (action) {
        return new FeatureDemandPlanning.Import.UploadAction(me.getParameters(), me);
    };
    me.getActionUri = function (action) {
        return privateStore[me.id].UploadActionUri;
    };
    me.getActionTitle = function (action) {
        return "Import PPO File";
    };
    me.getConfiguration = function () {
        return privateStore[me.id].Configuration;
    };
    me.getIdentifierPrefix = function () {
        return $("#Action_IdentifierPrefix").val();
    };
    me.getParameters = function () {
        return privateStore[me.id].Parameters;
    };
    me.getSelectedCarLine = function () {
        return privateStore[me.id].SelectedCarLine;
    };
    me.getSelectedCarLineDescription = function () {
        return privateStore[me.id].SelectedCarLineDescription;
    };
    me.getSelectedDocumentId = function () {
        return privateStore[me.id].SelectedDocumentId;
    };
    me.getSelectedDocument = function () {
        return privateStore[me.id].SelectedDocument;
    };
    me.getSelectedFile = function () {
        return $('input[type=file]')[0].files[0];
    };
    me.getSelectedModelYear = function () {
        return privateStore[me.id].SelectedModelYear;
    };
    me.getSelectedGateway = function () {
        return privateStore[me.id].SelectedGateway;
    };
    me.getUpdateParameters = function () {
        var uploadParameters = new FeatureDemandPlanning.Import.UploadParameters();
        uploadParameters.CarLine = me.getSelectedCarLine();
        uploadParameters.ModelYear = me.getSelectedModelYear();
        uploadParameters.Gateway = me.getSelectedGateway();
        uploadParameters.DocumentId = me.getSelectedDocumentId();

        return uploadParameters;
    };
    me.initialise = function () {
        me.registerEvents();
        me.registerSubscribers();
        me.filterModelYears();
        me.filterGateways();
        me.filterDocuments();
    };
    me.modelYearSelectedEventHandler = function (sender) {
        me.setSelectedModelYear($(sender.target).attr("data-target"));
        me.displaySelectedModelYear();
        me.filterGateways();
    };
    me.registerEvents = function () {
        var prefix = me.getIdentifierPrefix();

        $("#uploadForm").submit(function () {
            $("#uploadForm").ajaxSubmit();
            return false; // Prevent the submit handler from refreshing the page
        });
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
        $("#" + prefix + "_DocumentList").find("a.document-item").on("click", function (e) {
            me.documentSelectedEventHandler(e);
            e.preventDefault();
        });
        $(document).on("change", ".btn-file :file", function () {
            var input = $(this),
                numFiles = input.get(0).files ? input.get(0).files.length : 1,
                label = input.val().replace(/\\/g, "/").replace(/.*\//, "");
            $("#" + prefix + "_SelectedFilename").html(label);
            input.trigger("fileselect", [numFiles, label]);
        });
    };
    me.registerSubscribers = function () {

    };
    me.setParameters = function (parameters) {
        privateStore[me.id].Parameters = parameters;
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
    me.setSelectedDocument = function (document) {
        privateStore[me.id].SelectedDocument = document;
    };
    me.setSelectedDocumentId = function (documentId) {
        privateStore[me.id].SelectedDocumentId = documentId;
    };
}

