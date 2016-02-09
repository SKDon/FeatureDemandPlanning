"use strict";

var model = namespace("FeatureDemandPlanning.Volume");

model.Page = function (models) {
    var uid = 0, privateStore = {}, me = this;

    privateStore[me.id = uid++] = {};
    privateStore[me.id].Models = models;
    privateStore[me.id].DataTable = null;
    privateStore[me.id].ResultsMode = "PercentageTakeRate";
    privateStore[me.id].Changeset = null;
    privateStore[me.id].Initial = true;
    privateStore[me.id].Expanded = true;
    
    me.initialise = function () {
        $(privateStore[me.id].Models).each(function () {
            this.initialise();
        });
        me.setResultsMode($("#" + me.getIdentifierPrefix() + "_Mode").val());
        me.loadData();
        me.registerEvents();
        me.registerSubscribers();
        me.loadChangeset();
        me.checkCompletion();
        me.validate();
    };
    me.calcPanelHeight = function () {
        return ($(window).height()) - 135 + "px";
    };
    me.calcDataTableHeight = function () {
        var panelHeight = $("#" + me.getIdentifierPrefix() + "_TakeRateDataPanel").height();
        return (panelHeight - 160) + "px";
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
        me.initialiseControls();
        me.configureDataTables();
        me.configureCellEditing();
        me.configureComments();
        me.configureChangeset();
        me.configureRowHighlight();
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
            Title: "Changeset History",
            Uri: model.getChangesetHistoryUri(),
            Data: JSON.stringify(filter),
            Model: model,
            ActionModel: actionModel
        });
    };
    me.undoData = function() {
        getTakeRateDataModel().undoData({ Data: getChangeset().getDataChanges() }, me.undoDataCallback);
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
        me.loadChangeset();
        me.revertData(revertedData);
    };
    me.reloadPage = function() {
        location.reload();
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
            .unbind("UpdateFilterVolume").on("UpdateFilterVolume", function (sender, eventArgs) { $(".subscribers-notify").trigger("OnUpdateFilterVolumeDelegate", [eventArgs]); });

        $("#" + prefix + "_Save").unbind("click").on("click", function (sender, eventArgs) { $(".subscribers-notify").trigger("OnPersistDelegate", [eventArgs]); });
        $("#" + prefix + "_Undo").unbind("click").on("click", function (sender, eventArgs) { $(".subscribers-notify").trigger("OnUndoDelegate", [eventArgs]); });
        $("#" + prefix + "_History").unbind("click").on("click", function (sender, eventArgs) { $(".subscribers-notify").trigger("OnHistoryDelegate", [eventArgs]); });
        $("#" + prefix + "_Toggle").unbind("click").on("click", function (sender, eventArgs) { $(".subscribers-notify").trigger("OnToggleDelegate", [eventArgs]); });
        $(".update-filtered-volume").unbind("click").on("click", function (sender, eventArgs) { me.raiseFilteredVolumeChanged(); });
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
            .unbind("OnUpdateFilterVolumeDelegate").on("OnUpdateFilterVolumeDelegate", me.onUpdateFilterVolumeEventHandler);

        $("#" + me.getIdentifierPrefix() + "_TakeRateDataPanel")
            .on("OnEditCellDelegate", me.onEditCellEventHandler)
            .on("OnSaveDelegate", me.onSaveEventHandler)
            .on("OnSavedDelegate", me.onSavedEventHandler)
            .on("OnPersistDelegate", me.onPersistEventHandler)
            .on("OnHistoryDelegate", me.onHistoryEventHandler)
            .on("OnUndoDelegate", me.onUndoEventHandler)
            .on("OnToggleDelegate", me.onToggleEventHandler);

        // Iterate through each of the forecast / comparison controls and register onclick / change handlers
        $(".fdp-volume-header-toggle").unbind("click").on("click", me.toggleFdpVolumeHeader);

        $("#" + prefix + "_FilterMessage").on("keyup", function (sender, eventArgs) {
            var length = $("#" + prefix + "_FilterMessage").val().length;
            if (length === 0 || length > 2) {
                me.onFilterChangedEventHandler(sender, eventArgs);
            }
        });

        $(window).resize(function () {
            var panel = $("#" + me.getIdentifierPrefix() + "_TakeRateDataPanel");
            var table = me.getDataTable();
            //var settings = table.settings();
            panel.height(me.calcPanelHeight());
            $("div.dataTables_scrollBody").css("height", me.calcDataTableHeight());
            table.draw();
        });       
    };
    me.configureCellEditing = function () {
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
    };
    me.configureRowHighlight = function() {
        $(document).on({
            mouseenter: function() {
                if (me.isGroup(this)) {
                    return;
                }
                var selector = $("table.dataTable");
                var rowIndex = $(this).closest("tr").index() + 4; // Add +4 as we need to exclude the additional header rows
                var columnIndex = $(this).index();
               
                var modelIdentifier = $(this).attr("data-model");
                
                // Highlight the cell itself and any previous siblings
                selector.find("tr:eq(" + rowIndex + ") td:lt(" + (columnIndex + 1) + ")").addClass("highlight");

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
        if (change.Mode === "PercentageTakeRate") {

            change.setOriginalTakeRate(me.parseCellValue(this.revert));
            change.setChangedTakeRate(me.parseCellValue(value));

            if (change.isValid()) {
                formattedValue = me.formatPercentageTakeRate(change.getChangedTakeRate());
            } else {
                formattedValue = me.formatPercentageTakeRate(change.getOriginalTakeRate());
            }

        } else {

            change.setOriginalVolume(me.parseCellValue(this.revert));
            change.setChangedVolume(me.parseCellValue(value));

            if (change.getChangedVolume() == null && change.getOriginalVolume() != null) {
                formattedValue = me.formatVolume(change.getOriginalVolume());
            } else {
                formattedValue = me.formatVolume(change.getChangedVolume());
            }
        }
        $(document).trigger("EditCell", change);

        return formattedValue;
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

        return formattedValue;
    };
    me.onEditCellEventHandler = function (sender, eventArgs) {
        var marketIdentifier = eventArgs.getMarketIdentifier();
        var modelIdentifier = eventArgs.getModelIdentifier();
        var featureIdentifier = eventArgs.getFeatureIdentifier();
         
        var editedCell;
        if (featureIdentifier !== null)
        {
            editedCell = $("tbody div[data-target='" + marketIdentifier + "|" + modelIdentifier + "|" + featureIdentifier + "']");
        }
        else
        {
            editedCell = $("thead th[data-target='MS|" + marketIdentifier + "|" + modelIdentifier + "']");
        }
        //var editedRow = $(".DTFC_Cloned tbody tr[data-target='" + marketIdentifier + "|" + featureIdentifier + "']");
        var changeSet = getChangeset();

        // If any changes have reverted back to the original value, we need to lower any change flags and remove from the changeset
        var priorChanges = changeSet.getChange(marketIdentifier, modelIdentifier, featureIdentifier);
        if (priorChanges != null && priorChanges.length > 0 && (
                (eventArgs.Mode === "PercentageTakeRate" && eventArgs.getChangedTakeRate() === priorChanges[0].getOriginalTakeRate()) ||
                (eventArgs.Mode === "Raw" && eventArgs.getChangedVolume() === priorChanges[0].getOriginalVolume())))
        {
            changeSet.removeChanges(marketIdentifier, modelIdentifier, featureIdentifier);
            editedCell.removeClass("edited");

            // If there are no other changes to the feature, lower the feature changed indicator
            //var otherFeatureChanges = changeSet.getChangesForFeature(featureIdentifier);
            //if (otherFeatureChanges == null || otherFeatureChanges.length == 0) {
            //    editedRow.find(".changed-indicator").hide();
            //}
        }
        else if (eventArgs.isChanged())
        {
            changeSet.addChange(eventArgs);
            editedCell.addClass("edited");
            //editedRow.find(".changed-indicator").show();

            // Now we have added to the client changeset, raise the save event to store the changeset on the database and perform any
            // recalculation necessary

            $(document).trigger("Save");
        }
    };
    me.onSaveEventHandler = function () {
        me.saveData(me.saveCallback);
    };
    me.onSavedEventHandler = function() {
        window.location.reload();
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
        me.loadValidation();
    };
    me.loadChangeset = function () {
        getTakeRateDataModel().loadChangeset(me.loadChangesetCallback);
    };
    me.loadValidation = function() {
        getTakeRateDataModel().loadValidation(me.loadValidationCallback);
    };
    me.loadValidationCallback = function(validationData) {
        
        var model = getTakeRateDataModel();
        var markets = [];
        var mainIndicator = $(".primary-validation-error");
        //var marketIndicators = $(".market-validation-error");
        var modelIndicators = $(".model-validation-error");
        var featureIndicators = $(".feature-validation-error");

        model.setHasValidationErrors(validationData !== null && validationData.length > 0);
        if (model.HasValidationErrors) {
            $("#" + me.getIdentifierPrefix() + "_Save").prop("disabled", true);
        }

        mainIndicator.hide();
        //marketIndicators.hide();
        featureIndicators.hide();
        modelIndicators.hide();

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
    };
    me.checkCompletion = function() {
        var model = getTakeRateDataModel();
        var isImportCompleted = model.isImportCompleted();
        if (!isImportCompleted)
        {
            getModal().showAlert("Incomplete Data",
                "The import process for this take rate file has not been completed and still contains errors.<br/><br/>" +
                "The dataset will be incomplete and should be edited with caution.", 2);
        }
    };
    me.confirmLoadChangeset = function(changesetData) {
        var model = getTakeRateDataModel();
        $("#" + me.getIdentifierPrefix() + "_Save").prop("disabled", changesetData === null || changesetData.Changes.length === 0 || model.HasValidationErrors());
        $("#" + me.getIdentifierPrefix() + "_Undo").prop("disabled", changesetData === null || changesetData.Changes.length === 0);

        for (var i = 0; i < changesetData.Changes.length; i++) {
            var currentChange = changesetData.Changes[i];
            var displayValue;
            if (me.getResultsMode() === "PercentageTakeRate") {
                displayValue = me.formatPercentageTakeRate(currentChange.PercentageTakeRate);
            } else {
                displayValue = me.formatVolume(currentChange.Volume);
            }
            var selector;
            if (currentChange.IsFeatureSummary) {
                selector = $("tbody span[data-target='FS|" + currentChange.DataTarget + "']");
            } else if (currentChange.IsModelSummary) {
                selector = $("thead th[data-target='MS|" + currentChange.DataTarget + "']").last();
            } else if (currentChange.IsWholeMarketChange) {
                selector = $(".input-filtered-volume");
            } else {
                selector = $("tbody div[data-target='" + currentChange.DataTarget + "']");
            }

            if (currentChange.IsWholeMarketChange) {
                selector.addClass(me.getEditedDataClass(currentChange)).val(displayValue);
            } else {
                selector.addClass(me.getEditedDataClass(currentChange)).html(displayValue);
            }
        }
    };
    me.revertData = function(revertedData) {
        for (var i = 0; i < revertedData.Reverted.length; i++) {
            var revertedChange = revertedData.Reverted[i];
            var displayValue;
            if (me.getResultsMode() === "PercentageTakeRate") {
                displayValue = me.formatFractionalPercentageTakeRate(revertedChange.OriginalPercentageTakeRate);
            } else {
                displayValue = me.formatVolume(revertedChange.OriginalVolume);
            }
            var selector;
            if (revertedChange.IsFeatureSummary) {
                selector = $("tbody span[data-target='FS|" + revertedChange.DataTarget + "']");
            } else if (revertedChange.IsModelSummary) {
                selector = $("thead th[data-target='MS|" + revertedChange.DataTarget + "']").first();
            } else if (revertedChange.IsWholeMarketChange) {
                selector = $(".input-filtered-volume");
            } else {
                selector = $("tbody div[data-target='" + revertedChange.DataTarget + "']");
            }

            if (revertedChange.IsWholeMarketChange) {
                selector.removeClass(me.getEditedDataClass(revertedChange)).val(displayValue);
            } else {
                selector.removeClass("edited").removeClass(me.getEditedDataClass(revertedChange)).html(displayValue);
            }
        }
    };
    me.loadChangesetCallback = function (changesetData) {
        var changeset = getChangeset();
        changeset.clear();

        $("#" + me.getIdentifierPrefix() + "_Save").prop("disabled", true);
        $("#" + me.getIdentifierPrefix() + "_Undo").prop("disabled", true);

        me.loadValidation();

        if (changesetData.Changes.length === 0)
            return;

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
                else {
                    selector = $("tbody td[data-target='" + currentChange.DataTarget + "']");
                }
                selector.removeClass(me.getEditedDataClass(currentChange)).html(displayValue);
            }
        }
    };
    me.getEditedDataClass = function (changesetChange) {
        var className;
        if (changesetChange.IsFeatureSummary) {
            className = me.getEditedDataClassForFeatureSummary(changesetChange);
        }
        else if (changesetChange.IsModelSummary) {
            className = me.getEditedDataClassForModelSummary(changesetChange);
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
        return className;
    };
    me.getEditedDataClassForModelSummary = function (changesetChange) {
        var className = "edited";
        if (changesetChange.ModelIdentifier !== null && changesetChange.ModelIdentifier.charAt(0) === "F") {
            className = "edited";
        }
        return className;
    };
    me.getEditedDataClassForDataItem = function (changesetChange) {
        var className = "edited";
        if (changesetChange.FeatureIdentifier !== null && changesetChange.FeatureIdentifier.charAt(0) === "F") {
            className = "edited-fdp-data";
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
    me.onHistoryEventHandler = function () {
        me.showHistory();
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
        $(".comment-item").popover({ html: true, title: "Comments", container: "body", trigger: "hover" });

        $(".comment-item").on("click", function () {
            $(".comment-item").not(this).popover("hide");
        });

        $(".rule-item").popover({ html: true, title: "Rules", container: "body", trigger: "hover" });

        $(".rule-item").on("click", function () {
            $(".rule-item").not(this).popover("hide");
        });

        $(".efg-item").popover({ html: true, title: "Exclusive Feature Group", container: "body", trigger: "hover" });

        $(".efg-item").on("click", function () {
            $(".efg-item").not(this).popover("hide");
        });

        $(".pack-item").popover({ html: true, title: "Feature Pack", container: "body", trigger: "hover" });

        $(".pack-item").on("click", function () {
            $(".pack-item").not(this).popover("hide");
        });

        $(".feature-validation-error").popover({ html: true, title: "Validation Error", container: "body", trigger: "hover" });
        $(".feature-validation-error").on("click", function () {
            $(".feature-validation-error").not(this).popover("hide");
        });
        $(".model-validation-error").popover({ html: true, title: "Validation Error", container: "body", trigger: "hover" });
        $(".model-validation-error").on("click", function () {
            $(".model-validation-error").not(this).popover("hide");
        });
        $(".primary-validation-error")
            //.attr("data-content", "One or more validation errors exist for the dataset. Examine each indicated market in turn to rectify any errors.")
            .popover({ html: true, title: "Validation Error", container: "body", trigger: "hover" });
        $(".primary-validation-error").on("click", function () {
            $(".primary-validation-error").not(this).popover("hide");
        });
    };
    me.configureDataTables = function () {

        var prefix = me.getIdentifierPrefix();
        //$("#" + prefix + "_TakeRateDataPanel").hide();
        var table = $("#" + prefix + "_TakeRateData").DataTable({
            serverSide: false,
            paging: false,
            ordering: false,
            processing: true,
            dom: "t",
            scrollX: true,
            scrollY: me.calcDataTableHeight(),
            scrollCollapse: true
        });

        new $.fn.dataTable.FixedColumns(table, {
            leftColumns: 4,
            drawCallback: function (left) {
                var settings = table.settings();
                if (settings.data().length === 0) {
                    return;
                }

                var nGroup, nSubGroup, nCell, index, groupName, subGroupName;
                var lastGroupName = "", lastSubGroupName = "", corrector = 0;
                var nTrs = $("#" + me.getIdentifierPrefix() + "_TakeRateData tbody tr");
                var rightColumns = nTrs.first().children().length;

                for (var i = 0 ; i < nTrs.length ; i++) {
                    index = settings.page.info().start + i;
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
                            $(nGroup).on("click", function () {
                                var clickedGroup = $(this).attr("data-toggle");
                                var rows = $("tbody tr[data-group='" + clickedGroup + "']").toggle();
                                if ($(rows[0]).is(":visible")) {
                                    $(this).find("span").removeClass("glyphicon-plus").addClass("glyphicon-minus");
                                }
                                else {
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
                            $(nSubGroup).on("click", function (sender, eventArgs) {
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
                            $(nSubGroup).on("click", function () {
                                var clickedGroup = $(this).attr("data-toggle");
                                var rows = $("tbody tr[data-subgroup='" + clickedGroup + "']").toggle();
                                if ($(rows[0]).is(":visible")) {
                                    $(this).find("span").removeClass("glyphicon-plus").addClass("glyphicon-minus");
                                }
                                else {
                                    $(this).find("span").removeClass("glyphicon-minus").addClass("glyphicon-plus");
                                }
                            });

                            corrector++;
                        }
                        lastSubGroupName = subGroupName;
                    }
                }
                me.bindContextMenu();
            }
        });

        me.setDataTable(table);
    };
    me.bindContextMenu = function () {
        var prefix = me.getIdentifierPrefix();
        $("#" + prefix + "_TakeRateData .cross-tab-data-item").contextMenu({
            menuSelector: "#" + prefix + "_ContextMenu",
            dynamicContent: me.getContextMenu,
            contentIdentifier: me.getDataItemId,
            menuSelected: me.actionTriggered
        });
        $("#" + prefix + "_TakeRateDataPanel .model-mix").contextMenu({
            menuSelector: "#" + prefix + "_ContextMenu",
            dynamicContent: me.getContextMenu,
            contentIdentifier: me.getModelMixDataItemId,
            menuSelected: me.actionTriggered
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
        var dataItemString = $(this).attr("data-target")
        var filter = getFilter(dataItemString);
        filter.Action = parseInt($(this).attr("data-role")),

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
        console.log("Validate: " + errorThrown);
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
        var html = "";
        switch (eventArgs.StatusCode) {
            case "Success":
                html = "<div class=\"alert alert-dismissible alert-success\">" + eventArgs.StatusMessage + "</div>";
                break;
            case "Warning":
                html = "<div class=\"alert alert-dismissible alert-warning\">" + eventArgs.StatusMessage + "</div>";
                break;
            case "Failure":
                html = "<div class=\"alert alert-dismissible alert-danger\">" + eventArgs.StatusMessage + "</div>";
                break;
            case "Information":
                html = "<div class=\"alert alert-dismissible alert-info\">" + eventArgs.StatusMessage + "</div>";
                break;
            default:
                break;
        }
        $("notifier").html(html).fadeIn("slow");
    };
    me.onErrorEventHandler = function (sender, eventArgs) {
        var html = "<div class=\"alert alert-dismissible alert-danger\">" + eventArgs.Message + "</div>";
        me.scrollToNotify();
        me.fadeInNotify(html);
    };
    me.onFilterChangedEventHandler = function () {
        var filter = $("#" + me.getIdentifierPrefix() + "_FilterMessage").val();
        me.getDataTable().search(filter).draw();
    };
    me.onUpdatedEventHandler = function (sender, eventArgs) {
        $("#notifier").html("<div class=\"alert alert-dismissible alert-success\">" + eventArgs.StatusMessage + "</div>");
    };
    me.redrawDataTable = function () {
        me.getDataTable().draw();
    };
    me.validate = function () {
        //getTakeRateDataModel().validate(me.validateCallback);
    };
    me.validateCallback = function(validationResults) {
        $(".feature-validation-error").attr("data-content", "test").show();
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