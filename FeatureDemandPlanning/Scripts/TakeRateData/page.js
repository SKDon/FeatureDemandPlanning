"use strict";

var model = namespace("FeatureDemandPlanning.Volume");

model.Page = function (models) {
    var uid = 0, privateStore = {}, me = this;

    privateStore[me.id = uid++] = {};
    privateStore[me.id].Models = models;
    privateStore[me.id].DataTable = null;
    privateStore[me.id].ResultsMode = "PercentageTakeRate";
    privateStore[me.id].Changeset = null;
    
    me.initialise = function () {
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
        return (panelHeight - 220) + "px";
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
        //me.configureRules();
    };
    me.saveData = function () {
        getVolumeModel().saveVolume(getChangeset().getDataChanges());
    };
    me.initialiseControls = function () {
        var prefix = me.getIdentifierPrefix();
        $("#" + prefix + "_TakeRateDataPanel").height(me.calcPanelHeight());
    };
    me.getIdentifierPrefix = function () {
        return $("#Page_IdentifierPrefix").val();
    };
    me.clearVehicle = function () {
        me.setVehicle(getVehicleModel().getEmptyVehicle());
    };
    me.resetVehicle = function (startEventChain) {
        me.clearVehicle();
        me.resetEvent();
        if (startEventChain)
            me.toggleEvent();
    };
    me.parseError = function (error) {
        var retVal = "";
        $(error.errors).each(function () {
            retVal += ("<li>" + this.ErrorMessage + "</li>");
        });
        return retVal;
    };
    me.getVolume = function () {
        return getVolumeModel().getVolume();
    }
    me.getOxoDocId = function () {
        var document = getVolumeModel().getDocument();
        if (document != null) {
            return document.Id;
        }
        return null;
    };
    me.getVehicle = function () {
        return getVolumeModel().getVehicle();
    };
    me.setVehicle = function (vehicle) {
        getVolumeModel().setVehicle(vehicle);
    };
    me.registerEvents = function () {
        var prefix = me.getIdentifierPrefix();
        $(document)
            .unbind("Success").on("Success", function (sender, eventArgs) { $(".subscribers-notifySuccess").trigger("OnSuccessDelegate", [eventArgs]); })
            .unbind("Error").on("Error", function (sender, eventArgs) { $(".subscribers-notifyError").trigger("OnErrorDelegate", [eventArgs]); })
            .unbind("FilterComplete").on("FilterComplete", function (sender, eventArgs) { $(".subscribers-notifyFilterComplete").trigger("OnFilterCompleteDelegate", [eventArgs]); })
            .unbind("Results").on("Results", function (sender, eventArgs) { $(".subscribers-notifyResults").trigger("OnResultsDelegate", [eventArgs]); })
            .unbind("Updated").on("Updated", function (sender, eventArgs) { $(".subscribers-notifyUpdated").trigger("OnUpdatedDelegate", [eventArgs]); })
            .unbind("Validation").on("Validation", function (sender, eventArgs) { $(".subscribers-notifyValidation").trigger("OnValidationDelegate", [eventArgs]); })
            .unbind("EditCell").on("EditCell", function (sender, eventArgs) { $(".subscribers-notifyEditCell").trigger("OnEditCellDelegate", [eventArgs]); });

        $("#" + prefix + "_Save").unbind("click").on("click", function (sender, eventArgs) { $(".subscribers-notifySave").trigger("OnSaveDelegate", [eventArgs]); });
    };
    me.registerSubscribers = function () {
        var prefix = me.getIdentifierPrefix();
        // The #notifier displays status changed message, therefore it makes sense for it to listen to status
        // events and dispatch accordingly

        $("#notifier")
            .unbind("OnSuccessDelegate").on("OnSuccessDelegate", me.onSuccessEventHandler)
            .unbind("OnErrorDelegate").on("OnErrorDelegate", me.onErrorEventHandler)
            .unbind("OnUpdatedDelegate").on("OnUpdatedDelegate", me.onUpdatedEventHandler)
            .unbind("OnValidationDelegate").on("OnValidationDelegate", me.onValidationEventHandler);

        $("#" + me.getIdentifierPrefix() + "_TakeRateDataPanel")
            .on("OnEditCellDelegate", me.onEditCellEventHandler)
            .on("OnSaveDelegate", me.onSaveEventHandler);

        // Iterate through each of the forecast / comparison controls and register onclick / change handlers
        $(".fdp-volume-header-toggle").unbind("click").on("click", me.toggleFdpVolumeHeader);

        $("#" + prefix + "_FilterMessage").on("keyup", function (sender, eventArgs) {
            var length = $("#" + prefix + "_FilterMessage").val().length;
            if (length == 0 || length > 2) {
                me.onFilterChangedEventHandler(sender, eventArgs);
            }
        });

        $(window).resize(function () {
            var panel = $("#" + me.getIdentifierPrefix() + "_TakeRateDataPanel");
            var table = me.getDataTable();
            //var settings = table.settings();
            panel.height(me.calcPanelHeight());
            $('div.dataTables_scrollBody').css('height', me.calcDataTableHeight());
            table.draw();
            me.configureScrollerOffsets();
        });

        //$(document).on({
        //    mouseenter: function () {
        //        var columnIndex = $(this).index().column;
        //        var trIndex = $(this).closest("tr").index() + 5;
        //        $("table.dataTable").each(function (index) {
        //            $(this).find("tr:eq(" + trIndex + ")").children(".cross-tab-data-item").addClass("highlight");
        //            $(this).column(columnIndex).nodes().addClass("highlight");
        //        });
        //    },
        //    mouseleave: function () {
        //        var columnIndex = $(this).index().column;
        //        var trIndex = $(this).closest("tr").index() + 5;
        //        $("table.dataTable").each(function (index) {
        //            $(this).find("tr:eq(" + trIndex + ")").children(".cross-tab-data-item").removeClass("highlight");
        //            $(this).column(columnIndex).nodes().removeClass("highlight");
        //        });
        //    }
        //}, ".dataTables_wrapper tbody tr td");

        
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
    me.cellEditCallback = function (value, settings) {
        
        var identifiers = $(this).attr("data-target").split("|");
        var modelIdentifier = null;
        var featureIdentifier = null;

        if (identifiers.length > 0) {
            modelIdentifier = identifiers[0];
        }
        if (identifiers.length > 1) {
            featureIdentifier = identifiers[1];
        }
        var change = new FeatureDemandPlanning.Volume.Change(modelIdentifier, featureIdentifier);
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
        if (me.getResultsMode() === "PercentageTakeRate") {
            var parsedValue = $.trim(value.replace("%", ""));
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
        var formattedValue = "-"
        if (takeRate !== null)
            formattedValue = takeRate.toFixed(2) + " %";
        
        return formattedValue;
    };
    me.formatVolume = function (volume) {
        var formattedValue = "-"
        if (volume !== null)
            formattedValue = volume;

        return formattedValue;
    };
    me.onEditCellEventHandler = function (sender, eventArgs) {
        var modelIdentifier = eventArgs.getModelIdentifier();
        var featureIdentifier = eventArgs.getFeatureIdentifier();
         
        var editedCell = $("tbody td[data-target='" + modelIdentifier + "|" + featureIdentifier + "']");
        var editedRow = $(".DTFC_Cloned tbody tr[data-target='" + featureIdentifier + "']");
        var changeSet = getChangeset();

        // If any changes have reverted back to the original value, we need to lower any change flags and remove from the changeset
        var firstChange = changeSet.getChange(modelIdentifier, featureIdentifier);
        if (firstChange != null && (
                (eventArgs.Mode == "PercentageTakeRate" && eventArgs.getChangedTakeRate() === firstChange.getOriginalTakeRate()) ||
                (eventArgs.Mode == "Raw" && eventArgs.getChangedVolume() === firstChange.getOriginalVolume())))
        {
            changeSet.removeChanges(modelIdentifier, featureIdentifier);
            editedCell.removeClass("edited");

            // If there are no other changes to the feature, lower the feature changed indicator
            var otherFeatureChanges = changeSet.getChangesForFeature(featureIdentifier);
            if (otherFeatureChanges == null || otherFeatureChanges.length == 0) {
                editedRow.find(".changed-indicator").hide();
            }
        }
        else if (eventArgs.isChanged())
        {
            changeSet.addChange(eventArgs);
            editedCell.addClass("edited");
            editedRow.find(".changed-indicator").show();
        }
    };
    me.onSaveEventHandler = function (sender, eventArgs) {
        me.saveData();
    };
    me.configureComments = function () {
        $(".comment-item").popover({ html: true, title: "Comments" });

        $('.comment-item').on("click", function (e) {
            $('.comment-item').not(this).popover("hide");
        });
    };
    me.configureScrollerOffsets = function () {
        var leftFixed = $(".DTFC_LeftBodyLiner");
        var leftWrapper = $(".DTFC_LeftBodyWrapper");
        leftFixed.height((leftFixed.height() + 38) + "px");
        leftWrapper.height((leftWrapper.height() + 7) + "px");
    }
    me.configureDataTables = function () {

        var table = $("#" + me.getIdentifierPrefix() + "_TakeRateData").DataTable({
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
            leftColumns: 3,
            drawCallback: function (left, right) {
                var settings = table.settings();
                if (settings.data().length == 0) {
                    return;
                }

                var nGroup, nSubGroup, nCell, index, groupName, subGroupName;
                var lastGroupName = "", lastSubGroupName = "", corrector = 0;
                var nTrs = $("#" + me.getIdentifierPrefix() + "_TakeRateData tbody tr");
                var iColspan = 0;

                for (var i = 0 ; i < nTrs.length ; i++) {
                    index = settings.page.info().start + i;
                    groupName = $(nTrs[i]).attr("data-group"); //settings.data()[index][0];
                    subGroupName = $(nTrs[i]).attr("data-subgroup");

                    if (groupName != lastGroupName) {
                        /* Cell to insert into main table */
                        nGroup = document.createElement('tr');
                        nCell = document.createElement('td');
                        nCell.colSpan = iColspan;
                        nCell.className = "group";
                        nCell.innerHTML = "&nbsp;";
                        nGroup.appendChild(nCell);
                        $(nGroup).attr("data-toggle", groupName);
                        nTrs[i].parentNode.insertBefore(nGroup, nTrs[i]);
                        $(nGroup).on("click", function (sender, eventArgs) {
                            var clickedGroup = $(this).attr("data-toggle");
                            $("tbody tr[data-group='" + clickedGroup + "']").toggle();
                        });

                        /* Cell to insert into the frozen columns */
                        nGroup = document.createElement('tr');
                        nCell = document.createElement('td');
                        nCell.className = "group";
                        nCell.innerHTML = "<span class=\"glyphicon glyphicon-minus\"></span> " + groupName;
                        nCell.colSpan = 3;
                        $(nGroup).attr("data-toggle", groupName);
                        nGroup.appendChild(nCell);
                        $(nGroup).insertBefore($('tbody tr:eq(' + (i + corrector) + ')', left.body)[0]);
                        $(nGroup).on("click", function (sender, eventArgs) {
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

                    if (subGroupName != lastSubGroupName) {
                        if (subGroupName != "") {
                            /* Cell to insert into main table */
                            nSubGroup = document.createElement('tr');
                            nCell = document.createElement('td');
                            nCell.colSpan = iColspan;
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
                            nSubGroup = document.createElement('tr');
                            nCell = document.createElement('td');
                            nCell.className = "sub-group";
                            nCell.innerHTML = "<span class=\"glyphicon glyphicon-minus\"></span> " + subGroupName;
                            nCell.colSpan = 3;
                            $(nSubGroup).attr("data-group", groupName);
                            $(nSubGroup).attr("data-toggle", subGroupName);
                            nSubGroup.appendChild(nCell);
                            $(nSubGroup).insertBefore($('tbody tr:eq(' + (i + corrector) + ')', left.body)[0]);
                            $(nSubGroup).on("click", function (sender, eventArgs) {
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
            }
        });

        me.setDataTable(table);
        me.configureScrollerOffsets();
    };
    me.parseInputData = function (value, settings) {
        var parsedValue = value.replace("%", "");
        parsedValue = parsedValue.replace("-", "");
        var trimmedValue = $.trim(parsedValue);
        return trimmedValue;
    },
    me.onValidationEventHandler = function (sender, eventArgs) {
        me.getValidationMessage(eventArgs);
    };
    me.getValidationMessage = function (validationResults) {
        $.ajax({
            method: "POST",
            url: getVolumeModel().getValidationMessageUri(),
            data: JSON.stringify(validationResults),
            context: this,
            contentType: "application/json",
            success: me.getValidationMessageCallback,
            error: me.getValidationMessageError,
            async: true
        });
    };
    me.getValidationMessageCallback = function (response, textStatus, jqXHR) {
        var html = "";
        if (response != "") {
            html = response;
        }
        me.fadeInNotify(html);
    };
    me.fadeInNotify = function (displayHtml) {
        var control = $("#notifier");
        if (control.is(":visible")) {
            control.fadeOut("slow", function () {
                control.html(displayHtml);
                if (displayHtml != "") control.fadeIn("slow");
            });
        } else {
            if (displayHtml != "") control.fadeIn("slow");
        }
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
        $("#notifier").html("<div class=\"alert alert-dismissible alert-danger\">" + eventArgs.statusText + "</div>");
    };
    me.onFilterChangedEventHandler = function (sender, eventArgs) {
        var filter = $("#" + me.getIdentifierPrefix() + "_FilterMessage").val();
        me.getDataTable().search(filter).draw();
        me.configureScrollerOffsets();
    };
    me.onUpdatedEventHandler = function (sender, eventArgs) {
        $("#notifier").html("<div class=\"alert alert-dismissible alert-success\">" + eventArgs.StatusMessage + "</div>");
    };
    me.redrawDataTable = function () {
        me.getDataTable().draw();
    };
    me.validate = function (pageIndex, async) {
        getVolumeModel().validate(pageIndex, async);
    };
    me.toggleFdpVolumeHeader = function (data) {
        var fdpVolumeHeaderId = parseInt($(this).attr("data-target"));
        var model = getVolumeModel();
 
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
    function getVolumeModel() {
        return getModel("OxoVolume");
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
    function getCookies() {
        return getModel("Cookies");
    };
    function getModal() {
        return getModel("Modal");
    };
    function getFilter() {
        var model = getTakeRatesModel();
        var pageSize = model.getPageSize();
        var pageIndex = model.getPageIndex();
        var filter = new FeatureDemandPlanning.TakeRate.TakeRateFilter();

        filter.PageIndex = pageIndex;
        filter.PageSize = pageSize;

        return filter;
    };
};