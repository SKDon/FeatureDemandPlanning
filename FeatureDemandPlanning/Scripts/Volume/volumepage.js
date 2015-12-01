"use strict";

var model = namespace("FeatureDemandPlanning.Volume");

model.Page = function (models) {
    var uid = 0, privateStore = {}, me = this;

    privateStore[me.id = uid++] = {};
    privateStore[me.id].Models = models;
    privateStore[me.id].EventComplete = true;

    me.initialise = function () {
        me.registerEvents();
        me.registerSubscribers();

        $(privateStore[me.id].Models).each(function () {
            this.initialise();
        });
        me.loadData();
    };
    me.loadData = function () {
        me.configureDataTables();
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
    me.resetEvent = function () {
        privateStore[me.id].EventComplete = true;
    };
    me.toggleEvent = function () {
        privateStore[me.id].EventComplete = !privateStore[me.id].EventComplete;
    };
    me.isEventCompleted = function () {
        return privateStore[me.id].EventComplete == true;
    };
    me.isEventForControl = function (control) {
        return true;
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
        $(document)
            .unbind("Success").on("Success", function (sender, eventArgs) { $(".subscribers-notifySuccess").trigger("OnSuccessDelegate", [eventArgs]); })
            .unbind("Error").on("Error", function (sender, eventArgs) { $(".subscribers-notifyError").trigger("OnErrorDelegate", [eventArgs]); })
            .unbind("MakesChanged").on("MakesChanged", function (sender, eventArgs) { $(".subscribers-notifyMakes").trigger("OnMakesChangedDelegate", [eventArgs]); })
            .unbind("ProgrammesChanged").on("ProgrammesChanged", function (sender, eventArgs) { $(".subscribers-notifyProgrammes").trigger("OnProgrammesChangedDelegate", [eventArgs]); })
            .unbind("ModelYearsChanged").on("ModelYearsChanged", function (sender, eventArgs) { $(".subscribers-notifyModelYears").trigger("OnModelYearsChangedDelegate", [eventArgs]); })
            .unbind("GatewaysChanged").on("GatewaysChanged", function (sender, eventArgs) { $(".subscribers-notifyGateways").trigger("OnGatewaysChangedDelegate", [eventArgs]); })
            .unbind("FilterComplete").on("FilterComplete", function (sender, eventArgs) { $(".subscribers-notifyFilterComplete").trigger("OnFilterCompleteDelegate", [eventArgs]); })
            .unbind("VehicleChanged").on("VehicleChanged", function (sender, eventArgs) { $(".subscribers-notifyVehicle").trigger("OnVehicleChangedDelegate", [eventArgs]); })
            .unbind("Results").on("Results", function (sender, eventArgs) { $(".subscribers-notifyResults").trigger("OnResultsDelegate", [eventArgs]); })
            .unbind("Updated").on("Updated", function (sender, eventArgs) { $(".subscribers-notifyUpdated").trigger("OnUpdatedDelegate", [eventArgs]); })
            .unbind("BeforePageChanged").on("BeforePageChanged", function (sender, eventArgs) { $(".subscribers-notifyBeforePageChanged").trigger("OnBeforePageChangedDelegate", [eventArgs]); })
            .unbind("PageChanged").on("PageChanged", function (sender, eventArgs) { $(".subscribers-notifyPageChanged").trigger("OnPageChangedDelegate", [eventArgs]); })
            .unbind("FirstPage").on("FirstPage", function (sender, eventArgs) { $(".subscribers-notifyFirstPage").trigger("OnFirstPageDelegate", [eventArgs]); })
            .unbind("LastPage").on("LastPage", function (sender, eventArgs) { $(".subscribers-notifyLastPage").trigger("OnLastPageDelegate", [eventArgs]); })
            .unbind("Validation").on("Validation", function (sender, eventArgs) { $(".subscribers-notifyValidation").trigger("OnValidationDelegate", [eventArgs]); })
    };
    me.registerSubscribers = function () {
        // The #notifier displays status changed message, therefore it makes sense for it to listen to status
        // events and dispatch accordingly

        $("#notifier")
            .unbind("OnSuccessDelegate").on("OnSuccessDelegate", me.onSuccessEventHandler)
            .unbind("OnVehicleChangedDelegate").on("OnVehicleChangedDelegate", me.onVehicleChangedEventHandler)
            .unbind("OnErrorDelegate").on("OnErrorDelegate", me.onErrorEventHandler)
            .unbind("OnUpdatedDelegate").on("OnUpdatedDelegate", me.onUpdatedEventHandler)
            .unbind("OnBeforePageChangedDelegate").on("OnBeforePageChangedDelegate", me.onBeforePageChangedEventHandler)
            .unbind("OnValidationDelegate").on("OnValidationDelegate", me.onValidationEventHandler);

        // The page and vehicle descriptions need to respond and update if the forecast vehicle is changed
        // or the page is changed

        $("#lblPageDescription").unbind("OnPageChangedDelegate").on("OnPageChangedDelegate", me.onDescriptionPageChangedEventHandler);
        $("#lblVehicleDescription").unbind("OnVehicleChangedDelegate").on("OnVehicleChangedDelegate", me.onVehicleDescriptionEventHandler);
        $("#oxoDocuments").unbind("OnVehicleChangedDelegate").on("OnVehicleChangedDelegate", me.onVehicleDocumentsEventHandler);
        $("#availableImports").unbind("OnVehicleChangedDelegate").on("OnVehicleChangedDelegate", me.onVehicleImportsEventHandler);

        // Notify the pager buttons of any page changes so they can toggle visibility as appropriate

        $("#btnPrevious,#btnNext").unbind("OnPageChangedDelegate").on("OnPageChangedDelegate", me.onPageChangedEventHandler);

        // Notify the parent form of any page changes so we can actually render the appropriate content for the page

        $("#frmContent").unbind("OnPageChangedDelegate").on("OnPageChangedDelegate", me.onPageContentChangedEventHandler);

        // Each of the individual dropdowns and other controls for forecast / comparison will listen for
        // broadcast changes to makes, programmes, etc.
        // They will only respond if the message is intended for them

        $(".vehicle-filter-make").unbind("OnMakesChangedDelegate").on("OnMakesChangedDelegate", me.onMakesChangedEventHandler);
        $(".vehicle-filter-programme").unbind("OnProgrammesChangedDelegate").on("OnProgrammesChangedDelegate", me.onProgrammesChangedEventHandler);
        $(".vehicle-filter-modelYear").unbind("OnModelYearsChangedDelegate").on("OnModelYearsChangedDelegate", me.onModelYearsChangedEventHandler);
        $(".vehicle-filter-gateway").unbind("OnGatewaysChangedDelegate").on("OnGatewaysChangedDelegate", me.onGatewaysChangedEventHandler);

        // Each of the dropdowns will listen for validation messages if the data the hold is somehow in error
        // They will only respond if the validation message is intended for them

        $(".vehicle-filter-make,.vehicle-filter-programme,.vehicle-filter-modelYear,.vehicle-filter-gateway,.vehicle-filter-trim")
            .unbind("OnValidationDelegate").on("OnValidationDelegate", me.onValidationFilterEventHandler);

        // Iterate through each of the forecast / comparison controls and register onclick / change handlers

        $(".vehicle-filter-make").each(function () {
            $(this).unbind("change").on("change", me.makeChanged);
        });
        $(".vehicle-filter-programme").each(function () {
            $(this).unbind("change").on("change", me.programmeChanged);
        });
        $(".vehicle-filter-modelYear").each(function () {
            $(this).unbind("change").on("change", me.modelYearChanged);
        });
        $(".vehicle-filter-gateway").each(function () {
            $(this).unbind("change").on("change", me.gatewayChanged);
        });

        $("#btnNext").unbind("click").on("click", me.nextPage);
        $("#btnPrevious").unbind("click").on("click", me.previousPage);

        $("#oxoDocumentsTable td").contextMenu({
            menuSelector: "#oxoDocumentsContextMenu",
            menuSelected: function (invokedOn, selectedMenu) {
                var msg = "You selected the menu item '" + selectedMenu.text() +
                    "' on the value '" + invokedOn.text() + "'";
                alert(msg);
            }
        });

        $("#availableImportsTable td").contextMenu({
            menuSelector: "#availableImportsContextMenu",
            menuSelected: function (invokedOn, selectedMenu) {
                var msg = "You selected the menu item '" + selectedMenu.text() +
                    "' on the value '" + invokedOn.text() + "'";
                alert(msg);
            }
        });

        $(".oxo-document-toggle").unbind("click").on("click", me.toggleOxoDocument);
        $(".fdp-volume-header-toggle").unbind("click").on("click", me.toggleFdpVolumeHeader)
    };
    me.configureDataTables = function () {

       
        var table = $("#" + me.getIdentifierPrefix() + "_TakeRateData").DataTable({
            serverSide: false,
            paging: false,
            ordering: false,
            processing: true,
            dom: "ltip",
            scrollX: true,
            scrollY: "500px",
            scrollCollapse: true
        });

        new $.fn.dataTable.FixedColumns(table, {
            leftColumns: 5,
            drawCallback: function (left, right) {
                var settings = table.settings();
                if (settings.data().length == 0) {
                    return;
                }

                var nGroup, nCell, index, groupName;
                var lastGroupName = "", corrector = 0;
                var nTrs = $("#" + me.getIdentifierPrefix() + "_TakeRateData tbody tr");
                var iColspan = nTrs[0].getElementsByTagName('td').length;

                for (var i = 0 ; i < nTrs.length ; i++) {
                    index = settings.page.info().start + i;
                    groupName = settings.data()[index][0];

                    if (groupName != lastGroupName) {
                        /* Cell to insert into main table */
                        nGroup = document.createElement('tr');
                        nCell = document.createElement('td');
                        nCell.colSpan = iColspan;
                        nCell.className = "group";
                        nCell.innerHTML = "&nbsp;";
                        nGroup.appendChild(nCell);
                        nTrs[i].parentNode.insertBefore(nGroup, nTrs[i]);

                        /* Cell to insert into the frozen columns */
                        nGroup = document.createElement('tr');
                        nCell = document.createElement('td');
                        nCell.className = "group";
                        nCell.innerHTML = groupName;
                        nCell.colSpan = 5;
                        nGroup.appendChild(nCell);
                        $(nGroup).insertBefore($('tbody tr:eq(' + (i + corrector) + ')', left.body)[0]);

                        corrector++;
                        lastGroupName = groupName;
                    }
                }
            }
        });

        //$("#" + me.getIdentifierPrefix() + "_TakeRateData").rowGrouping();
        //    "aoColumns": [
        //        {
        //            "sName": "TAKE_RATE_ID",
        //            "bVisible": false
        //        },
        //        {
        //            "sName": "CREATED_ON",
        //            "bSearchable": true,
        //            "bSortable": true,
        //            "sClass": "text-center",
        //            "render": function (data, type, full, meta) {
        //                return "<a href='" + takeRateUri + "?oxoDocId=" + full[oxoDocIndex] + "'>" + data + "</a>";
        //            }
        //        }
        //        ,
        //        {
        //            "sName": "CREATED_BY",
        //            "bSearchable": true,
        //            "bSortable": true,
        //            "sClass": "text-center",
        //            "render": function (data, type, full, meta) {
        //                return "<a href='" + takeRateUri + "?oxoDocId=" + full[oxoDocIndex] + "'>" + data + "</a>";
        //            }
        //        },
        //        {
        //            "sName": "OXO_DOCUMENT",
        //            "bSearchable": true,
        //            "bSortable": true,
        //            "render": function (data, type, full, meta) {
        //                return "<a href='" + takeRateUri + "?oxoDocId=" + full[oxoDocIndex] + "'>" + data + "</a>";
        //            }
        //        },
        //        {
        //            "sName": "STATUS",
        //            "bSearchable": true,
        //            "bSortable": true,
        //            "sClass": "text-center",
        //            "render": function (data, type, full, meta) {
        //                return "<a href='" + takeRateUri + "?oxoDocId=" + full[oxoDocIndex] + "'>" + data + "</a>";
        //            }
        //        },
        //        {
        //            "sName": "UPDATED_ON",
        //            "bSearchable": true,
        //            "bSortable": true,
        //            "sClass": "text-center",
        //            "render": function (data, type, full, meta) {
        //                return "<a href='" + takeRateUri + "?oxoDocId=" + full[oxoDocIndex] + "'>" + data + "</a>";
        //            }
        //        },
        //        {
        //            "sName": "UPDATED_BY",
        //            "bSearchable": true,
        //            "bSortable": true,
        //            "sClass": "text-center",
        //            "render": function (data, type, full, meta) {
        //                return "<a href='" + takeRateUri + "?oxoDocId=" + full[oxoDocIndex] + "'>" + data + "</a>";
        //            }
        //        }
        //    ],
        //    "fnCreatedRow": function (row, data, index) {
        //        var takeRateId = data[0];
        //        $(row).attr("data-takeRate-id", takeRateId);
        //    },
        //    "fnDrawCallback": function (oSettings) {
        //        $(document).trigger("Results", me.getSummary());
        //        me.bindContextMenu();
        //        $("#pnlTakeRates").show();
        //    }
        //});
    };
    me.initialiseControls = function () {
        var prefix = me.getIdentifierPrefix();
        //$("#oxoDocumentsTable").dataTable();
        //$("#availableImportsTable").dataTable();
        //$(".editable").editable(function (value, settings) {

        //    // Update the total mix for the field
        //    try 
        //    {
        //        var currentModelId = $(this).attr("modelid");
        //        var featureId = $(this).attr("featureid");
        //        var newValue = parseInt(value.trim());
        //        var oldValue = parseInt(getVolumeModel().getCurrentEditValue());
        //        var rowTotal = 0;

        //        if (!($.isNumeric(newValue)) || newValue == oldValue)
        //            return getVolumeModel().getCurrentEditValue();

        //        $(this).closest("tr").find(".editable").each(function (value) {
        //            var elementValue = parseInt($(this).html().trim());
        //            if ($.isNumeric(elementValue) && currentModelId != $(this).attr("modelid")) {
        //                rowTotal += elementValue;
        //            }
        //        });

        //        rowTotal += newValue;

        //        $(".row-total[featureid='" + featureId + "']").html(rowTotal).addClass("dirty");
        //        getVolumeModel().setCurrentEditValue(null);

        //        // Mark the field as dirty
        //        //$(this).html($(this.html())).addClass("dirty");
                
        //    }
        //    catch (ex) {
        //        console.log(ex);
        //    }

        //    return value;
        //}, {
        //    tooltip: "Click to edit",
        //    cssclass: "editable-cell",
        //    data: function (value, settings)
        //    {
        //        var trimmedValue = $.trim(value);
        //        getVolumeModel().setCurrentEditValue(trimmedValue);
        //        return trimmedValue;
        //    },
        //    select: true,
        //    onblur: "submit"
        //});
        //$(".editable-header").editable(function (value, settings) {
        //    console.log(this);
        //    console.log(value);
        //    console.log(settings);

            
        //    return value;
        //}, {
        //    tooltip: "Click to edit",
        //    cssclass: "editable-header",
        //    data: function (string) { return $.trim(string) },
        //    select: true,
        //    onblur: "submit"
        //});
    };
    me.nextPage = function (sender, eventArgs) {
        getPager().nextPage();
    };
    me.previousPage = function (sender, eventArgs) {
        getPager().previousPage();
    };
    me.onBeforePageChangedEventHandler = function (sender, eventArgs) {
        if (!eventArgs.NextPage) {
            return;
        }
        me.validate(eventArgs.PageIndex);
        eventArgs.Cancel = !getVolumeModel().isValid();
    };
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
    me.onVehicleChangedEventHandler = function (sender, eventArgs) {
        me.setVehicle(eventArgs.Vehicle)
        me.toggleEvent();
        me.validate(getPager().getPageIndex() + 1, true);
    };
    me.onVehicleDescriptionEventHandler = function (sender, eventArgs) {
        if (eventArgs.Vehicle == null || eventArgs.Vehicle.ProgrammeId == null || eventArgs.MultipleResults == true) {
            $(sender.target).html("");
        } else {
            $(sender.target).html(eventArgs.Vehicle.FullDescription);
        }
    };
    me.onVehicleDocumentsEventHandler = function (sender, eventArgs) {
        getVolumeModel().getAvailableDocuments(me.oxoDocumentsContentChangedCallback);
    };
    me.onVehicleImportsEventHandler = function (sender, eventArgs) {
        getVolumeModel().getAvailableImports(me.importsContentChangedCallback);
    };
    me.oxoDocumentsContentChangedCallback = function (content) {
        $("#oxoDocuments").html(content);
        me.initialiseControls();
        me.initialise();
    };
    me.importsContentChangedCallback = function (content) {
        $("#availableImports").html(content);
        me.initialiseControls();
        me.initialise();
    };
    me.onErrorEventHandler = function (sender, eventArgs) {
        $("#notifier").html("<div class=\"alert alert-dismissible alert-danger\">" + eventArgs.statusText + "</div>");
    };
    me.onUpdatedEventHandler = function (sender, eventArgs) {
        $("#notifier").html("<div class=\"alert alert-dismissible alert-success\">" + eventArgs.StatusMessage + "</div>");
    };
    me.onMakesChangedEventHandler = function (sender, eventArgs) {
        var control = $(this);

        control.empty();

        $(".vehicle-filter-programme,.vehicle-filter-modelYear,.vehicle-filter-gateway").empty().attr("disabled", "disabled");

        $(eventArgs.Makes).each(function () {
            $("<option />", { val: this, text: this }).appendTo(control);
        });
        control.prepend("<option value='' selected='selected'>-- SELECT --</option>");

        // As the make dropdown is actually hidden, populate the programmes on load

        me.populateProgrammes();

        $(".vehicle-filter-programme").removeAttr("disabled");
    };
    me.onProgrammesChangedEventHandler = function (sender, eventArgs) {
        var control = $(this);
        control.unbind();
        control.empty().attr("disabled", "disabled");

        $(".vehicle-filter-modelYear,.vehicle-filter-gateway").empty().attr("disabled", "disabled");

        $(eventArgs.Programmes).each(function () {
            $("<option />", { val: this.VehicleName, text: this.Description }).appendTo(control);
        });
        if (eventArgs.Programmes.length == 1) {
            control.val(eventArgs.Programmes[0].VehicleName).removeAttr("disabled");
            me.populateModelYears();
        } else {
            me.toggleEvent();
            control.prepend("<option value='' selected='selected'>-- SELECT --</option>").removeAttr("disabled");
        }
        me.populateVehicle();
    };
    me.onModelYearsChangedEventHandler = function (sender, eventArgs) {
        var control = $(this);
        control.unbind();
        control.empty().attr("disabled", "disabled");

        $(".vehicle-filter-gateway").empty().attr("disabled", "disabled");

        $(eventArgs.ModelYears).each(function () {
            $("<option />", { val: this, text: this }).appendTo(control);
        });
        if (eventArgs.ModelYears.length == 1) {
            control.val(eventArgs.ModelYears[0]);
            me.populateGateways();
        } else {
            me.toggleEvent();
            control.prepend("<option value='' selected='selected'>-- SELECT --</option>");
        }
        control.removeAttr("disabled");
        me.registerEvents();
        me.registerSubscribers();
        me.populateVehicle();
    };
    me.onGatewaysChangedEventHandler = function (sender, eventArgs) {
        var control = $(this);
        control.unbind();
        control.empty().attr("disabled", "disabled");

        if (eventArgs.Filter.ModelYear == null) {
            return;
        }
        $(eventArgs.Gateways).each(function () {
            $("<option />", { val: this, text: this }).appendTo(control);
        });
        if (eventArgs.Gateways.length === 1) {
            control.val(eventArgs.Gateways[0]).removeAttr("disabled");
        } else {
            control.prepend("<option value='' selected='selected'>-- SELECT --</option>").removeAttr("disabled");
        }
        me.toggleEvent();
        me.registerEvents();
        me.registerSubscribers();
        me.populateVehicle();
    };
    me.onDescriptionPageChangedEventHandler = function (sender, eventArgs) {
        var descriptions = $(".page-description").hide().filter(function () {
            return $(this).attr("data-index") == eventArgs.PageIndex;
        }).show();
    };
    me.onPageChangedEventHandler = function (sender, eventArgs) {
        var button = $(sender.target);
        if (eventArgs.IsFirstPage && button.attr("id") == "btnPrevious") {
            button.hide();
        } else if (eventArgs.IsLastPage && button.attr("id") == "btnNext") {
            button.hide();
        } else {
            button.show();
        }
    };
    me.onPageContentChangedEventHandler = function (sender, eventArgs) {
        getPager().getPageContent(JSON.stringify({ volume: me.getVolume(), pageIndex: eventArgs.PageIndex }), me.notifyPageContentChangedCallback, me)
    };
    me.notifyPageContentChangedCallback = function (content) {
        $("#frmContent").html(content);
        me.initialiseControls();
        me.initialise();
    };
    me.makeChanged = function (data) {
        me.resetVehicle(true);
        me.populateProgrammes();
    };
    me.programmeChanged = function (data) {
        me.resetVehicle(true);
        me.populateModelYears();
    };
    me.modelYearChanged = function (data) {
        me.resetVehicle(true);
        me.populateGateways();
    };
    me.gatewayChanged = function (data) {
        me.resetVehicle(false);
        me.populateVehicle();
    };
    me.populateProgrammes = function () {
        getVehicleModel().getProgrammes(getVehicleFilter());
    };
    me.populateModelYears = function () {
        getVehicleModel().getModelYears(getVehicleFilter());
    };
    me.populateGateways = function () {
        getVehicleModel().getGateways(getVehicleFilter());
    };
    me.populateVehicle = function () {
        if (me.isEventCompleted())
            getVehicleModel().getVehicle(getVehicleFilter());
    };
    me.saveForecast = function () {
        getVolumeModel().saveVolume();
    };
    me.validate = function (pageIndex, async) {
        getVolumeModel().validate(pageIndex, async);
    };
    me.toggleOxoDocument = function (data) {
        var oxoDocId = parseInt($(this).attr("data-target"));
        var model = getVolumeModel();

        $(".oxo-document-toggle").removeClass("btn-danger").addClass("btn-primary");

        if ($(this).text() == "Unselect") {
            model.setDocument({});
            $(this).text("Select");
        } else {
            model.setDocument({ Id: oxoDocId, ProgrammeId: model.getVehicle().ProgrammeId });
            $(this).text("Select").removeClass("btn-primary").addClass("btn-danger");
        }
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
    me.configureScroller = function (columnsToClone) {

        // If we are resizing, destroy and scrollbars first, as this affects the positioning of any fixed columns
        $("#scroller").mCustomScrollbar("destroy");

        $("#scroller table").each(function () {

            // Create a fixed table element at this location
            $(this).parent().append("<div id='scrollerFixed'></div>");

            var table = $(this),
                fixedTable = table.clone(true),
                fixedWidth = table.find("th").eq(0).width(),
                fixedHeight = table.find("th").eq(0).height(),
                tablePos = table.position(),
                removeIndex = columnsToClone - 1;

            // Remove all but the number of specified columns from the clones table
            fixedTable.find("thead tr").each(function () {
                $(this).find("th:gt(" + removeIndex + ")").remove();
            });
            fixedTable.find("tbody tr").each(function () {
                $(this).find("td:gt(" + removeIndex + ")").remove();
            });

            // Set positioning so that cloned table overlays
            // first column of original table
            fixedTable.addClass("fixedTable");
            fixedTable.css({
                left: tablePos.left,
                top: tablePos.top
            });

            // Do the same with the table cells, we will need to iterate each row
            var clonedRows = fixedTable.find("thead tr");
            var rowIndex = 0;
            clonedRows.each(function () {
                var clonedCells = $(this).find("th");
                var originalRow = table.find("thead tr").eq(rowIndex++);

                for (var i = 0; i < clonedCells.length; i++) {
                    var originalCell = originalRow.find("th").eq(i);
                    var width = originalCell.width();
                    var height = originalCell.height();

                    clonedCells.eq(i).css("width", width + "px").css("height", height + "px");
                }
            });

            //clonedRows = fixedTable.find("tbody tr");
            //rowIndex = 0;
            //clonedRows.each(function () {
            //    var clonedCells = $(this).find("td");
            //    var originalRow = table.find("tbody tr").eq(rowIndex++);

            //    for (var i = 0; i < clonedCells.length; i++) {
            //        var originalCell = originalRow.find("td").eq(i);
            //        var width = originalCell.width();
            //        var height = originalCell.height();

            //        clonedCells.eq(i).css("width", width + "px").css("height", height + "px");
            //    }
            //});

            $("#scrollerFixed").html(fixedTable);

            $("#scroller").mCustomScrollbar({
                axis: "x",
                theme: "inset-3"
            });
        });
    };
    function getVehicleModel() {
        return getModel("Vehicle");
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
    function getPager() {
        return getModel("Pager");
    };
    function getTrimMapping() {
        return getModel("TrimMapping");
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