"use strict";

var model = namespace("FeatureDemandPlanning.Volume");

model.PowertrainAction = function(params) {
    var uid = 0;
    var privateStore = {};
    var me = this;

    privateStore[me.id = uid++] = {};
    privateStore[me.id].Config = params.Configuration;
    privateStore[me.id].Parameters = params;
    privateStore[me.id].ResultsMode = "PercentageTakeRate";

    me.action = function() {
        //$(document).trigger("Filtered", me.getActionParameters());
    };
    me.formatPercentageTakeRate = function (takeRate) {
        var formattedValue = "-";
        if (takeRate !== null && takeRate !== undefined)
            formattedValue = takeRate.toFixed(2) + " %";

        return formattedValue;
    };
    me.formatFractionalPercentageTakeRate = function (takeRate) {
        var formattedValue = "-";
        if (takeRate !== null && takeRate !== undefined)
            formattedValue = (takeRate * 100).toFixed(2) + " %";

        return formattedValue;
    }
    me.getActionParameters = function() {
        var actionParameters = getData();
        $.extend(actionParameters, { Filter: me.getFilter() });
        return actionParameters;
    };
    me.getActionTitle = function () {
        return "Powertrain Summary Data";
    };
    me.getFilter = function() {
        return $("#" + me.getIdentifierPrefix() + "_FilterMessage").val();
    };
    me.getIdentifierPrefix = function() {
        return $("#Action_IdentifierPrefix").val();
    };
    me.getParameters = function() {
        return privateStore[me.id].Parameters;
    };
    me.parseCellValue = function (value) {
        var retVal = null;
        var parsedValue;
        if (me.getResultsMode() === "PercentageTakeRate") {
            parsedValue = $.trim(value.replace("%", ""));
            if (parsedValue !== "-" && parsedValue !== "") {
                retVal = parseFloat(parsedValue);
            }
        }
        else {
            parsedValue = $.trim(value);
            if (parsedValue !== "-" && parsedValue !== "") {
                retVal = parseInt(parsedValue);
            }
        }
        if (isNaN(retVal))
            retVal = null;

        return retVal;
    };
    me.getResultsMode = function () {
        return privateStore[me.id].ResultsMode;
    };
    me.setResultsMode = function (resultsMode) {
        privateStore[me.id].ResultsMode = resultsMode;
    };
    me.initialise = function() {
        me.registerEvents();
        me.registerSubscribers();

        $("#Modal_OK").hide();
        $("#Modal_Cancel").html("Close");

        me.configureDerivativeCellEditing();
    };
    me.configureDerivativeCellEditing = function () {
        $(".editable-derivative").editable(me.derivativeCellEditCallback,
        {
            tooltip: "Click to edit percentage take / volume",
            cssclass: "editable-cell",
            data: me.parseInputData,
            select: true,
            onblur: "submit"
        }).click(function() {
            $("#Modal_Cancel").attr("disabled", "disabled");
        });
    };
    me.derivativeCellEditCallback = function (value, settings) {

        me.showSpinner("Updating Derivative Mix");
       
        var target = $(this).attr("data-target");
        var identifiers = target.split("|");

        var derivativeCode = null;
        var marketIdentifier = null;

        marketIdentifier = identifiers[0];
        derivativeCode = identifiers[1];

        var change = new FeatureDemandPlanning.Volume.Change(marketIdentifier, null, null);
        change.setDerivativeCode(derivativeCode);
        change.Mode = me.getResultsMode();
        var formattedValue = "";
        if (change.Mode === "PercentageTakeRate") {

            change.setOriginalTakeRate(me.parseCellValue(this.revert));
            change.setChangedTakeRate(me.parseCellValue(value));

            if (change.isValid()) {
                formattedValue = me.formatPercentageTakeRate(change.getChangedTakeRate());
                $(document).trigger("EditCell", change);
            } else {
                formattedValue = me.formatPercentageTakeRate(change.getOriginalTakeRate());
            }

        }
        //me.hideSpinner();
        $("#Modal_Cancel").removeAttr("disabled");

        return formattedValue;
    };
    me.showSpinner = function (spinnerText) {
        var spinnerModal = $("#" + me.getIdentifierPrefix() + "_SpinnerModal");
        var spinner = $("#" + me.getIdentifierPrefix() + "_Spinner");
        var spinnerTitle = $("#" + me.getIdentifierPrefix() + "_SpinnerModalTitle");

        spinnerTitle.html(spinnerText);
        spinnerModal.modal({
            backdrop: "static",
            keyboard: false
        });
        spinner.spin("show");
    };
    me.hideSpinner = function () {
        var spinnerModal = $("#" + me.getIdentifierPrefix() + "_SpinnerModal");
        var spinner = $("#" + me.getIdentifierPrefix() + "_Spinner");

        spinner.spin("hide");
        spinnerModal.modal("hide");
    };
    me.parseInputData = function (value) {
        var parsedValue = value.replace("%", "");
        parsedValue = parsedValue.replace("-", "");
        var trimmedValue = $.trim(parsedValue);
        return trimmedValue;
    };
    me.registerEvents = function() {
        $("#Modal_OK").unbind("click").on("click", me.action);

        $("#" + me.getIdentifierPrefix() + "_FilterMessage").on("keyup", function() {
            var value = $("#" + me.getIdentifierPrefix() + "_FilterMessage").val();
            if (value.length === 0 || value.length >= 3) {
                $(document).trigger("Filtered", me.getActionParameters());
            }
        });
        $("#" + me.getIdentifierPrefix() + "_ClearFilter").on("click", function () {
            $("#" + me.getIdentifierPrefix() + "_FilterMessage").val("");
            $(document).trigger("Filtered", me.getActionParameters());
        });
    };
    me.registerSubscribers = function() {

    };
    me.setParameters = function (parameters) {
        privateStore[me.id].Parameters = parameters;
    };
    function getData() {
        var params = me.getParameters();
        if (params.Data != undefined)
            return JSON.parse(params.Data);

        return {};
    };
}