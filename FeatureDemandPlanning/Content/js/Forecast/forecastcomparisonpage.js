"use strict";

var model = namespace("FeatureDemandPlanning.Forecast");

model.Page = function (models) {
    var uid = 0, privateStore = {}, me = this;

    privateStore[me.id = uid++] = {};
    privateStore[me.id].Models = models;
    privateStore[me.id].EventComplete = true;

    me.initialise = function () {
        me.registerEvents();
        me.registerSubscribers();
        me.configureScroller(2); // Fix first two columns
        $(privateStore[me.id].Models).each(function () {
            this.initialise();
        });
    };
    me.clearVehicle = function (vehicleIndex) {
        me.setVehicle(vehicleIndex, getVehicleModel().getEmptyVehicle());
    };
    me.resetVehicle = function (vehicleIndex, startEventChain) {
        me.clearVehicle(vehicleIndex);
        me.resetEvent();
        if (startEventChain)
            me.toggleEvent();
    };
    me.getVehicle = function (vehicleIndex) {
        if (vehicleIndex == 0) {
            return me.getForecastVehicle();
        } else {
            return me.getComparisonVehicle(vehicleIndex);
        }
    };
    me.setVehicle = function (vehicleIndex, vehicle) {
        if (vehicleIndex == 0) {
            me.setForecastVehicle(vehicle);
        } else {
            me.setComparisonVehicle(vehicleIndex - 1, vehicle);
        }
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
    me.isEventForControl = function (control, vehicleIndex) {
        return vehicleIndex != null && vehicleIndex == parseInt(control.attr("data-index"));
    };
    me.getForecast = function () {
        return getForecastModel().getForecast();
    }
    me.getForecastId = function () {
        return getForecastModel().getForecastId();
    };
    me.getForecastVehicle = function () {
        return getForecastModel().getForecastVehicle();
    };
    me.setForecastVehicle = function (forecastVehicle) {
        getForecastModel().setForecastVehicle(forecastVehicle);
    };
    me.getComparisonVehicles = function () {
        return getForecastModel().getComparisonVehicles();
    };
    me.getComparisonVehicle = function (vehicleIndex) {
        return getForecastModel().getComparisonVehicle(vehicleIndex);
    };
    me.setComparisonVehicle = function (vehicleIndex, comparisonVehicle) {
        getForecastModel().setComparisonVehicle(vehicleIndex, comparisonVehicle);
    };
    me.setComparisonVehicleTrim = function (vehicleIndex, forecastVehicleTrimId, comparisonVehicleTrimId) {
        getForecastModel().setComparisonVehicleTrim(vehicleIndex, comparison);
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
            //.unbind("hide.bs.modal").on("hide.bs.modal", function (sender, eventArgs) { $(".subscribers-notifyModal").trigger("OnHideModal", [eventArgs]); })
            .unbind("TrimMappingUpdated").on("TrimMappingUpdated", function (sender, eventArgs) { $(".subscribers-notifyTrimMappingChanged").trigger("OnTrimMappingChangedDelegate", [eventArgs]); });
            
        // Don't keep firing the resize event. Wait until it has completed
        $(window).unbind("resize").on("resize", function (sender, eventArgs) {
            if (this.resizeTO) clearTimeout(this.resizeTO);
            this.resizeTO = setTimeout(function () {
                $(".subscribers-notifyResize").trigger("OnResizeDelegate")
            }, 500);
        });
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
            $(this).unbind("changed").on("change", me.modelYearChanged);
        });
        $(".vehicle-filter-gateway").each(function () {
            $(this).unbind("change").on("change", me.gatewayChanged);
        });

        $("#btnNext").unbind("click").on("click", me.nextPage);
        $("#btnPrevious").unbind("click").on("click", me.previousPage);

        $(".forecast-trim-link").unbind("click").on("click", me.onForecastTrimClickedEventHandler);
        $(".subscribers-notifyTrimMappingChanged").unbind("OnTrimMappingChangedDelegate").on("OnTrimMappingChangedDelegate", me.onTrimMappingChangedEventHandler);
        $(".subscribers-notifyResize").unbind("OnResizeDelegate").on("OnResizeDelegate", me.onResizeEventHandler);
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
        me.validateForecast(eventArgs.PageIndex);
        eventArgs.Cancel = !getForecastModel().isValid();
    };
    me.onForecastTrimClickedEventHandler = function (sender, eventArgs) {
        getModal().showModal({
            title: "Trim Mapping",
            uri: getForecastModel().getTrimSelectUri(),
            data: JSON.stringify({
                Forecast: me.getForecast(),
                VehicleIndex: $(sender.target).attr("data-index"),
                ForecastTrimId: $(sender.target).attr("data-forecast-trim-id")
            }),
            model: getTrimMapping()
        });
    };
    me.onResizeEventHandler = function (sender, eventArgs) {
        me.configureScroller(2);
    };
    me.onValidationEventHandler = function (sender, eventArgs) {
        me.getValidationMessage(eventArgs);
    };
    me.getValidationMessage = function (validationResults) {
        $.ajax({
            method: "POST",
            url: getForecastModel().getValidationMessageUri(),
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
            me.notifyAdditionalValidationFilters(this.errors);
        });
    };
    me.notifyAdditionalValidationFilters = function (additionalItems) {
        if (this.errors == undefined || !this.errors) 
            return;
        $(additionalItems).each(function () {
            $(this).each(function () {
                me.notifyAdditionValidationFiltersForVehicle(this.CustomState);
            });
        });
    };
    me.notifyAdditionValidationFiltersForVehicle = function (customState) {
        if (customState == null)
            return;
        $(customState).each(function () {
            $("[data-val='ComparisonVehiclesToValidate[" + (this.VehicleIndex - 1) + "].ComparisonVehicle']").addClass("has-error");
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
        me.setVehicle(eventArgs.VehicleIndex, eventArgs.Vehicle)
        me.toggleEvent();
        me.validateForecast(getPager().getPageIndex() + 1, true);
    };
    me.onVehicleDescriptionEventHandler = function (sender, eventArgs) {
        if (eventArgs.VehicleIndex != 0) {
            return;
        }
        if (eventArgs.Vehicle == null || eventArgs.Vehicle.ProgrammeId == null || eventArgs.MultipleResults == true) {
            $(sender.target).html("");
        } else {
            $(sender.target).html(eventArgs.Vehicle.FullDescription);
        }
    };
    me.onErrorEventHandler = function (sender, eventArgs) {
        $("#notifier").html("<div class=\"alert alert-dismissible alert-danger\">" + eventArgs.statusText + "</div>");
    };
    me.onUpdatedEventHandler = function (sender, eventArgs) {
        $("#notifier").html("<div class=\"alert alert-dismissible alert-success\">" + eventArgs.StatusMessage + "</div>");
    };
    me.onMakesChangedEventHandler = function (sender, eventArgs) {
        var control = $(this), vehicleIndex = parseInt(control.attr("data-index"));

        if (!me.isEventForControl(control, eventArgs.VehicleIndex))
            return;

        control.empty();

        $(".vehicle-filter-programme,.vehicle-filter-modelYear,.vehicle-filter-gateway")
            .filter(function () { return control.attr("data-index") == vehicleIndex; }).empty().attr("disabled", "disabled");

        $(eventArgs.Makes).each(function () {
            $("<option />", { val: this, text: this }).appendTo(control);
        });
        control.prepend("<option value='' selected='selected'>-- SELECT --</option>");

        // As the make dropdown is actually hidden, populate the programmes on load

        me.populateProgrammes(vehicleIndex);

        $(".vehicle-filter-programme").filter(function () { $(this).attr("data-index") == vehicleIndex; }).removeAttr("disabled");
    };
    me.onProgrammesChangedEventHandler = function (sender, eventArgs) {
        var control = $(this), vehicleIndex = parseInt($(this).attr("data-index"));

        if (!me.isEventForControl(control, eventArgs.VehicleIndex))
            return;

        control.empty().attr("disabled", "disabled");

        $(".vehicle-filter-modelYear,.vehicle-filter-gateway")
            .filter(function () { return $(this).attr("data-index") == vehicleIndex; }).empty().attr("disabled", "disabled");

        $(eventArgs.Programmes).each(function () {
            $("<option />", { val: this.VehicleName, text: this.Description }).appendTo(control);
        });
        if (eventArgs.Programmes.length == 1) {
            control.val(eventArgs.Programmes[0].VehicleName).removeAttr("disabled");
            me.populateModelYears(vehicleIndex);
        } else {
            me.toggleEvent();
            control.prepend("<option value='' selected='selected'>-- SELECT --</option>").removeAttr("disabled");
        }
        me.populateVehicle(vehicleIndex);
    };
    me.onModelYearsChangedEventHandler = function (sender, eventArgs) {
        var control = $(this), vehicleIndex = parseInt(control.attr("data-index"));

        if (!me.isEventForControl(control, eventArgs.VehicleIndex))
            return;

        control.empty().attr("disabled", "disabled");

        $(".vehicle-filter-gateway").filter(function () { return $(this).attr("data-index") == vehicleIndex; }).empty().attr("disabled", "disabled");

        $(eventArgs.ModelYears).each(function () {
            $("<option />", { val: this, text: this }).appendTo(control);
        });
        if (eventArgs.ModelYears.length == 1) {
            control.val(eventArgs.ModelYears[0]);
            me.populateGateways(vehicleIndex);
        } else {
            me.toggleEvent();
            control.prepend("<option value='' selected='selected'>-- SELECT --</option>");
        }
        control.removeAttr("disabled");
        me.populateVehicle(vehicleIndex);
    };
    me.onGatewaysChangedEventHandler = function (sender, eventArgs) {
        var control = $(this), vehicleIndex = parseInt(control.attr("data-index"));

        if (!me.isEventForControl(control, eventArgs.VehicleIndex))
            return;

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
        me.toggleEvent()
        me.populateVehicle(vehicleIndex);
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
        getPager().getPageContent(JSON.stringify({ forecast: me.getForecast(), pageIndex: eventArgs.PageIndex }), me.notifyPageContentChangedCallback, me)
    };
    me.onTrimMappingChangedEventHandler = function (sender, eventArgs) {
        var target = $(sender.target);
        var forecastTrimId = parseInt(target.attr("data-forecast-trim-id"));
        var vehicleIndex = parseInt(target.attr("data-index"));

        if (eventArgs.VehicleIndex != vehicleIndex || eventArgs.ForecastTrimId != forecastTrimId) {
            return;
        }

        var trimMappings = eventArgs.Forecast.ComparisonVehicles[vehicleIndex - 1].TrimMappings;
        var mappingsForCell = null;
        $(trimMappings).each(function () {
            if (this.ForecastVehicleTrim.Id == forecastTrimId) {
                mappingsForCell = this;
                return false;
            }
        });
        me.getComparisonVehicle(vehicleIndex).TrimMappings = trimMappings;
        target.text(getTrimMapping().getDisplayText(mappingsForCell));
        me.configureScroller(2); // Refresh the fixed columns as the cells widths of the underlying table will have changed
    };
    me.notifyPageContentChangedCallback = function (content) {
        $("#frmContent").html(content);
        me.initialise();
    };
    me.makeChanged = function (data) {
        var vehicleIndex = parseInt($(this).attr("data-index"));
        me.resetVehicle(vehicleIndex, true);
        me.populateProgrammes(vehicleIndex);
    };
    me.programmeChanged = function (data) {
        var vehicleIndex = parseInt($(this).attr("data-index"));
        me.resetVehicle(vehicleIndex, true);
        me.populateModelYears(vehicleIndex);
    };
    me.modelYearChanged = function (data) {
        var vehicleIndex = parseInt($(this).attr("data-index"));
        me.resetVehicle(vehicleIndex, true);
        me.populateGateways(vehicleIndex);
    };
    me.gatewayChanged = function (data) {
        var vehicleIndex = parseInt($(this).attr("data-index"));
        me.resetVehicle(vehicleIndex, false); // No event chain will be started by changing the gateway, we simply populate the chosen vehicle
        me.populateVehicle(vehicleIndex);
    };
    me.populateProgrammes = function (vehicleIndex) {
        getVehicleModel().getProgrammes(getVehicleFilter(vehicleIndex));
    };
    me.populateModelYears = function (vehicleIndex) {
        getVehicleModel().getModelYears(getVehicleFilter(vehicleIndex));
    };
    me.populateGateways = function (vehicleIndex) {
        if (vehicleIndex == 0) {
            getVehicleModel().getGateways(getVehicleFilter(vehicleIndex));
        } else {
            me.toggleEvent();
            me.populateVehicle(vehicleIndex);
        }
    };
    me.populateVehicle = function (vehicleIndex) {
        if (me.isEventCompleted())
            getVehicleModel().getVehicle(getVehicleFilter(vehicleIndex));
    };
    me.saveForecast = function () {
        getForecastModel().saveForecast();
    };
    me.validateForecast = function (pageIndex, async) {
        var sectionToValidate = 0;
        switch (pageIndex) {
            case 1:
                sectionToValidate = 1;
                break;
            case 2:
                sectionToValidate = 3;
                break;
            case 3:
                sectionToValidate = 4;
                break;
            default:
                break;
        }
        getForecastModel().validateForecast(sectionToValidate, async);
    };
    me.configureScroller = function (columnsToClone) {
        
        // If we are resizing, destroy and scrollbars first, as this affects the positioning of any fixed columns
        $("#scroller").mCustomScrollbar("destroy");

        $("#scroller table").each(function () {
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

            clonedRows = fixedTable.find("tbody tr");
            rowIndex = 0;
            clonedRows.each(function () {
                var clonedCells = $(this).find("td");
                var originalRow = table.find("tbody tr").eq(rowIndex++);

                for (var i = 0; i < clonedCells.length; i++) {
                    var originalCell = originalRow.find("td").eq(i);
                    var width = originalCell.width();
                    var height = originalCell.height();

                    clonedCells.eq(i).css("width", width + "px").css("height", height + "px");
                }
            });

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
    function getForecastModel() {
        return getModel("Forecast");
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
    function getModal() {
        return getModel("Modal");
    };
    function getPager() {
        return getModel("Pager");
    };
    function getTrimMapping() {
        return getModel("TrimMapping");
    };
    function getVehicleFilter(vehicleIndex) {
        var model = getVehicleModel(), filter = new FeatureDemandPlanning.Vehicle.VehicleFilter(),
            classPrefix = ".vehicle-filter", attrFilter = "[data-index='" + vehicleIndex + "']";

        filter.Make = "";
        filter.Code = $(classPrefix + "-programme" + attrFilter).val();
        filter.ModelYear = $(classPrefix + "-modelYear" + attrFilter).val();
        filter.Gateway = $(classPrefix + "-gateway" + attrFilter).val();
        filter.DerivativeCode = $(classPrefix + "-derivativeCode" + attrFilter).val();
        filter.PageIndex = model.getPageIndex();
        filter.PageSize = model.getPageSize();
        filter.VehicleIndex = vehicleIndex;

        return filter;
    };
};