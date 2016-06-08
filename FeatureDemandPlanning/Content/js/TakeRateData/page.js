"use strict";

var model = namespace("FeatureDemandPlanning.Volume");

// Create a stopwatch "class." 
model.StopWatch = function () {
    this.StartMilliseconds = 0;
    this.ElapsedMilliseconds = 0;
    var me = this;
    
    me.Start = function () {
        me.StartMilliseconds = new Date().getTime();
    }

    me.Stop = function () {
        me.ElapsedMilliseconds = new Date().getTime() - me.StartMilliseconds;
    }
}

model.Page = function (models) {
    var uid = 0, privateStore = {}, me = this;

    privateStore[me.id = uid++] = {};
    privateStore[me.id].Models = models;
    privateStore[me.id].DataTable = null;
    privateStore[me.id].ResultsMode = "PercentageTakeRate";
    privateStore[me.id].Changeset = null;
    privateStore[me.id].Initial = true;
    privateStore[me.id].Expanded = true;
    privateStore[me.id].InEdit = false;
    privateStore[me.id].Markets = null;
    privateStore[me.id].RowOffset = 0;
    
    me.initialise = function ()
    {    
        $(privateStore[me.id].Models).each(function () {
            this.initialise();
        });
        
        me.setResultsMode($("#" + me.getIdentifierPrefix() + "_Mode").val());
        me.loadData();
        me.registerEvents();
        me.registerSubscribers();
    };
    me.calcPanelHeight = function () {
        return ($(window).height()) - 135 + "px";
    };
    me.calcDataTableHeight = function () {
        var panelHeight = $("#" + me.getIdentifierPrefix() + "_TakeRateDataPanel").height();
        return (panelHeight - 190) + "px";
    };
    me.configureChangeset = function () {
        privateStore[me.id].Changeset = new FeatureDemandPlanning.Volume.Changeset();
    };
    me.getDataTable = function () {
        return privateStore[me.id].DataTable;
    };
    me.setDataTable = function (dataTable) {
        privateStore[me.id].DataTable = dataTable;
    };
    me.getResultsMode = function () {
        return privateStore[me.id].ResultsMode;
    };
    me.setResultsMode = function (resultsMode) {
        privateStore[me.id].ResultsMode = resultsMode;
    };
    me.loadData = function () {
        me.showSpinner("Loading Changes & Validating");
        me.initialiseControls();
        me.configureChangeset();
        me.configureDataTables();
        me.loadChangeset();
        me.loadValidation();
    };
    me.persistData = function () {
        var model = getTakeRateDataModel();
        var action = model.getPersistChangesetAction();
        var actionModel = model.getActionModel(action);
        var filter = getFilter("");
        filter.Action = action;
        filter.Changeset = getChangeset().getDataChanges();

        getModal().showModal({
            Title: "Commit Changes",
            Uri: model.getPersistChangesetConfirmUri(),
            Data: JSON.stringify(filter),
            Model: model,
            ActionModel: actionModel
        });
    };
    me.showHistory = function() {
        var model = getTakeRateDataModel();
        var action = model.getChangesetHistoryAction();
        var actionModel = model.getActionModel(action);
        var filter = getFilter("");
        filter.Action = action;

        getModal().showModal({
            Title: "History",
            Uri: model.getChangesetHistoryUri(),
            Data: JSON.stringify(filter),
            Model: model,
            ActionModel: actionModel
        });
    };
    me.showHistoryDetails = function(changesetId) {
        var model = getTakeRateDataModel();
        var action = model.getChangesetHistoryDetailsAction();
        var actionModel = model.getActionModel(action);
        var filter = getFilter("");

        $.extend(filter, { ChangesetId: changesetId });
        filter.Action = action;
       
        getModal().refreshModal({
            Title: "Change Details",
            Uri: model.getChangesetHistoryDetailsUri(),
            Data: JSON.stringify(filter),
            Model: model,
            ActionModel: actionModel
        });
    };
    me.showPowertrain = function() {
        var model = getTakeRateDataModel();
        var action = model.getPowertrainAction();
        var actionModel = model.getActionModel(action);
        var filter = getFilter("");
        filter.Action = action;

        getModal().showModal({
            Title: "Derivative Mix Data",
            Uri: model.getPowertrainUri(),
            Data: JSON.stringify(filter),
            Model: model,
            ActionModel: actionModel
        });
    };
    me.showValidationSummary = function() {
        var model = getTakeRateDataModel();
        var action = model.getValidationSummaryAction();
        var actionModel = model.getActionModel(action);
        var filter = getFilter("");
        filter.Action = action;

        getModal().showModal({
            Title: "Validation Summary",
            Uri: model.getValidationSummaryUri(),
            Data: JSON.stringify(filter),
            Model: model,
            ActionModel: actionModel
        });
    };
    me.showFilter = function() {
        var model = getFilterModel();
        var action = model.getFilterAction();
        var actionModel = model.getActionModel(action);
        var filter = getFilter("");
        filter.Action = action;
        filter.Filter = model.getCurrentFilter();

        getModal().showModal({
            Title: actionModel.getActionTitle(),
            Uri: model.getActionContentUri(),
            Data: JSON.stringify(filter),
            Model: model,
            ActionModel: actionModel
        });
    }
    me.undoData = function () {
        me.showSpinner("Undo Data");
        getTakeRateDataModel().undoData({ Data: getChangeset().getDataChanges() }, me.undoDataCallback);
    };
    me.undoAllData = function () {
        me.showSpinner("Undo All Data");
        getTakeRateDataModel().undoAllData({ Data: getChangeset().getDataChanges() }, me.undoAllDataCallback);
    };
    me.showSpinner = function(spinnerText) {
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
    me.hideSpinner = function() {
        var spinnerModal = $("#" + me.getIdentifierPrefix() + "_SpinnerModal");
        var spinner = $("#" + me.getIdentifierPrefix() + "_Spinner");

        spinner.spin("hide");
        spinnerModal.modal("hide");
    };
    me.getPersistSuccessMessage = function() {
        return "Changes committed successfully. Data will now reload";
    };
    me.persistDataCallback = function() {
        var modal = getModal();
        modal.setModalParameters({ Data: getChangeset().getDataChanges() });
        modal.showConfirm("Changes Committed", me.getPersistSuccessMessage(), me.reloadPage);
    };
    me.undoDataCallback = function(revertedData) {
        me.setInitial(false);
        //me.loadChangeset();
        me.revertData(revertedData);
        me.hideSpinner();
        me.loadValidation();
    };
    me.undoAllDataCallback = function(revertedData) {
        me.undoAllData(revertedData);
        me.reloadPage();
    };
    me.reloadPage = function() {
        location.reload(true);
    };
    me.saveData = function (callback) {
        var changes = getChangeset().getDataChanges();
        getTakeRateDataModel().saveData(changes, callback);
    };
    me.initialiseControls = function () {
        var prefix = me.getIdentifierPrefix();
        $("#" + prefix + "_TakeRateDataPanel").height(me.calcPanelHeight());
    };
    me.getIdentifierPrefix = function () {
        return $("#Page_IdentifierPrefix").val();
    };
    me.parseError = function (error) {
        var retVal = "";
        $(error.errors).each(function () {
            retVal += ("<li>" + this.ErrorMessage + "</li>");
        });
        return retVal;
    };
    me.getVolume = function () {
        return getTakeRateDataModel().getVolume();
    }
    me.getVehicle = function () {
        return getTakeRateDataModel().getVehicle();
    };
    me.setVehicle = function (vehicle) {
        getTakeRateDataModel().setVehicle(vehicle);
    };
    me.registerEvents = function () {
        var prefix = me.getIdentifierPrefix();
        $(document)
            .unbind("Success").on("Success", function(sender, eventArgs) { $(".subscribers-notify").trigger("OnSuccessDelegate", [eventArgs]); })
            .unbind("Error").on("Error", function(sender, eventArgs) { $(".subscribers-notify").trigger("OnErrorDelegate", [eventArgs]); })
            .unbind("Results").on("Results", function(sender, eventArgs) { $(".subscribers-notify").trigger("OnResultsDelegate", [eventArgs]); })
            .unbind("Updated").on("Updated", function(sender, eventArgs) { $(".subscribers-notify").trigger("OnUpdatedDelegate", [eventArgs]); })
            .unbind("Action").on("Action", function(sender, eventArgs) { $(".subscribers-notify").trigger("OnActionDelegate", [eventArgs]); })
            .unbind("ModalLoaded").on("ModalLoaded", function(sender, eventArgs) { $(".subscribers-notify").trigger("OnModalLoadedDelegate", [eventArgs]); })
            .unbind("ModalOk").on("ModalOk", function(sender, eventArgs) { $(".subscribers-notify").trigger("OnModalOkDelegate", [eventArgs]); })
            .unbind("Validation").on("Validation", function(sender, eventArgs) { $(".subscribers-notify").trigger("OnValidationDelegate", [eventArgs]); })
            .unbind("EditCell").on("EditCell", function(sender, eventArgs) { $(".subscribers-notify").trigger("OnEditCellDelegate", [eventArgs]); })
            .unbind("Save").on("Save", function(sender, eventArgs) { $(".subscribers-notify").trigger("OnSaveDelegate", [eventArgs]); })
            .unbind("Saved").on("Saved", function(sender, eventArgs) { $(".subscribers-notify").trigger("OnSavedDelegate", [eventArgs]); })
            .unbind("UpdateFilterVolume").on("UpdateFilterVolume", function(sender, eventArgs) { $(".subscribers-notify").trigger("OnUpdateFilterVolumeDelegate", [eventArgs]); })
            .unbind("Filtered").on("Filtered", function(sender, eventArgs) { $(".subscribers-notify").trigger("OnFilteredDelegate", [eventArgs]); })
            .unbind("HistoryDetails").on("HistoryDetails", function (sender, eventArgs) { $(".subscribers-notify").trigger("OnHistoryDetailsDelegate", [eventArgs]); })
            .unbind("NoteAdded").on("NoteAdded", function (sender, eventArgs) { $(".subscribers-notify").trigger("OnNoteAddedDelegate", [eventArgs]); })
            .unbind("ValidationNavigation").on("ValidationNavigation", function(sender, eventArgs) { $(".subscribers-notify").trigger("OnValidationNavigationDelegate", [eventArgs]); });

        $("#" + prefix + "_Save").unbind("click").on("click", function (sender, eventArgs) { $(".subscribers-notify").trigger("OnPersistDelegate", [eventArgs]); });
        $("#" + prefix + "_Undo").unbind("click").on("click", function (sender, eventArgs) { $(".subscribers-notify").trigger("OnUndoDelegate", [eventArgs]); });
        $("#" + prefix + "_UndoAll").unbind("click").on("click", function (sender, eventArgs) { $(".subscribers-notify").trigger("OnUndoAllDelegate", [eventArgs]); });
        $("#" + prefix + "_History").unbind("click").on("click", function (sender, eventArgs) { $(".subscribers-notify").trigger("OnHistoryDelegate", [eventArgs]); });
        $("#" + prefix + "_Validation").unbind("click").on("click", function (sender, eventArgs) { $(".subscribers-notify").trigger("OnValidationSummaryDelegate", [eventArgs]); });
        $("#" + prefix + "_Powertrain").unbind("click").on("click", function (sender, eventArgs) { $(".subscribers-notify").trigger("OnPowertrainDelegate", [eventArgs]); });

        $("#" + prefix + "_MarketReview").unbind("click").on("click", function () { $(".subscribers-notify").trigger("OnMarketReviewDelegate", [{ MarketReviewStatus: 1 }]); });
        $("#" + prefix + "_SubmitMarketReview").unbind("click").on("click", function () { $(".subscribers-notify").trigger("OnMarketReviewDelegate",[{ MarketReviewStatus: 2 }]); });
        $("#" + prefix + "_ApproveMarketReview").unbind("click").on("click", function () { $(".subscribers-notify").trigger("OnMarketReviewDelegate", [{ MarketReviewStatus: 4 }]); });
        $("#" + prefix + "_RejectMarketReview").unbind("click").on("click", function () { $(".subscribers-notify").trigger("OnMarketReviewDelegate", [{ MarketReviewStatus: 3 }]); });
        $("#" + prefix + "_RecallMarketReview").unbind("click").on("click", function () { $(".subscribers-notify").trigger("OnMarketReviewDelegate", [{ MarketReviewStatus: 5 }]); });

        $("#" + prefix + "_Publish").unbind("click").on("click", function (sender, eventArgs) { $(".subscribers-notify").trigger("OnPublishDelegate", [eventArgs]); });

        $("#" + prefix + "_Toggle").unbind("click").on("click", function (sender, eventArgs) { $(".subscribers-notify").trigger("OnToggleDelegate", [eventArgs]); });
        $("#" + prefix + "_Filter").unbind("click").on("click", function (sender, eventArgs) { $(".subscribers-notify").trigger("OnFilterDelegate", [eventArgs]); });
        $(".update-filtered-volume").unbind("click").on("click", function (sender, eventArgs) { me.raiseFilteredVolumeChanged(); });
        $(".efg-item").unbind("click").on("click", function (sender, eventArgs) { $(this).popover("hide"); me.filterItem(this); });
        $("a").unbind("click").on("click", function(sender, eventArgs) { me.showSpinner("Loading"); });
    };
    me.registerSubscribers = function () {
        var prefix = me.getIdentifierPrefix();
        // The #notifier displays status changed message, therefore it makes sense for it to listen to status
        // events and dispatch accordingly

        $("#notifier")
            .unbind("OnSuccessDelegate").on("OnSuccessDelegate", me.onSuccessEventHandler)
            .unbind("OnErrorDelegate").on("OnErrorDelegate", me.onErrorEventHandler)
            .unbind("OnUpdatedDelegate").on("OnUpdatedDelegate", me.onUpdatedEventHandler)
            .unbind("OnValidationDelegate").on("OnValidationDelegate", me.onValidationEventHandler)
            .unbind("OnActionDelegate").on("OnActionDelegate", me.onActionEventHandler)
            .unbind("OnUpdateFilterVolumeDelegate").on("OnUpdateFilterVolumeDelegate", me.onUpdateFilterVolumeEventHandler)
            .unbind("OnNoteAddedDelegate").on("OnNoteAddedDelegate", me.onNoteAddedEventHandler)
            .unbind("OnFilteredDelegate").on("OnFilteredDelegate", me.onFilterChangedEventHandler);

        $("#" + me.getIdentifierPrefix() + "_TakeRateDataPanel")
            .on("OnEditCellDelegate", me.onEditCellEventHandler)
            .on("OnSaveDelegate", me.onSaveEventHandler)
            .on("OnSavedDelegate", me.onSavedEventHandler)
            .on("OnPersistDelegate", me.onPersistEventHandler)
            .on("OnHistoryDelegate", me.onHistoryEventHandler)
            .on("OnHistoryDetailsDelegate", me.onHistoryDetailsEventHandler)
            .on("OnPowertrainDelegate", me.onPowertrainEventHandler)
            .on("OnValidationSummaryDelegate", me.onValidationSummaryEventHandler)
            .on("OnMarketReviewDelegate", me.onMarketReviewEventHandler)
            .on("OnPublishDelegate", me.onPublishEventHandler)
            .on("OnUndoDelegate", me.onUndoEventHandler)
            .on("OnUndoAllDelegate", me.onUndoAllEventHandler)
            .on("OnToggleDelegate", me.onToggleEventHandler)
            .on("OnFilterDelegate", me.onFilterEventHandler)
            .on("OnValidationNavigationDelegate", me.onValidationNavigationEventHandler);

        // Iterate through each of the forecast / comparison controls and register onclick / change handlers
        $(".fdp-volume-header-toggle").unbind("click").on("click", me.toggleFdpVolumeHeader);      
    };
    me.lowerCellEditing = function () {
        var prefix = me.getIdentifierPrefix();
        $(".editable").unbind("click.editable");
        $(".editable-header").unbind("click.editable");
        $("#" + prefix + "_MarketVolume").unbind("click.editable");
    };
    me.configureCellEditing = function () {
        var prefix = me.getIdentifierPrefix();
        $(".editable").editable(me.cellEditCallback,
        {
            tooltip: "Click to edit percentage take / volume",
            cssclass: "editable-cell",
            data: me.parseInputData,
            select: true,
            onblur: "submit"
        });

        $(".editable-header").editable(me.cellEditCallback,
        {
            tooltip: "Click to edit percentage take / volume for model",
            cssclass: "editable-cell",
            data: me.parseInputData,
            select: true,
            onblur: "submit"
        });

        $("#" + prefix + "_MarketVolume").editable(me.cellEditCallback,
        {
            tooltip: "Click to edit volume for market",
            cssclass: "editable-cell-large",
            data: me.parseInputData,
            select: true,
            onblur: "submit"
        });
    };
    me.configureRowHighlight = function() {
        $(document).on({
            mouseenter: function() {
                if (me.isGroup(this)) {
                    return;
                }
                var selector = $("table.dataTable");
                var rowIndex = $(this).closest("tr").index() + 3; // Add +3 as we need to exclude the additional header rows
                var columnIndex = $(this).index();
               
                var modelIdentifier = $(this).attr("data-model");
                
                // Highlight the cell itself and any previous siblings
                selector.find("tr:eq(" + rowIndex + ") td:lt(" + (columnIndex + 1) + "),td[class='cross-tab-fixed']").addClass("highlight");

                // Highlight the cells in the same column with a row index <= the current index
                selector.find("tr:lt(" + (rowIndex + 1) + ") td[data-model='" + modelIdentifier + "'], th[data-model='" + modelIdentifier + "']").addClass("highlight");
            },
            mouseleave: function () {
                var selector = $("table.dataTable");
                selector.find("tbody tr td").removeClass("highlight");
                selector.find("thead tr th").removeClass("highlight");
            }
        }, ".dataTables_wrapper tbody tr td");
    };
    me.isGroup = function (selector) {
        var g = $(selector).hasClass("group") || $(selector).hasClass("sub-group");
        return g;
    };
    me.isFixed = function(selector) {
        var f = $(selector).hasClass("cross-tab-fixed") || $(selector).hasClass("fdp-data-item-fixed");
        return f;
    };
    me.cellEditCallback = function (value, settings) {

        me.showSpinner("Updating Data");
        
        var target = $(this).attr("data-target");
        target = target.replace("MS|", "");
        var identifiers = target.split("|");

        var modelIdentifier = null;
        var featureIdentifier = null;
        var marketIdentifier = null;

        if (identifiers.length > 0) {
            marketIdentifier = identifiers[0];
        }
        if (identifiers.length > 1) {
            modelIdentifier = identifiers[1];
        }
        if (identifiers.length > 2) {
            featureIdentifier = identifiers[2];
        }
        var change = new FeatureDemandPlanning.Volume.Change(marketIdentifier, modelIdentifier, featureIdentifier);
        change.Mode = me.getResultsMode();
        var formattedValue = "";
        if (change.Mode === "PercentageTakeRate" && modelIdentifier !== null) {

            change.setOriginalTakeRate(me.parseCellValue(this.revert));
            change.setChangedTakeRate(me.parseCellValue(value));

            if (change.isValid()) {
                formattedValue = me.formatPercentageTakeRate(change.getChangedTakeRate());
            } else {
                formattedValue = me.formatPercentageTakeRate(change.getOriginalTakeRate());
            }

        } else {

            change.setMode("Raw");
            change.setOriginalVolume(me.parseCellValue(this.revert));
            change.setChangedVolume(me.parseCellValue(value));

            if (change.getChangedVolume() == null && change.getOriginalVolume() != null) {
                formattedValue = me.formatVolume(change.getOriginalVolume());
            } else {
                formattedValue = me.formatVolume(change.getChangedVolume());
            }
        }
        if (!privateStore[me.id].InEdit)
            $(document).trigger("EditCell", change);

        return formattedValue;
    };
    me.parseCellValue = function (value) {
        var retVal = null;
        var parsedValue;
        if (me.getResultsMode() === "PercentageTakeRate") {
            parsedValue = $.trim(value.replace("%", ""));
            parsedValue = parsedValue.replace(",", "");
            if (parsedValue !== "-" && parsedValue !== "") {
                retVal = parseFloat(parsedValue);
            }
        }
        else {
            parsedValue = $.trim(value);
            parsedValue = parsedValue.replace(",", "");
            if (parsedValue !== "-" && parsedValue !== "") {
                retVal = parseInt(parsedValue);
            }
        }
        if (isNaN(retVal))
            retVal = null;

        return retVal;
    };
    me.formatPercentageTakeRate = function (takeRate) {
        var formattedValue = "-";
        if (takeRate !== null && takeRate !== undefined)
            formattedValue = takeRate.toFixed(2) + " %";
        
        return formattedValue;
    };
    me.formatFractionalPercentageTakeRate = function(takeRate) {
        var formattedValue = "-";
        if (takeRate !== null && takeRate !== undefined)
            formattedValue = (takeRate * 100).toFixed(2) + " %";

        return formattedValue;
    }
    me.formatVolume = function (volume) {
        var formattedValue = "-";
        if (volume !== null)
            formattedValue = volume;

        formattedValue = me.addCommas(formattedValue);

        return formattedValue;
    };
    me.addCommas = function(nStr) {
        nStr += "";
        var x = nStr.split(".");
        var x1 = x[0];
        var x2 = x.length > 1 ? "." + x[1] : "";
        var rgx = /(\d+)(\d{3})/;
        while (rgx.test(x1)) {
            x1 = x1.replace(rgx, "$1" + "," + "$2");
        }
        return x1 + x2;
    }
    me.onEditCellEventHandler = function (sender, eventArgs) {
        var marketIdentifier = eventArgs.getMarketIdentifier();
        var modelIdentifier = eventArgs.getModelIdentifier();
        var featureIdentifier = eventArgs.getFeatureIdentifier();
        var derivativeCode = eventArgs.getDerivativeCode();
         
        var editedCell;
        if (featureIdentifier !== null)
        {
            editedCell = $("tbody div[data-target='" + marketIdentifier + "|" + modelIdentifier + "|" + featureIdentifier + "']");
        }
        else
        {
            editedCell = $("thead th[data-target='MS|" + marketIdentifier + "|" + modelIdentifier + "']");
        }

        if (derivativeCode != null) {
            editedCell = $("td[data-target='" + marketIdentifier + "|" + derivativeCode + "']");
        }
        //var editedRow = $(".DTFC_Cloned tbody tr[data-target='" + marketIdentifier + "|" + featureIdentifier + "']");
        var changeSet = getChangeset();

        // If any changes have reverted back to the original value, we need to lower any change flags and remove from the changeset
        var priorChanges = changeSet.getChange(marketIdentifier, modelIdentifier, featureIdentifier, derivativeCode);
        if (priorChanges !== null && priorChanges.length > 0 && (
                (eventArgs.Mode === "PercentageTakeRate" && eventArgs.getChangedTakeRate() === priorChanges[0].getOriginalTakeRate()) ||
                (eventArgs.Mode === "Raw" && eventArgs.getChangedVolume() === priorChanges[0].getOriginalVolume())))
        {
            changeSet.removeChanges(marketIdentifier, modelIdentifier, featureIdentifier, derivativeCode);
            //editedCell.removeClass("edited");

            // If there are no other changes to the feature, lower the feature changed indicator
            //var otherFeatureChanges = changeSet.getChangesForFeature(featureIdentifier);
            //if (otherFeatureChanges == null || otherFeatureChanges.length == 0) {
            //    editedRow.find(".changed-indicator").hide();
            //}
        }
        //else if (eventArgs.isChanged())
        //{
            changeSet.addChange(eventArgs);
            //editedCell.addClass("edited");
            //editedRow.find(".changed-indicator").show();

            // Now we have added to the client changeset, raise the save event to store the changeset on the database and perform any
            // recalculation necessary

            $(document).trigger("Save");
        //}
    };
    me.onSaveEventHandler = function () {
        privateStore[me.id].InEdit = true;
        me.saveData(me.saveCallback);
    };
    me.onSavedEventHandler = function() {
        window.location.reload(true);
    };
    me.onToggleEventHandler = function() {
        me.toggleGroups();
    };
    me.getInitial = function() {
        return privateStore[me.id].Initial;
    }
    me.setInitial = function(initial) {
        privateStore[me.id].Initial = initial;
    };
    me.saveCallback = function () {
        me.setInitial(false);
        me.loadChangeset();
        privateStore[me.id].InEdit = false;
        me.loadValidation();
    };
    me.loadChangeset = function () {
        getTakeRateDataModel().loadChangeset(me.loadChangesetCallback);
    };
    me.loadValidation = function() {
        getTakeRateDataModel().loadValidation(me.loadValidationCallback);
    };
    me.toggleButtonState = function () {

        var prefix = me.getIdentifierPrefix();
        var model = getTakeRateDataModel();

        if (model.HasValidationErrors())
        {
            $("#" + prefix + "_Validation").prop("disabled", false).addClass("validation-error");
            $("#" + prefix + "_Save").prop("disabled", true);
            $("#" + prefix + "_Publish").prop("disabled", true);
            $("#" + prefix + "_MarketReview").prop("disabled", true);
            $("#" + prefix + "_SubmitMarketReview").prop("disabled", true);
            $("#" + prefix + "_ApproveMarketReview").prop("disabled", true);

            if (model.HasChanges())
            {
                $("#" + prefix + "_Undo").prop("disabled", false);
                $("#" + prefix + "_UndoAll").prop("disabled", false);
                $("#" + prefix + "_RecallMarketReview").prop("disabled", true);
            }

            if (!model.HasChanges())
            {
                $("#" + prefix + "_Undo").prop("disabled", true);
                $("#" + prefix + "_UndoAll").prop("disabled", true);
            }

            return;
        }

        if (!model.HasValidationErrors()) {
            $("#" + prefix + "_Validation").prop("disabled", true).removeClass("validation-error");
        }

        if (model.HasChanges())
        {
            $("#" + prefix + "_Save").prop("disabled", false);
            $("#" + prefix + "_Publish").prop("disabled", true);
            $("#" + prefix + "_Undo").prop("disabled", false);
            $("#" + prefix + "_UndoAll").prop("disabled", false);
            $("#" + prefix + "_MarketReview").prop("disabled", true);
            $("#" + prefix + "_RecallMarketReview").prop("disabled", true);
            $("#" + prefix + "_Publish").prop("disabled", true);
        }

        if (!model.HasChanges())
        {
            $("#" + prefix + "_Undo").prop("disabled", true);
            $("#" + prefix + "_UndoAll").prop("disabled", true);
            $("#" + prefix + "_Publish").prop("disabled", false);
        }
    }
    me.loadValidationCallback = function(validationData) {
        
        var model = getTakeRateDataModel();
        var markets = [];
        var mainIndicator = $(".primary-validation-error");
        var modelIndicators = $(".model-validation-error");
        var featureIndicators = $(".feature-validation-error");

        mainIndicator.hide();
        featureIndicators.hide();
        modelIndicators.hide();

        model.setHasValidationErrors(validationData !== null && validationData !== undefined && validationData.ValidationResults.length > 0);

        me.toggleButtonState();

        if (validationData === null || validationData === undefined) return;

        for (var i = 0; i < validationData.ValidationResults.length; i++) {
            var currentResult = validationData.ValidationResults[i];

            // Show an indicator at the market level if there is an error for that market
            var marketExists = false;
            for (var j = 0; j < markets.length; j++) {
                if (markets[j] === currentResult.MarketId) {
                    marketExists = true;
                }
            }
            if (!marketExists) {
                $("a[data-target='ALL']").addClass("validation-error");
                $("a[data-target='MG|" + currentResult.MarketGroupId + "']").addClass("validation-error");
                $("a[data-target='M|" + currentResult.MarketId + "']").addClass("validation-error");
            }

            var selector;
            if (currentResult.IsFeatureMixValidation) {
                selector = $("tbody span[data-target='FS|" + currentResult.DataTarget + "']");
            } else if (currentResult.IsModelValidation) {
                $("thead th[data-target='MS|" + currentResult.DataTarget + "']")
                    .children(".model-validation-error")
                    .fadeIn(1000)
                    .attr("data-content", currentResult.Message);

            } else if (currentResult.IsWholeMarketValidation) {
                selector = $(".input-filtered-volume");
            } else {
                $("tbody div[data-target='" + currentResult.DataTarget + "']")
                    .next()
                    .fadeIn(1000)
                    .attr("data-content", currentResult.Message);
            }
            //selector.addClass(me.getValidationDataClass(currentResult));
        }

        if (validationData.ValidationResults.length !== 0) {
            
            mainIndicator.fadeIn();
        }

        me.configureComments();
    };
    me.confirmLoadChangeset = function(changesetData) {

        var model = getTakeRateDataModel();
        if (changesetData.Changes.length !== 0) {
            model.setHasChanges(true);
        } else {
            model.setHasChanges(false);
        }

        for (var i = 0; i < changesetData.Changes.length; i++)
        {
            var currentChange = changesetData.Changes[i];
            var displayValue, displayValue2;
            var selector, selector2;

            if (currentChange.IsWholeMarketChange)
            {
                displayValue = me.formatVolume(currentChange.Volume);
                displayValue2 = me.formatPercentageTakeRate(currentChange.PercentageTakeRate);
                selector = $("#" + me.getIdentifierPrefix() + "_MarketVolume");
                selector2 = $("#" + me.getIdentifierPrefix() + "_MarketPercentageTakeRate");
            }
            else if (currentChange.IsAllMarketChange)
            {
                displayValue = me.formatVolume(currentChange.Volume);
                selector = $("#" + me.getIdentifierPrefix() + "_AllMarketVolume");
            }
            else if (currentChange.IsPowertrainChange) {

                displayValue = me.formatVolume(currentChange.Volume);
                displayValue2 = me.formatPercentageTakeRate(currentChange.PercentageTakeRate);

                selector = $(".read-only-derivative[data-target='" + currentChange.DataTarget + "|PTV']").first();
                selector2 = $(".editable-derivative[data-target='" + currentChange.DataTarget + "|PTP']").first();
            }
            else
            {
                if (me.getResultsMode() === "PercentageTakeRate")
                {
                    displayValue = me.formatPercentageTakeRate(currentChange.PercentageTakeRate);
                }
                else
                {
                    displayValue = me.formatVolume(currentChange.Volume);
                }

                if (currentChange.IsFeatureSummary)
                {
                    selector = $("tbody span[data-target='FS|" + currentChange.DataTarget + "']");
                }
                else if (currentChange.IsModelSummary)
                {
                    selector = $(".editable-header[data-target='MS|" + currentChange.DataTarget + "']").first();
                }
                else if (currentChange.IsNote)
                {
                    selector = $("div[data-target='N|" + currentChange.DataTarget + "']");
                }
                else
                {
                    selector = $("tbody div[data-target='" + currentChange.DataTarget + "']");
                }
            }

            if (!currentChange.IsNote) {
                if (selector !== null && selector !== undefined) {
                    selector.addClass(me.getEditedDataClass(currentChange)).html(displayValue);
                    if (selector2 != null && displayValue2 != null) {
                        selector2.addClass(me.getEditedDataClass(currentChange)).html(displayValue2);
                    }
                }
            } else {
                if (selector !== null && selector !== undefined) {
                    selector.show();
                }
            }
        }

        // Load the model mix

        if (changesetData.ModelMix.HasModelMixChanged === true && me.getResultsMode() === "PercentageTakeRate")
        {
            $(".model-mix-total").each(function() {
                $(this).html(me.formatPercentageTakeRate(changesetData.ModelMix.ModelMix * 100)).addClass(me.getEditedDataClass(changesetData.ModelMix));
            });
        }
        else if (changesetData.ModelMix.HasModelVolumeChanged === true)
        {
            $(".model-mix-total").each(function () {
                $(this).html(me.formatVolume(changesetData.ModelMix.ModelVolume)).addClass(me.getEditedDataClass(changesetData.ModelMix));
            });
        }

        me.configureCellEditing();
        me.hideSpinner();
    };
    me.revertData = function(revertedData) {
        for (var i = 0; i < revertedData.Reverted.length; i++) {
            var revertedChange = revertedData.Reverted[i];
            var displayValue, displayValue2;
            if (me.getResultsMode() === "PercentageTakeRate" && !revertedChange.IsWholeMarketChange)
            {
                displayValue = me.formatFractionalPercentageTakeRate(revertedChange.OriginalPercentageTakeRate);
            }
            else
            {
                displayValue = me.formatVolume(revertedChange.OriginalVolume);
                displayValue2 = me.formatFractionalPercentageTakeRate(revertedChange.OriginalPercentageTakeRate);
            }
            var selector, selector2;
            if (revertedChange.IsFeatureSummary)
            {
                selector = $("tbody span[data-target='FS|" + revertedChange.DataTarget + "']");
            }
            else if (revertedChange.IsModelSummary)
            {
                selector = $("thead th[data-target='MS|" + revertedChange.DataTarget + "']").first();
            }
            else if (revertedChange.IsWholeMarketChange)
            {
                selector = $("#" + me.getIdentifierPrefix() + "_MarketVolume");
                selector2 = $("#" + me.getIdentifierPrefix() + "_MarketPercentageTakeRate");
            }
            else if (revertedChange.IsAllMarketChange)
            {
                selector = $("#" + me.getIdentifierPrefix() + "_AllMarketVolume");
                displayValue = me.formatVolume(revertedChange.OriginalVolume);
            }
            else
            {
                selector = $("tbody div[data-target='" + revertedChange.DataTarget + "']");
            }

            selector.html(displayValue);
            if (selector2 != null && displayValue2 != null) {
                selector2.html(displayValue2);
            }

            // If the data has been reverted back in to the original committed change
            // Remove any classes indicated that it has been edited

            var editedDataClass = me.getEditedDataClass(revertedChange);
            if (revertedChange.IsReverted) {
                selector.removeClass(editedDataClass);
                if (selector2 != null) {
                    selector2.removeClass(editedDataClass);
                }
            } else {
                selector.addClass(editedDataClass);
                if (selector2 != null) {
                    selector2.addClass(editedDataClass);
                }
            }

            // Load the model mix

            if (revertedData.ModelMix.HasModelMixChanged === false && me.getResultsMode() === "PercentageTakeRate") {
                $(".model-mix-total").each(function () {
                    $(this).html(me.formatPercentageTakeRate(revertedData.ModelMix.ModelMix * 100)).removeClass(me.getEditedDataClass(revertedData.ModelMix));
                });
            }
            else if (revertedData.ModelMix.HasModelVolumeChanged === false) {
                $(".model-mix-total").each(function () {
                    $(this).html(me.formatVolume(revertedData.ModelMix.ModelVolume)).removeClass(me.getEditedDataClass(revertedData.ModelMix));
                });
            }
        }
        $("#" + me.getIdentifierPrefix() + "_Spinner").spin("hide");
    };
    me.loadChangesetCallback = function (changesetData) {
        var changeset = getChangeset();
        changeset.clear();
        me.confirmLoadChangeset(changesetData);
    };
    me.revertChangeset = function () {
        getTakeRateDataModel().revertChangeset(me.revertChangesetCallback);
    };
    me.revertChangesetCallback = function (revertedData) {
        var changeset = getChangeset();
        changeset.clear();

        for (var i = 0; i < revertedData.Changes.length; i++) {
            if (me.getResultsMode() === "PercentageTakeRate") {
                var currentChange = revertedData.Changes[i];
                var displayValue = me.formatPercentageTakeRate(currentChange.PercentageTakeRate);

                var selector;
                if (currentChange.IsFeatureSummary) {
                    selector = $("tbody span[data-target='FS|" + currentChange.DataTarget + "']");
                }
                else if (currentChange.IsModelSummary) {
                    selector = $("thead th[data-target='" + currentChange.DataTarget + "']");
                }
                else if (currentChange.IsWholeMarketChange) {
                    selector = $("#" + me.getIdentifierPrefix() + "_MarketVolume");
                }
                else if (currentChange.IsAllMarketChange) {
                    selector = $("#" + me.getIdentifierPrefix() + "_AllMarketVolume");
                }
                else {
                    selector = $("tbody td[data-target='" + currentChange.DataTarget + "']");
                }
                selector.removeClass(me.getEditedDataClass(currentChange)).html(displayValue);
            }
        }
    };
    me.getEditedDataClass = function (changesetChange) {
        var className;
        if (changesetChange.IsModelMix) {
            className = me.getEditedDataClassForModelMix(changesetChange);
        }
        else if (changesetChange.IsFeatureSummary) {
            className = me.getEditedDataClassForFeatureSummary(changesetChange);
        }
        else if (changesetChange.IsModelSummary) {
            className = me.getEditedDataClassForModelSummary(changesetChange);
        }
        else if (changesetChange.IsWholeMarketChange || changesetChange.IsAllMarketChange) {
            className = me.getEditedDataClassForMarket(changesetChange);
        }
        else {
            className = me.getEditedDataClassForDataItem(changesetChange);
        }
        return className;
    };
    me.getValidationDataClass = function(validationResult) {
        var className;
        if (validationResult.IsFeatureValidation) {
            className = me.getValidationDataClassForFeatureSummary(validationResult);
        }
        else if (validationResult.IsModelValidation) {
            className = me.getValidationDataClassForModelSummary(validationResult);
        }
        else {
            className = me.getValidationDataClassForDataItem(validationResult);
        }
        return className;
    }
    me.getEditedDataClassForFeatureSummary = function (changesetChange) {
        var className = "edited";
        if (changesetChange.FeatureIdentifier !== null && changesetChange.FeatureIdentifier.charAt(0) === "F") {
            className = "edited-fdp-data";
        }
        if (changesetChange.IsMarketReview) {
            className = className + "-market-review";
        }
        return className;
    };
    me.getEditedDataClassForModelSummary = function (changesetChange) {
        var className = "edited";
        if (changesetChange.ModelIdentifier !== null && changesetChange.ModelIdentifier.charAt(0) === "F") {
            className = "edited";
        }
        if (changesetChange.IsMarketReview) {
            className = className + "-market-review";
        }
        return className;
    };
    me.getEditedDataClassForModelMix = function (changesetChange) {
        var className = "edited";
        
        if (changesetChange.IsMarketReview) {
            className = className + "-market-review";
        }
        return className;
    };
    me.getEditedDataClassForMarket = function (changesetChange) {
        var className = "edited";
        if (changesetChange.IsMarketReview) {
            className = className + "-market-review";
        }
        return className;
    };
    me.getEditedDataClassForDataItem = function (changesetChange) {
        var className = "edited";
        if (changesetChange.FeatureIdentifier !== null && changesetChange.FeatureIdentifier.charAt(0) === "F") {
            className = "edited";
        }
        if (changesetChange.IsMarketReview) {
            className = className + "-market-review";
        }
        return className;
    };
    me.getValidationDataClassForFeatureSummary = function (validationResult) {
        var className = "validation";
        if (validationResult.FeatureIdentifier !== null && validationResult.FeatureIdentifier.charAt(0) === "F") {
            className = "validation-fdp-data";
        }
        return className;
    };
    me.getValidationDataClassForModelSummary = function (validationResult) {
        var className = "validation";
        if (validationResult.ModelIdentifier !== null && validationResult.ModelIdentifier.charAt(0) === "F") {
            className = "validation";
        }
        return className;
    };
    me.getValidationDataClassForDataItem = function (validationResult) {
        var className = "validation";
        if (validationResult.FeatureIdentifier !== null && validationResult.FeatureIdentifier.charAt(0) === "F") {
            className = "validation-fdp-data";
        }
        return className;
    };
    me.onPersistEventHandler = function () {
        me.persistData();
    };
    me.onUndoEventHandler = function() {
        me.undoData();
    };
    me.onUndoAllEventHandler = function () {
        me.undoAllData();
    };
    me.onHistoryEventHandler = function () {
        me.showHistory();
    };
    me.onHistoryDetailsEventHandler = function (sender, eventArgs) {
        me.showHistoryDetails(eventArgs.ChangesetId);
    };
    me.onPowertrainEventHandler = function() {
        me.showPowertrain();
    };
    me.onValidationSummaryEventHandler = function () {
        me.showValidationSummary();
    };
    me.onFilterEventHandler = function() {
        me.showFilter();
    };
    me.onValidationNavigationEventHandler = function(sender, eventArgs) {
        var dataTable = me.getDataTable();

        var selector = $("td[data-feature='" + eventArgs + "']").first().parent();

        var rowIndex = dataTable.rows(selector);

        dataTable.row(rowIndex).scrollTo();
    };
    me.onMarketReviewEventHandler = function(sender, eventArgs) {
        switch (eventArgs.MarketReviewStatus)
        {
            case 1:
                me.marketReview(eventArgs.MarketReviewStatus);
                break;
            case 2:
                me.submitMarketReview(eventArgs.MarketReviewStatus);
                break;
            case 3:
                me.rejectMarketReview(eventArgs.MarketReviewStatus);
                break;
            case 4:
                me.approveMarketReview(eventArgs.MarketReviewStatus);
                break;
            default:
                me.marketReview(eventArgs.MarketReviewStatus);
                break;
        }
    };
    me.onPublishEventHandler = function (sender, eventArgs) {
        me.publish();
    };
    me.marketReview = function(marketReviewStatus) {
        var model = getMarketReviewModel();
        model.setMarketReviewStatus(marketReviewStatus);
        var action = model.getMarketReviewAction();
        var actionModel = model.getActionModel(action);
        var filter = getFilter("");
        filter.Action = action;
        filter.MarketReviewStatus = marketReviewStatus;

        getModal().showModal({
            Title: "Market Review",
            Uri: model.getActionContentUri(),
            Data: JSON.stringify(filter),
            Model: model,
            ActionModel: actionModel
        });
    };
    me.publish = function() {
        var model = getPublishModel();
        var action = model.getPublishAction();
        var actionModel = model.getActionModel(action);
        var filter = getFilter("");
        filter.Action = action;

        getModal().showModal({
            Title: "Publish",
            Uri: model.getActionContentUri(),
            Data: JSON.stringify(filter),
            Model: model,
            ActionModel: actionModel
        });
    }
    me.submitMarketReview = function(marketReviewStatus) {
        var model = getMarketReviewModel();
        model.setMarketReviewStatus(marketReviewStatus);
        var action = model.getMarketReviewAction();
        var actionModel = model.getActionModel(action);
        var filter = getFilter("");
        filter.Action = action;
        filter.MarketReviewStatus = marketReviewStatus;

        getModal().showModal({
            Title: "Submit Market Review",
            Uri: model.getActionContentUri(),
            Data: JSON.stringify(filter),
            Model: model,
            ActionModel: actionModel
        });
    };
    me.rejectMarketReview = function (marketReviewStatus) {
        var model = getMarketReviewModel();
        model.setMarketReviewStatus(marketReviewStatus);
        var action = model.getMarketReviewAction();
        var actionModel = model.getActionModel(action);
        var filter = getFilter("");
        filter.Action = action;
        filter.MarketReviewStatus = marketReviewStatus;

        getModal().showModal({
            Title: "Reject Market Review",
            Uri: model.getActionContentUri(),
            Data: JSON.stringify(filter),
            Model: model,
            ActionModel: actionModel
        });
    };
    me.approveMarketReview = function (marketReviewStatus) {
        var model = getMarketReviewModel();
        model.setMarketReviewStatus(marketReviewStatus);
        var action = model.getMarketReviewAction();
        var actionModel = model.getActionModel(action);
        var filter = getFilter("");
        filter.Action = action;
        filter.MarketReviewStatus = marketReviewStatus;

        getModal().showModal({
            Title: "Approve Market Review",
            Uri: model.getActionContentUri(),
            Data: JSON.stringify(filter),
            Model: model,
            ActionModel: actionModel
        });
    };
    me.onUpdateFilterVolumeEventHandler = function (sender, eventArgs) {
        var marketIdentifier = getTakeRateDataModel().getMarketId();
        var changeSet = getChangeset();
        var priorChanges = changeSet.getChangesForMarket(marketIdentifier);

        if (priorChanges.length > 0 && (
                (eventArgs.Mode === "PercentageTakeRate" && eventArgs.getChangedTakeRate() === priorChanges[0].getOriginalTakeRate()) ||
                (eventArgs.Mode === "Raw" && eventArgs.getChangedVolume() === priorChanges[0].getOriginalVolume())))
        {
            changeSet.removeChangesForMarket(marketIdentifier);
        }
        else
        {
            changeSet.addChange(eventArgs);
        }
        me.saveData(me.saveCallback);
    };
    me.configureComments = function () {

        var prefix = me.getIdentifierPrefix();

        // We need to destroy and re-initialise the popovers each time the filter results is performed
        // Otherwise we get unexpected results

        $("[data-toggle='popover']").popover("destroy");

        $(".comment-item")
            .each(function () {
                var commentItem = $(this);
                if (commentItem.is(":visible")) {
                    commentItem
                        .popover({
                            html: true,
                            title: "Comments",
                            container: "body",
                            trigger: "hover",
                            placement: "auto bottom"
                        })
                        .on("click", function() {
                            $("[data-toggle='popover']")
                                .is(":visible")
                                .popover("hide");
                        });
                }
            });


        $(".rule-item")
            .each(function() {
                var ruleItem = $(this);
                if (ruleItem.is(":visible")) {
                    ruleItem.popover({
                        html: true,
                        title: "Rules",
                        container: "body",
                        trigger: "hover",
                        placement: "auto bottom"
                    });
                };
            });

        $(".efg-item")
            .each(function () {
                var efgItem = $(this);
                if (efgItem.is(":visible")) {
                    efgItem.popover({
                        html: true,
                        title: "Exclusive Feature Group",
                        container: "body",
                        trigger: "hover",
                        placement: "auto bottom"
                    });
                }
            });

        $(".pack-item")
            .each(function () {
                var packItem = $(this);
                if (packItem.is(":visible")) {
                    packItem.popover({
                        html: true,
                        container: "body",
                        placement: "auto bottom",
                        trigger: "manual",
                        title: "Pack Contents <span class='glyphicon glyphicon-filter'></span> Click to Filter"
                    })
                    .unbind("mouseenter").on("mouseenter", function () {
                        packItem.popover("show");
                    })
                    .unbind("mouseleave").on("mouseleave", function () {
                        packItem.popover("hide");
                    })
                    .unbind("click").on("click", function () {
                        var filter = $(this).attr("data-filter");
                        $("[data-toggle='popover']").popover("destroy");
                        me.filter(filter);
                    });
                }
            });

        $(".feature-pack-item")
            .each(function () {
                var featurePackItem = $(this);
                if (featurePackItem.is(":visible")) {
                    featurePackItem
                        .data("state", "hover")
                        .popover({
                            html: true,
                            container: "body",
                            placement: "auto bottom",
                            trigger: "manual",
                            title: "Feature Packs <span class='glyphicon glyphicon-filter'></span> Click Pack Name to Filter"
                        })
                        .unbind("mouseenter").on("mouseenter", function () {
                            if (featurePackItem.data("state") === "hover")
                                featurePackItem.popover("show");
                        })
                        .unbind("mouseleave").on("mouseleave", function () {
                            if (featurePackItem.data("state") === "hover")
                                featurePackItem.popover("hide");
                        })
                        .unbind("click").on("click", function () {
                            if (featurePackItem.data("state") === "hover") {
                                featurePackItem.data("state", "pinned");
                                $(".feature-pack-item-header").unbind("click").on("click", function () {
                                    var filter = $(this).attr("data-filter");
                                    $("[data-toggle='popover']").popover("destroy");
                                    me.filter(filter);
                                });
                            } else {
                                featurePackItem
                                    .data("state", "hover")
                                    .popover("hover");
                            }
                        });
                }
            });

        var validationErrors = $(".feature-validation-error, .model-validation-error, .primary-validation-error");
        validationErrors.each(function () {
            var error = $(this);
            if (error.is(":visible")) {
                error
                    .popover({
                        html: true,
                        title: "Validation Error",
                        container: "body",
                        trigger: "hover",
                        placement: "auto bottom"
                    })
                .on("click", function () {
                    validationErrors.not(error).each(function () {
                        if ($(this).is(":visible")) {
                            $(this).popover("hide");
                        }
                    });
                });
            }
        });

        $("#" + prefix + "_Save").popover({ trigger: "hover", title: "Save Changes", placement: "auto bottom", container: "body" });
        $("#" + prefix + "_Publish").popover({ trigger: "hover", title: "Publish", placement: "auto bottom", container: "body" });
        $("#" + prefix + "_Undo").popover({ trigger: "hover", title: "Undo", placement: "auto bottom", container: "body" });
        $("#" + prefix + "_UndoAll").popover({ trigger: "hover", title: "Undo All", placement: "auto bottom", container: "body" });
        $("#" + prefix + "_History").popover({ trigger: "hover", title: "Change History", placement: "auto bottom", container: "body" });
        $("#" + prefix + "_Validation").popover({ trigger: "hover", title: "Validation Summary", placement: "auto bottom", container: "body" });
        $("#" + prefix + "_Powertrain").popover({ trigger: "hover", title: "Derivative Mix Data", placement: "auto bottom", container: "body" });
        $("#" + prefix + "_Filter").popover({ trigger: "hover", title: "Filter", placement: "auto bottom", container: "body" });
        $("#" + prefix + "_Toggle").popover({ trigger: "hover", title: "Toggle", placement: "auto bottom", container: "body" });
        $("#" + prefix + "_Filter").popover({ trigger: "hover", title: "Filter", placement: "auto bottom", container: "body" });

        $("#" + prefix + "_MarketReview").popover({ trigger: "hover", title: "Market Review", placement: "auto bottom", container: "body" });
        $("#" + prefix + "_SubmitMarketReview").popover({ trigger: "hover", title: "Market Review", placement: "auto bottom", container: "body" });
        $("#" + prefix + "_ApproveMarketReview").popover({ trigger: "hover", title: "Market Review", placement: "auto bottom", container: "body" });
        $("#" + prefix + "_RejectMarketReview").popover({ trigger: "hover", title: "Market Review", placement: "auto bottom", container: "body" });
        $("#" + prefix + "_RecallMarketReview").popover({ trigger: "hover", title: "Market Review", placement: "auto bottom", container: "body" });

        $("#" + prefix + "_FirstPage").popover({ trigger: "hover", title: "First Page", placement: "auto bottom", container: "body" });
        $("#" + prefix + "_PrevPage").popover({ trigger: "hover", title: "Previous Page", placement: "auto bottom", container: "body" });
        $("#" + prefix + "_NextPage").popover({ trigger: "hover", title: "Next Page", placement: "auto bottom", container: "body" });
        $("#" + prefix + "_LastPage").popover({ trigger: "hover", title: "Last Page", placement: "auto bottom", container: "body" });

        //$(window).on("resize", function () {
        //    me.getDataTable().destroy();
        //    me.configureDataTables();
        //});
    };
    me.configureMarkets = function() {
        privateStore[me.id].Markets = new Bloodhound({
            datumTokenizer: Bloodhound.tokenizers.obj.whitespace("Name"),
            queryTokenizer: Bloodhound.tokenizers.whitespace,
            prefetch: getTakeRateDataModel().getMarketUri()
        });
        $("#" + me.getIdentifierPrefix() + "_Markets .typeahead").typeahead(null, {
            name: "Markets",
            display: "Name",
            source: privateStore[me.id].Markets,
            templates: {
                empty: "<div class='empty-message'>No matching markets</div>",
                highlighter: function(item) {
                    var parts = item.split("#");
                    var html = "<div class='typeahead'>";
                    html += "<div class='pull-left margin-small'>";
                    html += "<div class='text-left'><strong>" + parts[0] + "</strong></div>";
                    html += "<div class='text-left'>" + parts[1] + "</div>";
                    html += "</div>";
                    html += "<div class='clearfix'></div>";
                    html += "</div>";
                    return html;
                },
                    suggestion: function(data) {
                        var html = "<p><strong>" + data.Name + "</strong></p>";
                        html += "<p>Number of Model Variants:" + data.VariantCount + "</p>";
                        html += "<p>Market Group" + data.GroupName + "</p>";
                        return html;
                    }
                
            }
        });
    };
    me.configureDataTables = function () {

        var prefix = me.getIdentifierPrefix();
        var filterModel = getFilterModel();
        var height = me.calcDataTableHeight();
        var leftFixedColumns = 4;

        me.showSpinner("Loading Data");
        
        var table = $("#" + prefix + "_TakeRateData").DataTable({
            serverSide: false,
            paging: false,
            ordering: false,
            processing: false,
            dom: "t",
            scrollX: true,
            //autoWidth: false,
            scrollY: height,
            scrollCollapse: true
        });
        var fixedColumns = new $.fn.dataTable.FixedColumns(table, {
            leftColumns: leftFixedColumns,
            drawCallback: function (left) {
                //// If we are filtering, remove the row groupings, as they aren't necessary and mess up the resizing
                //// upon filter
                if (filterModel.getCurrentFilter() === null || filterModel.getCurrentFilter() === "") {
                    me.configureRowGroupings(table, left);
                }
                me.bindContextMenu();
                me.configureRowHighlight();
            }
        });

        me.setDataTable(table);
    };
    me.configureRowGroupings = function(table, left) {
        var settings = table.settings();

        var displayedRecords = settings.page.info().recordsDisplay;
        //var displayedRecords = settings.aoData.length;
        if (displayedRecords === 0) {
            $(".dataTables_empty").html("No data");
            return;
        }

        var nGroup, nSubGroup, nCell, groupName, subGroupName;
        var lastGroupName = "", lastSubGroupName = "", corrector = 0;
        var nTrs = $("#" + me.getIdentifierPrefix() + "_TakeRateData tbody tr");
        var rightColumns = nTrs.first().children().length;

        for (var i = 0; i < nTrs.length; i++) {
            //index = settings.page.info().start + i;
            groupName = $(nTrs[i]).attr("data-group");
            subGroupName = $(nTrs[i]).attr("data-subgroup");

            if (groupName !== lastGroupName) {
                /* Cell to insert into main table */
                nGroup = document.createElement("tr");
                nCell = document.createElement("td");
                nCell.colSpan = rightColumns;
                nCell.className = "group";
                nCell.innerHTML = "&nbsp;";
                nGroup.appendChild(nCell);
                $(nGroup).attr("data-toggle", groupName);
                nTrs[i].parentNode.insertBefore(nGroup, nTrs[i]);
                $(nGroup).on("click", function() {
                    var clickedGroup = $(this).attr("data-toggle");
                    $("tbody tr[data-group='" + clickedGroup + "']").toggle();
                });

                /* Cell to insert into the frozen columns */
                nGroup = document.createElement("tr");
                nCell = document.createElement("td");
                nCell.className = "group";
                nCell.innerHTML = "<span class=\"glyphicon glyphicon-minus\"></span> " + groupName;
                nCell.colSpan = 4;
                $(nGroup).attr("data-toggle", groupName);
                nGroup.appendChild(nCell);
                $(nGroup).insertBefore($("tbody tr:eq(" + (i + corrector) + ")", left.body)[0]);
                $(nGroup).on("click", function() {
                    var clickedGroup = $(this).attr("data-toggle");
                    var rows = $("tbody tr[data-group='" + clickedGroup + "']").toggle();
                    if ($(rows[0]).is(":visible")) {
                        $(this).find("span").removeClass("glyphicon-plus").addClass("glyphicon-minus");
                    } else {
                        $(this).find("span").removeClass("glyphicon-minus").addClass("glyphicon-plus");
                    }
                });

                corrector++;
                lastGroupName = groupName;
            }


            if (subGroupName !== lastSubGroupName) {
                if (subGroupName !== "") {
                    /* Cell to insert into main table */
                    nSubGroup = document.createElement("tr");
                    nCell = document.createElement("td");
                    nCell.colSpan = rightColumns;
                    nCell.className = "sub-group";
                    nCell.innerHTML = "&nbsp;";
                    $(nSubGroup).attr("data-group", groupName)
                    $(nSubGroup).attr("data-toggle", subGroupName);
                    nSubGroup.appendChild(nCell);
                    nTrs[i].parentNode.insertBefore(nSubGroup, nTrs[i]);
                    $(nSubGroup).on("click", function(sender, eventArgs) {
                        var clickedGroup = $(this).attr("data-toggle");
                        $("tbody tr[data-subgroup='" + clickedGroup + "']").toggle();
                    });

                    /* Cell to insert into the frozen columns */
                    nSubGroup = document.createElement("tr");
                    nCell = document.createElement("td");
                    nCell.className = "sub-group";
                    nCell.innerHTML = "<span class=\"glyphicon glyphicon-minus\"></span> " + subGroupName;
                    nCell.colSpan = 4;
                    $(nSubGroup).attr("data-group", groupName);
                    $(nSubGroup).attr("data-toggle", subGroupName);
                    nSubGroup.appendChild(nCell);
                    $(nSubGroup).insertBefore($("tbody tr:eq(" + (i + corrector) + ")", left.body)[0]);
                    $(nSubGroup).on("click", function() {
                        var clickedGroup = $(this).attr("data-toggle");
                        var rows = $("tbody tr[data-subgroup='" + clickedGroup + "']").toggle();
                        if ($(rows[0]).is(":visible")) {
                            $(this).find("span").removeClass("glyphicon-plus").addClass("glyphicon-minus");
                        } else {
                            $(this).find("span").removeClass("glyphicon-minus").addClass("glyphicon-plus");
                        }
                    });

                    corrector++;
                }
                lastSubGroupName = subGroupName;
            }
        }

        privateStore[me.id].RowOffset = corrector;

        // Clear spurious child elements from the hidden sizing columns
        $(".dataTables_sizing").empty();
    };
    me.bindContextMenuForPublish = function() {
        var prefix = me.getIdentifierPrefix();
        $.contextMenu({
            selector: "#" + prefix + "_TakeRateData .cross-tab-data-item",
            callback: function (key, options) {
                //var m = "clicked: " + key;
                //window.console && console.log(m) || alert(m);
            },
            items: {
                view: {
                    name: "ViewDetails",
                    icon: function (opt, $itemElement) {
                        // Set the content to the menu trigger selector and add an bootstrap icon to the item.
                        $itemElement.html('<span class="glyphicon glyphicon-info-sign" aria-hidden="true"></span> View Details...' + opt.selector);
                    },
                    callback: function (itemKey, opt) {
                        var target = opt.$trigger.children().first();
                        me.actionTriggered(target, 4);
                    }
                }
            },
            className: "context-menu-custom"
        });
        $.contextMenu({
            selector: "#" + prefix + "_TakeRateDataPanel .model-mix",
            callback: function (key, options) {
                //var m = "clicked: " + key;
                //window.console && console.log(m) || alert(m);
            },
            items: {
                view: {
                    name: "ViewDetails",
                    icon: function (opt, $itemElement) {
                        // Set the content to the menu trigger selector and add an bootstrap icon to the item.
                        $itemElement.html('<span class="glyphicon glyphicon-info-sign" aria-hidden="true"></span> View Model Mix Details...' + opt.selector);
                    },
                    callback: function (itemKey, opt) {
                        var target = opt.$trigger;
                        me.actionTriggered(target, 4);
                    }
                }
            },
            className: "context-menu-custom"
        });
    },
    me.bindContextMenu = function () {
        var prefix = me.getIdentifierPrefix();

        var isPublished = parseInt($("#" + prefix + "_Published").val());
        if (isPublished === 1) {
            me.bindContextMenuForPublish();
            return;
        }
        $.contextMenu({
            selector: "#" + prefix + "_TakeRateData .cross-tab-data-item",
            callback: function (key, options) {
                //var m = "clicked: " + key;
                //window.console && console.log(m) || alert(m);
            },
            items: {
                view: {
                    name: "ViewDetails",
                    icon: function (opt, $itemElement) {
                        // Set the content to the menu trigger selector and add an bootstrap icon to the item.
                        $itemElement.html('<span class="glyphicon glyphicon-info-sign" aria-hidden="true"></span> View Details...' + opt.selector);
                    },
                    callback: function (itemKey, opt) {
                        var target = opt.$trigger.children().first();
                        me.actionTriggered(target, 4);
                    }
                },
                addNote: {
                    name: "AddNote",
                    icon: function (opt, $itemElement) {
                        // Set the content to the menu trigger selector and add an bootstrap icon to the item.
                        $itemElement.html('<span class="glyphicon glyphicon-pencil" aria-hidden="true"></span> Add Note...' + opt.selector);
                    },
                    callback: function (itemKey, opt) {
                        var target = opt.$trigger.children().first();
                        me.actionTriggered(target, 8);
                    }
                }
            },
            className: "context-menu-custom"
        });
        $.contextMenu({
            selector: "#" + prefix + "_TakeRateDataPanel .model-mix",
            callback: function(key, options) {
                //var m = "clicked: " + key;
                //window.console && console.log(m) || alert(m);
            },
            items: {
                view: {
                    name: "ViewDetails",
                    icon: function(opt, $itemElement) {
                        // Set the content to the menu trigger selector and add an bootstrap icon to the item.
                        $itemElement.html('<span class="glyphicon glyphicon-info-sign" aria-hidden="true"></span> View Model Mix Details...' + opt.selector);
                    },
                    callback: function(itemKey, opt) {
                        var target = opt.$trigger;
                        me.actionTriggered(target, 4);
                    }
                },
                addNote: {
                    name: "AddNote",
                    icon: function(opt, $itemElement) {
                        // Set the content to the menu trigger selector and add an bootstrap icon to the item.
                        $itemElement.html('<span class="glyphicon glyphicon-pencil" aria-hidden="true"></span> Add Note...' + opt.selector);
                    },
                    callback: function(itemKey, opt) {
                        var target = opt.$trigger;
                        me.actionTriggered(target, 8);
                    }
                }
            },
            className: "context-menu-custom"
        });
    };
    me.raiseFilteredVolumeChanged = function () {

        var marketIdentifier = getTakeRateDataModel().getMarketId();
        var change = new FeatureDemandPlanning.Volume.Change(marketIdentifier, null, null);
        change.Mode = me.getResultsMode();
        var formattedValue = "";
        if (change.Mode === "PercentageTakeRate") {

            change.setOriginalTakeRate(me.getOriginalTakeRateByMarket());
            change.setChangedTakeRate(me.parseCellValue(me.getChangedTakeRateByMarket()));

            if (change.isValid()) {
                formattedValue = me.formatPercentageTakeRate(change.getChangedTakeRate());
            } else {
                formattedValue = me.formatPercentageTakeRate(change.getOriginalTakeRate());
            }

        } else {

            change.setOriginalVolume(me.getOriginalVolumeByMarket());
            change.setChangedVolume(me.parseCellValue(me.getChangedVolumeByMarket()));

            if (change.getChangedVolume() == null && change.getOriginalVolume() != null) {
                formattedValue = me.formatVolume(change.getOriginalVolume());
            } else {
                formattedValue = me.formatVolume(change.getChangedVolume());
            }
        }
        $(document).trigger("UpdateFilterVolume", change);
    };
    me.getOriginalTakeRateByMarket = function () {
        var prefix = me.getIdentifierPrefix();
        return parseFloat($("#" + prefix + "_OriginalTakeRateByMarket").val()).toFixed(2);
    };
    me.getChangedTakeRateByMarket = function () {
        return $(".input-filtered-volume").val();
    };
    me.getOriginalVolumeByMarket = function () {
        var prefix = me.getIdentifierPrefix();
        return parseInt($("#" + prefix + "_OriginalVolumeByMarket").val());
    };
    me.getChangedVolumeByMarket = function () {
        return $(".input-filtered-volume").val();
    };
    me.getDataItemId = function (cell) {
        return $(cell).children().first().attr("data-target");
    };
    me.getModelMixDataItemId = function(cell) {
        return $(cell).attr("data-target").replace("MS|", "");
    };
    me.getContextMenu = function (dataItemString) {
        var params = getFilter(dataItemString);
        $.ajax({
            "dataType": "html",
            "async": true,
            "type": "POST",
            "url": getTakeRateDataModel().getActionsUri(),
            "data": params,
            "success": function (response) {
                $("#" + me.getIdentifierPrefix() + "_ContextMenu").html(response);
            },
            "error": function (jqXHR, textStatus, errorThrown) {
                alert(errorThrown);
            }
        });
    };
    me.actionTriggered = function (invokedOn, action) {
        var dataItemString = $(invokedOn).data("target");
        dataItemString = dataItemString.replace("MS|", "");
        var filter = getFilter(dataItemString);
        filter.Action = action,

        $(document).trigger("Action", filter);
    };
    me.onActionEventHandler = function (sender, eventArgs) {
        var action = eventArgs.Action;
        var model = getModelForAction(action);
        var actionModel = model.getActionModel(action);

        getModal().showModal({
            Title: model.getActionTitle(action),
            Uri: model.getActionContentUri(action),
            Data: JSON.stringify(eventArgs),
            Model: model,
            ActionModel: actionModel
        });
    };
    me.parseInputData = function (value) {
        var parsedValue = value.replace("%", "");
        parsedValue = parsedValue.replace("-", "");
        parsedValue = parsedValue.replace(",", "");
        var trimmedValue = $.trim(parsedValue);
        return trimmedValue;
    };
    me.onValidationEventHandler = function (sender, eventArgs) {
        me.getValidationMessage(eventArgs);
    };
    me.getValidationMessage = function (validationResults) {
        $.ajax({
            method: "POST",
            url: getTakeRateDataModel().getValidationMessageUri(),
            data: JSON.stringify(validationResults),
            context: this,
            contentType: "application/json",
            success: me.getValidationMessageCallback,
            error: me.getValidationMessageError,
            async: true
        });
    };
    me.getValidationMessageCallback = function (response) {
        var html = "";
        if (response !== "") {
            html = response;
        }
        me.fadeInNotify(html);
    };
    me.fadeOutNotify = function() {
        var control = $("#notifier");
        if (control.is(":visible")) {
            control.fadeOut("slow");
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
    me.scrollToNotify = function() {
        $("html, body").animate({
            scrollTop: $("#notifier").offset().top - 80
    }, 500);
    };
    me.getValidationMessageError = function (jqXHR, textStatus, errorThrown) {
        //console.log("Validate: " + errorThrown);
    };
    me.onBeforeValidationFilterEventHandler = function (sender, eventArgs) {
        $(sender.target).removeClass("has-error").removeClass("has-warning");
    };
    me.onValidationFilterEventHandler = function (sender, eventArgs) {
        $(eventArgs.Errors).each(function () {
            if ($(sender.target).attr("data-val") == this.key) {
                $(sender.target).addClass("has-error");
            }
        });
    };
    me.onSuccessEventHandler = function (sender, eventArgs) {
        if (eventArgs.Message === "") {
            me.fadeOutNotify();
            return;
        }
        if (eventArgs.Message !== null && eventArgs.Message !== undefined) {
            var html = "<div class=\"alert alert-dismissible alert-success\">" + eventArgs.Message + "</div>";
            me.scrollToNotify();
            me.fadeInNotify(html);
        }
    };
    me.onErrorEventHandler = function (sender, eventArgs) {
        var html = "<div class=\"alert alert-dismissible alert-danger\">" + eventArgs.Message + "</div>";
        me.scrollToNotify();
        me.fadeInNotify(html);
    };
    me.filterItem = function(item) {
        var filter = $(item).attr("data-filter");
        me.filter(filter);
    }
    me.filter = function(searchFilter) {
        $(document).trigger("Filtered", { Filter: searchFilter });
    };
    me.onFilterChangedEventHandler = function (sender, eventArgs) {
        //console.log("filter changed");
        var filter = eventArgs.Filter;
        getFilterModel().setCurrentFilter(filter);
        me.getDataTable().search(filter).draw();
    };
    me.onUpdatedEventHandler = function (sender, eventArgs) {
        $("#notifier").html("<div class=\"alert alert-dismissible alert-success\">" + eventArgs.StatusMessage + "</div>");
    };
    me.onNoteAddedEventHandler = function(sender, eventArgs) {
        me.loadChangeset();
    };
    me.redrawDataTable = function () {
        //console.log("in redraw");
        me.getDataTable().draw();
    };
    me.getExpandedState = function() {
        return privateStore[me.id].Expanded;
    };
    me.setExpandedState = function(state) {
        privateStore[me.id].Expanded = state;
        if (state) {
            $("#" + me.getIdentifierPrefix() + "_Toggle").find("span").removeClass("glyphicon-plus").addClass("glyphicon-minus");
        } else {
            $("#" + me.getIdentifierPrefix() + "_Toggle").find("span").removeClass("glyphicon-minus").addClass("glyphicon-plus");
        }
    };
    me.toggleGroups = function () {
        var toggleState = me.getExpandedState();
        $(".group").each(function() {
            var groupName = $(this).closest("tr").attr("data-toggle");
            if (toggleState) {
                $("tbody tr[data-group='" + groupName + "']").hide();
                $(this).find("span").removeClass("glyphicon-minus").addClass("glyphicon-plus");
            } else {
                $("tbody tr[data-group='" + groupName + "']").show();
                $(this).find("span").removeClass("glyphicon-plus").addClass("glyphicon-minus");
            }
        });
        $(".sub-group").each(function () {
            if (toggleState) {
                $(this).find("span").removeClass("glyphicon-minus").addClass("glyphicon-plus");
            } else {
                $(this).find("span").removeClass("glyphicon-plus").addClass("glyphicon-minus");
            }
        });
        me.setExpandedState(!toggleState);
    };
    me.toggleFdpVolumeHeader = function (data) {
        var fdpVolumeHeaderId = parseInt($(this).attr("data-target"));
        var model = getTakeRateDataModel();
 
        $(".fdp-volume-header-toggle").text("Select").removeClass("btn-danger").addClass("btn-primary");

        if (model.hasFdpVolumeHeader(fdpVolumeHeaderId)) {
            model.removeFdpVolumeHeader(fdpVolumeHeaderId);
        } else {
            model.addFdpVolumeHeader(fdpVolumeHeaderId);
        }

        $(".fdp-volume-header-toggle").each(function () {
            fdpVolumeHeaderId = parseInt($(this).attr("data-target"));
            if (model.hasFdpVolumeHeader(fdpVolumeHeaderId)) {
                $(this).removeClass("btn-primary").addClass("btn-danger").text("Unselect");
            } 
        });
    };
    function getChangeset() {
        return privateStore[me.id].Changeset;
    };
    function getTakeRateDataModel() {
        return getModel("OxoVolume");
    };
    function getModels() {
        return privateStore[me.id].Models;
    };
    function getModel(modelName) {
        var model = null;
        $(getModels()).each(function () {
            if (this.ModelName === modelName) {
                model = this;
                return false;
            }
        });
        return model;
    };
    function getCookies() {
        return getModel("Cookies");
    };
    function getDetailsModel() {
        return getModel("Details");
    };
    function getAddNoteModel() {
        return getModel("AddNote");
    };
    function getMarketReviewModel() {
        return getModel("MarketReview");
    };
    function getPublishModel() {
        return getModel("Publish");
    };
    function getFilterModel() {
        return getModel("Filter");
    };
    function getPowertrainModel() {
        return getModel("Powertrain");
    };
    function getModal() {
        return getModel("Modal");
    };
    function getModelForAction(actionId) {
        var model;
        switch (actionId) {
            case 4:
                model = getDetailsModel();
                break;
            case 8:
                model = getAddNoteModel();
                break;
            case 11:
                model = getMarketReviewModel();
                break;
            case 15:
                model = getPowertrainModel();
            default:
                break;
        }
        return model;
    };
    function getFilter(dataItemString) {
        var identifiers = dataItemString.split("|");
        var modelIdentifier = null;
        var featureIdentifier = null;
        var volume = getTakeRateDataModel();
        var takeRateId = volume.getTakeRateId();
        var documentId = volume.getOxoDocId();
        var marketId = volume.getMarketId();
        var marketGroupId = volume.getMarketGroupId();

        if (identifiers.length > 0 && identifiers[0] !== "") {
            marketId = identifiers[0];
        }
        if (identifiers.length > 1 && identifiers[1] !== "") {
            modelIdentifier = identifiers[1];
        }
        if (identifiers.length > 2 && identifiers[2] !== "") {
            featureIdentifier = identifiers[2];
        }
        return {
            TakeRateId: takeRateId,
            DocumentId: documentId,
            ModelIdentifier: modelIdentifier,
            FeatureIdentifier: featureIdentifier,
            MarketId: marketId,
            MarketGroupId: marketGroupId
        };
    };
};