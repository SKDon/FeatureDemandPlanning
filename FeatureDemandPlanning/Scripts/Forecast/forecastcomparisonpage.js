"use strict";

var model = namespace("FeatureDemandPlanning.Forecast");

model.Page = function (models) {
    var uid = 0;
    var privateStore = {};
    var me = this;

    privateStore[me.id = uid++] = {};
    privateStore[me.id].Models = models;
    privateStore[me.id].PageIndex = 0;
    privateStore[me.id].ForecastVehicle = null;
    privateStore[me.id].InitCount = 0;
    privateStore[me.id].IsValid = false;

    me.initialise = function () {
        me.registerEvents();
        me.registerSubscribers();
        $(privateStore[me.id].Models).each(function () {
            this.initialise(me.initialiseCallback);
        });
    };
    me.initialiseCallback = function () {
        me.incrementNumberOfInitialisedModels();
        if (!me.isInitComplete()) {
            return;
        }
        me.initialiseForecastVehicle();
        me.initialiseComparisonVehicles();
    };
    me.getNumberOfInitialisedModels = function() {
        return privateStore[me.id].InitCount;
    };
    me.incrementNumberOfInitialisedModels = function() {
        privateStore[me.id].InitCount++;
    };
    me.isInitComplete = function () {
        return privateStore[me.id].InitCount < getModels().length - 1
    };
    me.initialiseForecastVehicle = function () {
        var forecastVehicle = me.getForecastVehicle();
        if (forecastVehicle != null) {
            $(document).trigger("notifyVehicleLoaded", { Vehicle: forecastVehicle, VehicleIndex: 0 });
        }
    };
    me.initialiseComparisonVehicles = function () {
            var vehicleIndex = 1;
        $(me.getComparisonVehicles()).each(function () { $(document).trigger("notifyVehicleLoaded", { Vehicle: this, VehicleIndex: vehicleIndex++ }); });
    };
    me.getForecastId = function () {
        var forecast = getForecastModel();
        return forecast.getForecastId();
    };
    me.getForecastVehicle = function () {
        var forecast = getForecastModel();
        var forecastVehicle = forecast.getForecastVehicle();
        if (forecastVehicle.VehicleId == null) {
            return null;
        }
        return forecastVehicle;
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
            .on("notifySuccess", function (sender, eventArgs) { $(".subscribers-notifySuccess").trigger("notifySuccessEventHandler", [eventArgs]); })
            .on("notifyError", function (sender, eventArgs) { $(".subscribers-notifyError").trigger("notifyErrorEventHandler", [eventArgs]); })
            .on("notifyMakes", function (sender, eventArgs) { $(".subscribers-notifyMakes").trigger("notifyMakesEventHandler", [eventArgs]); })
            .on("notifyProgrammes", function (sender, eventArgs) { $(".subscribers-notifyProgrammes").trigger("notifyProgrammesEventHandler", [eventArgs]); })
            .on("notifyModelYears", function (sender, eventArgs) { $(".subscribers-notifyModelYears").trigger("notifyModelYearsEventHandler", [eventArgs]); })
            .on("notifyGateways", function (sender, eventArgs) { $(".subscribers-notifyGateways").trigger("notifyGatewaysEventHandler", [eventArgs]); })
            .on("notifyFilterComplete", function (sender, eventArgs) { $(".subscribers-notifyFilterComplete").trigger("notifyFilterCompleteEventHandler", [eventArgs]); })
            .on("notifyVehicleLoaded", function (sender, eventArgs) { $(".subscribers-notifyVehicle").trigger("notifyVehicleLoadedEventHandler", [eventArgs]); })
            .on("notifyVehicleChanged", function (sender, eventArgs) { $(".subscribers-notifyVehicle").trigger("notifyVehicleChangedEventHandler", [eventArgs]); })
            .on("notifyResults", function (sender, eventArgs) { $(".subscribers-notifyResults").trigger("notifyResultsEventHandler", [eventArgs]); })
            .on("notifyUpdated", function (sender, eventArgs) { $(".subscribers-notifyUpdated").trigger("notifyUpdatedEventHandler", [eventArgs]); })
            .on("notifyPageChanged", function (sender, eventArgs) { $(".subscribers-notifyPageChanged").trigger("notifyPageChangedEventHandler", [eventArgs]); })
            .on("notifyFirstPage", function (sender, eventArgs) { $(".subscribers-notifyFirstPage").trigger("notifyFirstPageEventHandler", [eventArgs]); })
            .on("notifyLastPage", function (sender, eventArgs) { $(".subscribers-notifyLastPage").trigger("notifyLastPageEventHandler", [eventArgs]); })
            .on("notifyBeforePageChanged", function (sender, eventArgs) { $(".subscribers-notifyBeforePageChanged").trigger("notifyBeforePageChangedEventHandler", [eventArgs]); })
            .on("notifyValidation", function (sender, eventArgs) { $(".subscribers-notifyValidation").trigger("notifyValidationEventHandler", [eventArgs]); });

        // Iterate through each of the forecast / comparison controls and register onclick / change handlers

        $(".vehicle-filter-make").each(function () { $(this).change(me.makeChanged); });
        $(".vehicle-filter-programme").each(function () { $(this).change(me.programmeChanged); });
        $(".vehicle-filter-modelYear").each(function () { $(this).change(me.modelYearChanged); });
        $(".vehicle-filter-gateway").each(function () { $(this).change(me.gatewayChanged); });
        $(".vehicle-filter-trim").each(function () { $(this).change(me.trimChanged); });

        $("#btnNext").click(me.nextPage);
        $("#btnPrevious").click(me.previousPage);
    };
    me.registerSubscribers = function () {
        // The #notifier displays status changed message, therefore it makes sense for it to listen to status
        // events and dispatch accordingly

        $("#notifier")
            .on("notifySuccessEventHandler", me.notifySuccessEventHandler)
            .on("notifyVehicleChangedEventHandler", me.notifyVehicleChangedEventHandler)
            .on("notifyErrorEventHandler", me.notifyErrorEventHandler)
            .on("notifyUpdatedEventHandler", me.notifyUpdatedEventHandler)
            .on("notifyBeforePageChangedEventHandler", me.notifyBeforePageChangedEventHandler)
            .on("notifyValidationEventHandler", me.notifyValidationEventHandler)

        // The page and vehicle descriptions need to respond and update if the forecast vehicle is changed
        // or the page is changed

        $("#lblPageDescription").on("notifyPageChangedEventHandler", me.notifyDescriptionPageChangedEventHandler);
        $("#lblVehicleDescription")
            .on("notifyVehicleLoadedEventHandler", me.notifyVehicleDescriptionEventHandler)
            .on("notifyVehicleChangedEventHandler", me.notifyVehicleDescriptionEventHandler);

        // Notify the pager buttons of any page changes so they can toggle visibility as appropriate

        $("#btnPrevious,#btnNext").on("notifyPageChangedEventHandler", me.notifyPageChangedEventHandler);

        // For both forecast and comparisons, we have a pair of controls, one with selection controls, the other read-only fields
        // Both will listen for "notifyVehicleLoaded" events and take appropriate action (basically toggling the display)

        $(".vehicle-filter,.vehicle-readonly")
            .on("notifyVehicleChangedEventHandler", me.notifyVehicleLoadedFilterEventHandler)
            .on("notifyVehicleLoadedEventHandler", me.notifyVehicleLoadedFilterEventHandler);

        // Each of the individual dropdowns and other controls for forecast / comparison will listen for
        // broadcast changes to makes, programmes, etc.
        // They will only respond if the message is intended for them

        $(".vehicle-filter-make").on("notifyMakesEventHandler", me.notifyMakesEventHandler);
        $(".vehicle-filter-programme").on("notifyProgrammesEventHandler", me.notifyProgrammesEventHandler);
        $(".vehicle-filter-modelYear").on("notifyModelYearsEventHandler", me.notifyModelYearsEventHandler);
        $(".vehicle-filter-gateway").on("notifyGatewaysEventHandler", me.notifyGatewaysEventHandler);
        $(".vehicle-filter-trim").on("notifyTrimEventHandler", me.notifyTrimEventHandler);

        // Each of the dropdowns will listen for validation messages if the data the hold is somehow in error
        // They will only respond if the validation message is intended for them

        $(".vehicle-filter-make,.vehicle-filter-programme,.vehicle-filter-modelYear,.vehicle-filter-gateway,.vehicle-filter-trim")
            .on("notifyValidationEventHandler", me.notifyValidationFilterEventHandler);
    };
    me.nextPage = function (sender, eventArgs) {
        getPager().nextPage();
    };
    me.previousPage = function (sender, eventArgs) {
        getPager().previousPage();
    };
    me.notifyBeforePageChangedEventHandler = function (sender, eventArgs) {
        if (!eventArgs.NextPage) {
            return;
        }
        me.validateForecast(eventArgs.PageIndex);
        var model = getForecastModel();
        eventArgs.Cancel = !model.isValid();
    };
    me.notifyValidationEventHandler = function (sender, eventArgs) {
        var control = $(this);
        var errorHtml = "<div class=\"alert alert-dismissible alert-warning\"><ul>";

        if (eventArgs.IsValid == true) {
            control.html("");
            return;
        }

        $(eventArgs.Errors).each(function () {
            errorHtml += me.parseError(this);
        });
        errorHtml += "</ul></div>";

        control.html(errorHtml);
    };
    me.parseError = function (error) {
        var retVal = "";
        
        $(error.errors).each(function () {
            retVal += "<li>";
            retVal += this.ErrorMessage;
            retVal += "</li>";
        });

        return retVal;
    };
    me.notifyBeforeValidationFilterEventHandler = function (sender, eventArgs) {
        $(sender.target).removeClass("has-error")
            .removeClass("has-warning");
    };
    me.notifyValidationFilterEventHandler = function (sender, eventArgs) {
        var validationKey = $(sender.target).attr("data-val");
        $(eventArgs.Errors).each(function ()
        {
            if (validationKey == this.key) {
                $(sender.target).addClass("has-error");
            }

            if (this.errors != undefined && this.errors) {
                me.notifyAdditionalValidationFilters(this.errors);
            }
        });
    };
    me.notifyAdditionalValidationFilters = function (additionalItems) {
        $(additionalItems).each(function () {
            $(this).each(function () {
                if (this.CustomState != null)
                    me.notifyAdditionValidationFiltersForVehicle(this.CustomState);
            });
        });
        };
    me.notifyAdditionValidationFiltersForVehicle = function (customState) {
        $(customState).each(function () {
            var selector = $("[data-val='ComparisonVehiclesToValidate[" + (this.VehicleIndex - 1) + "].ComparisonVehicle']");
            selector.addClass("has-error");
        });
    };
    me.notifySuccessEventHandler = function (sender, eventArgs) {
        var notifier = $("#notifier");

        switch (eventArgs.StatusCode) {
            case "Success":
                notifier.html("<div class=\"alert alert-dismissible alert-success\">" + eventArgs.StatusMessage + "</div>");
                break;
            case "Warning":
                notifier.html("<div class=\"alert alert-dismissible alert-warning\">" + eventArgs.StatusMessage + "</div>");
                break;
            case "Failure":
                notifier.html("<div class=\"alert alert-dismissible alert-danger\">" + eventArgs.StatusMessage + "</div>");
                break;
            case "Information":
                notifier.html("<div class=\"alert alert-dismissible alert-info\">" + eventArgs.StatusMessage + "</div>");
                break;
            default:
                break;
        }
    };
    me.notifyVehicleLoadedFilterEventHandler = function (sender, eventArgs) {
        var vehicleIndex = parseInt($(sender.target).attr("data-index"));
        if (vehicleIndex != eventArgs.VehicleIndex) {
            return;
        };

        if (eventArgs.Vehicle == null ||
            eventArgs.Vehicle.VehicleId == null ||
            eventArgs.Vehicle.VehicleId == 0) {
            $(sender.target).show();
        } else {
            $(sender.target).hide();
        }
    };
    me.notifyVehicleLoadedReadOnlyEventHandler = function (sender, eventArgs) {
        var vehicleIndex = parseInt($(sender.target).attr("data-index"));
        if (vehicleIndex != eventArgs.VehicleIndex) {
            return;
        };
        var target = $(sender.target);
        var vehicle = eventArgs.Vehicle;

        if (vehicle != null && vehicle.VehicleId != null && vehicle.VehicleId != 0) {
            target.show();

            if (target.hasClass("vehicle-readonly-programme") && vehicleIndex == 0) {
                target.html(vehicle.Description);
            }
            if (target.hasClass("vehicle-readonly-programme") && vehicleIndex > 0) {
                target.html(vehicleIndex + ". " + vehicle.Description);
            }
            if (target.hasClass("vehicle-readonly-modelYear")) {
                target.html(vehicle.ModelYear);
            }
            if (target.hasClass("vehicle-readonly-gateway")) {
                target.html(vehicle.Gateway);
            }
        }
        else {
            target.hide();
        }
    };
    me.notifyVehicleChangedEventHandler = function (sender, eventArgs) {
        if (eventArgs.VehicleIndex == 0) {
            me.setForecastVehicle(eventArgs.Vehicle);
        } else {
            me.setComparisonVehicle(eventArgs.VehicleIndex - 1, eventArgs.Vehicle);
        }
        var pager = getPager();
        me.validateForecast(pager.getPageIndex() + 1, true);
    };
    me.notifyVehicleClearedEventHandler = function (sender, eventArgs) {

    };
    me.notifyVehicleDescriptionEventHandler = function (sender, eventArgs) {
        if (eventArgs.VehicleIndex != 0) {
            return;
        }
        if (eventArgs.Vehicle == null) {
            $(sender.target).html("");
        } else {
            $(sender.target).html(eventArgs.Vehicle.FullDescription);
        }
    };
    me.notifyErrorEventHandler = function (sender, eventArgs) {
        $("#notifier").html("<div class=\"alert alert-dismissible alert-danger\">" + eventArgs.statusText + "</div>");
    };
    me.notifyUpdatedEventHandler = function (sender, eventArgs) {
        $("#notifier").html("<div class=\"alert alert-dismissible alert-success\">" + eventArgs.StatusMessage + "</div>");
    };
    me.notifyMakesEventHandler = function (sender, eventArgs) {
        var vehicleIndex = parseInt($(this).attr("data-index"));

        // If this event is not intended for this specific control, return
        if (eventArgs.VehicleIndex != null && eventArgs.VehicleIndex != vehicleIndex)
            return;

        $(this).empty();

        $(".vehicle-filter-programme,.vehicle-filter-modelYear,.vehicle-filter-gateway")
            .filter(function () { return $(this).attr("data-index") == vehicleIndex; }).empty().attr("disabled", "disabled");

        $(eventArgs.Makes).each(function () {
            $("<option />", {
                val: this,
                text: this
            }).appendTo($(this));
        });

        $(this).prepend("<option value='' selected='selected'>-- SELECT --</option>");

        // As the make dropdown is actually hidden, populate the programmes on load

        me.populateProgrammes(vehicleIndex);

        $(".vehicle-filter-programme").filter(function() { $(this).attr("data-index") == vehicleIndex; }).removeAttr("disabled");
    };
    me.notifyProgrammesEventHandler = function (sender, eventArgs) {
        var vehicleIndex = parseInt($(this).attr("data-index"));

        // If this event is not intended for this specific control, return
        if (eventArgs.VehicleIndex != null && eventArgs.VehicleIndex != vehicleIndex)
            return;

        $(this).empty().attr("disabled", "disabled");

        $(".vehicle-filter-modelYear,.vehicle-filter-gateway")
            .filter(function () { return $(this).attr("data-index") == vehicleIndex; }).empty().attr("disabled", "disabled");

        // If the value of the sender is null or empty, we don't want to populate anything

        $(eventArgs.Programmes).each(function () {
            $("<option />", {
                val: this.VehicleName,
                text: this.Description
            }).appendTo($(this));
        });

        if (eventArgs.Programmes.length === 1) {
            $(this).val(eventArgs.Programmes[0].VehicleName).removeAttr("disabled");
            me.populateModelYears(vehicleIndex);
        }
        else {
            $(this).prepend("<option value='' selected='selected'>-- SELECT --</option>").removeAttr("disabled");
        }
    };
    me.notifyModelYearsEventHandler = function (sender, eventArgs) {
        var control = $(this);
        var vehicleIndex = parseInt(control.attr("data-index"));

        // If this event is not intended for this specific control, return
        if (eventArgs.VehicleIndex != null && eventArgs.VehicleIndex !== vehicleIndex)
            return;

        control.empty().attr("disabled", "disabled");

        $(".vehicle-filter-gateway").filter(function () { return $(this).attr("data-index") == vehicleIndex; }).empty().attr("disabled", "disabled");

        if (eventArgs.Filter.Name == null) {
            return;
        }

        $(eventArgs.ModelYears).each(function () {
            $("<option />", {
                val: this,
                text: this
            }).appendTo(control);
        });

        if (eventArgs.ModelYears.length === 1) {
            control.val(eventArgs.ModelYears[0]);
            me.populateGateways(vehicleIndex);
        }
        else {
            control.prepend("<option value='' selected='selected'>-- SELECT --</option>");
        }

        control.removeAttr("disabled");
    };
    me.notifyTrimEventHandler = function (sender, eventArgs) {
    };
    me.notifyDescriptionPageChangedEventHandler = function (sender, eventArgs) {
        $(sender.target).children().hide().filter(function () {
            return $(this).attr("data-index") == eventArgs;
        }).show();
        switch (pageIndex) {
            case 0:
                $(sender.target).html("Choose a carline, model year and gateway to create a forecast for");
                break;
            case 1:
                $(sender.target).html("Choose up to 5 carlines &amp; model years to compare to");
                break;
            case 2:
                $(sender.target).html("Choose equivalent trim level for each comparison");
                break;
            default:
                break;
        }
    };
    me.notifyPageChangedEventHandler = function (sender, eventArgs) {
        var button = $(sender.target);
        if (eventArgs.IsFirstPage && button.attr("id") == "btnPrevious") {
            button.hide();
        } else if (eventArgs.IsLastPage && button.attr("id") == "btnNext") {
            button.hide();
        } else {
            button.show();
        }
        if (button.attr("id") == "btnNext" && eventArgs.PageIndex == 2) {
            me.saveForecast();
        }
    };
    me.notifyGatewaysEventHandler = function (sender, eventArgs) {
        var vehicleIndex = parseInt(control.attr("data-index"));

        // If this event is not intended for this specific control, return

        if (eventArgs.VehicleIndex != null && eventArgs.VehicleIndex !== vehicleIndex)
            return;

        $(this).empty().attr("disabled", "disabled");

        if (eventArgs.Filter.ModelYear == null) {
            return;
        }

        $(eventArgs.Gateways).each(function () {
            $("<option />", {
                val: this,
                text: this
            }).appendTo($(this));
        });

        if (eventArgs.Gateways.length === 1) {
            $(this).val(eventArgs.Gateways[0]).removeAttr("disabled");
        }
        else {
            $(this).prepend("<option value='' selected='selected'>-- SELECT --</option>").removeAttr("disabled");
        }
    };
    me.makeChanged = function (data) {
        me.populateProgrammes(parseInt($(this).attr("data-index")));
    };
    me.programmeChanged = function (data) {
        var control = $(this);
        var model = getVehicleModel();
        var vehicleIndex = parseInt(control.attr("data-index"));
        me.populateModelYears(vehicleIndex);
        if (control.val() == "") {
            $(document).trigger("notifyVehicleChanged", { VehicleIndex: vehicleIndex, Vehicle: model.getEmptyVehicle() });
        }
    };
    me.modelYearChanged = function (data) {
        var vehicleIndex = parseInt($(this).attr("data-index"));
        if (vehicleIndex > 0) {
            me.populateVehicle(vehicleIndex);
        } else {
            me.populateGateways(vehicleIndex);
        }
    };
    me.gatewayChanged = function (data) {
        me.populateVehicle(parseInt($(this).attr("data-index")));
    };
    me.trimChanged = function (data) {
        var control = $(this);
        var forecast = getForecastModel();

        var vehicleIndex = parseInt(control.attr("data-index"));
        var forecastVehicleTrimId = parseInt(control.attr("data-forecast-trim"));
        var comparisonVehicle = me.getComparisonVehicle(vehicleIndex);
        var comparisonVehicleTrimId = null;

        if (control.val() != "") {
            comparisonVehicleTrimId = parseInt(control.val());
        }

        var mapping = new model.TrimMapping();
        mapping.VehicleIndex = vehicleIndex;
        mapping.ForecastVehicleTrimId = forecastVehicleTrimId;
        mapping.ComparisonVehicleTrimId = comparisonVehicleTrimId;

        forecast.setComparisonVehicleTrim(mapping);
        forecast.saveForecast();
    };
    me.populateProgrammes = function (vehicleIndex) {
        model.getProgrammes(getVehicleFilter(vehicleIndex));
    };
    me.populateModelYears = function (vehicleIndex) {
        model.getModelYears(getVehicleFilter(vehicleIndex));
    };
    me.populateGateways = function (vehicleIndex) {
        if (vehicleIndex == 0) {
            model.getGateways(getVehicleFilter(vehicleIndex));
        } else {
            model.getVehicle(getVehicleFilter(vehicleIndex));
        }
    };
    me.populateVehicle = function (vehicleIndex) {
        model.getVehicle(getVehicleFilter(vehicleIndex));
    };
    me.getPageIndex = function () {
        return privateStore[me.id].PageIndex;
    };
    me.setPageIndex = function (pageIndex) {
        privateStore[me.id].PageIndex = pageIndex;
    };
    me.saveForecast = function () {
        getForecastModel().saveForecast();
    };
    me.validateForecast = function (pageIndex, async) {
        var forecast = getForecastModel();
        var sectionToValidate = 0;
        if (pageIndex != null) {
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
        }
        forecast.validateForecast(sectionToValidate, async);
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
    function getPager() {
        return getModel("Pager");
    };
    function getVehicleFilter(vehicleIndex) {
        var model = getVehicleModel();
        var filter = new FeatureDemandPlanning.Vehicle.VehicleFilter();
        var classPrefix = ".vehicle-filter";
        var attrFilter = "[data-index='" + vehicleIndex + "']";

        filter.Make = $(classPrefix + "-make" + attrFilter).val();
        filter.Name = $(classPrefix + "-programme" + attrFilter).val();
        filter.ModelYear = $(classPrefix + "-modelYear" + attrFilter).val();
        filter.Gateway = $(classPrefix + "-gateway" + attrFilter).val();
        filter.DerivativeCode = $(classPrefix + "-derivativeCode" + attrFilter).val();
        filter.PageIndex = model.getPageIndex();
        filter.PageSize = model.getPageSize();
        filter.VehicleIndex = vehicleIndex;

        return filter;
    };
};