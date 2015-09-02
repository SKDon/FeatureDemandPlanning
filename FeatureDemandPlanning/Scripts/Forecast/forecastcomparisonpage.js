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
        privateStore[me.id].InitCount++;
        if (privateStore[me.id].InitCount < getModels().length - 1) {
            return;
        }
        me.initialiseForecastVehicle();
        me.initialiseComparisonVehicles();
    };
    me.initialiseForecastVehicle = function () {
        var forecastVehicle = me.getForecastVehicle();
        if (forecastVehicle != null) {
            $(document).trigger("notifyVehicleLoaded", { Vehicle: forecastVehicle, VehicleIndex: 0 });
        }
    };
    me.initialiseComparisonVehicles = function () {
        var comparisonVehicles = me.getComparisonVehicles();
        if (comparisonVehicles != null) {
            var vehicleIndex = 1;
            $(comparisonVehicles).each(function () {
                $(document).trigger("notifyVehicleLoaded", { Vehicle: this, VehicleIndex: vehicleIndex++ });
            });
        }
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
        var forecast = getForecastModel();
        forecast.setForecastVehicle(forecastVehicle);
    };
    me.getComparisonVehicles = function () {
        var forecast = getForecastModel();
        return forecast.getComparisonVehicles();
    };
    me.getComparisonVehicle = function (vehicleIndex) {
        var forecast = getForecastModel();
        return forecast.getComparisonVehicle(vehicleIndex);
    };
    me.setComparisonVehicle = function (vehicleIndex, comparisonVehicle) {
        var forecast = getForecastModel();
        forecast.setComparisonVehicle(vehicleIndex, comparisonVehicle);
    };
    me.setComparisonVehicleTrim = function (vehicleIndex, forecastVehicleTrimId, comparisonVehicleTrimId) {
        var forecast = getForecastModel();
        forecast.setComparisonVehicleTrim(vehicleIndex, comparison)
    };
    me.registerEvents = function () {
        $(document).on("notifySuccess", function (sender, eventArgs) {
            $(".subscribers-notifySuccess").trigger("notifySuccessEventHandler", [eventArgs]);
        });
        $(document).on("notifyError", function (sender, eventArgs) {
            $(".subscribers-notifyError").trigger("notifyErrorEventHandler", [eventArgs]);
        });
        $(document).on("notifyMakes", function (sender, eventArgs) {
            $(".subscribers-notifyMakes").trigger("notifyMakesEventHandler", [eventArgs]);
        });
        $(document).on("notifyProgrammes", function (sender, eventArgs) {
            $(".subscribers-notifyProgrammes").trigger("notifyProgrammesEventHandler", [eventArgs]);
        });
        $(document).on("notifyModelYears", function (sender, eventArgs) {
            $(".subscribers-notifyModelYears").trigger("notifyModelYearsEventHandler", [eventArgs]);
        });
        $(document).on("notifyGateways", function (sender, eventArgs) {
            $(".subscribers-notifyGateways").trigger("notifyGatewaysEventHandler", [eventArgs]);
        });
        $(document).on("notifyFilterComplete", function (sender, eventArgs) {
            $(".subscribers-notifyFilterComplete").trigger("notifyFilterCompleteEventHandler", [eventArgs]);
        });
        $(document).on("notifyVehicleLoaded", function (sender, eventArgs) {
            $(".subscribers-notifyVehicle").trigger("notifyVehicleLoadedEventHandler", [eventArgs]);
        });
        $(document).on("notifyVehicleChanged", function (sender, eventArgs) {
            $(".subscribers-notifyVehicle").trigger("notifyVehicleChangedEventHandler", [eventArgs]);
        });
        $(document).on("notifyResults", function (sender, eventArgs) {
            $(".subscribers-notifyResults").trigger("notifyResultsEventHandler", [eventArgs]);
        });
        $(document).on("notifyUpdated", function (sender, eventArgs) {
            $(".subscribers-notifyUpdated").trigger("notifyUpdatedEventHandler", [eventArgs]);
        });
        $(document).on("notifyPageChanged", function (sender, eventArgs) {
            $(".subscribers-notifyPageChanged").trigger("notifyPageChangedEventHandler", [eventArgs]);
        });
        $(document).on("notifyFirstPage", function (sender, eventArgs) {
            $(".subscribers-notifyFirstPage").trigger("notifyFirstPageEventHandler", [eventArgs]);
        });
        $(document).on("notifyLastPage", function (sender, eventArgs) {
            $(".subscribers-notifyLastPage").trigger("notifyLastPageEventHandler", [eventArgs]);
        });
        $(document).on("notifyBeforePageChanged", function (sender, eventArgs) {
            $(".subscribers-notifyBeforePageChanged").trigger("notifyBeforePageChangedEventHandler", [eventArgs]);
        });
        $(document).on("notifyBeforeValidation", function (sender, eventArgs) {
            $(".subscribers-notifyValidation").trigger("notifyBeforeValidationEventHandler", [eventArgs]);
        });
        $(document).on("notifyValidation", function (sender, eventArgs) {
            $(".subscribers-notifyValidation").trigger("notifyValidationEventHandler", [eventArgs]);
        });
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

        $("#notifier").on("notifySuccessEventHandler", me.notifySuccessEventHandler);
        $("#notifier").on("notifyVehicleChangedEventHandler", me.notifyVehicleChangedEventHandler);
        $("#notifier").on("notifyErrorEventHandler", me.notifyErrorEventHandler);
        $("#notifier").on("notifyUpdatedEventHandler", me.notifyUpdatedEventHandler);
        $("#notifier").on("notifyBeforePageChangedEventHandler", me.notifyBeforePageChangedEventHandler);
        $("#notifier").on("notifyValidationEventHandler", me.notifyValidationEventHandler);

        // The page and vehicle descriptions need to respond and update if the forecast vehicle is changed
        // or the page is changed

        $("#lblPageDescription").on("notifyPageChangedEventHandler", me.notifyDescriptionPageChangedEventHandler);
        $("#lblVehicleDescription").on("notifyVehicleLoadedEventHandler", me.notifyVehicleDescriptionEventHandler);
        $("#lblVehicleDescription").on("notifyVehicleChangedEventHandler", me.notifyVehicleDescriptionEventHandler);

        // Notify the pager buttons of any page changes so they can toggle visibility as appropriate

        $("#btnPrevious").on("notifyPageChangedEventHandler", me.notifyPageChangedEventHandler);
        $("#btnNext").on("notifyPageChangedEventHandler", me.notifyPageChangedEventHandler);

        // Notify the parent form of any page changes so we can actually render the appropriate content for the page

        $("#frmContent").on("notifyPageChangedEventHandler", me.notifyPageContentChangedEventHandler);

        // For both forecast and comparisons, we have a pair of controls, one with selection controls, the other read-only fields
        // Both will listen for "notifyVehicleLoaded" events and take appropriate action (basically toggling the display)

        $(".vehicle-filter").on("notifyVehicleChangedEventHandler", me.notifyVehicleLoadedFilterEventHandler);
        $(".vehicle-readonly").on("notifyVehicleChangedEventHandler", me.notifyVehicleLoadedReadOnlyEventHandler)
        $(".vehicle-filter").on("notifyVehicleLoadedEventHandler", me.notifyVehicleLoadedFilterEventHandler);
        $(".vehicle-readonly").on("notifyVehicleLoadedEventHandler", me.notifyVehicleLoadedReadOnlyEventHandler)

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

        $(".vehicle-filter").on("notifyBeforeValidationEventHandler", me.notifyBeforeValidationFilterEventHandler);
        $(".vehicle-filter").on("notifyValidationEventHandler", me.notifyValidationFilterEventHandler);
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
        var notifier = $("#notifier");
        notifier.html("<div class=\"alert alert-dismissible alert-danger\">" + eventArgs.statusText + "</div>");
    };
    me.notifyUpdatedEventHandler = function (sender, eventArgs) {
        var notifier = $("#notifier");
        notifier.html("<div class=\"alert alert-dismissible alert-success\">" + eventArgs.StatusMessage + "</div>");
    };
    me.notifyMakesEventHandler = function (sender, eventArgs) {
        var control = $(this);
        var vehicleIndex = parseInt(control.attr("data-index"));

        // If this event is not intended for this specific control, return
        if (eventArgs.VehicleIndex != null && eventArgs.VehicleIndex != vehicleIndex)
            return;

        control.empty();

        var indexFilter = "";
        if (eventArgs.VehicleIndex != null) {
            indexFilter = "[data-index='" + vehicleIndex + "']";
        }
        $(".vehicle-filter-programme" + indexFilter).empty().attr("disabled", "disabled");
        $(".vehicle-filter-modelYear" + indexFilter).empty().attr("disabled", "disabled");
        $(".vehicle-filter-gateway" + indexFilter).empty().attr("disabled", "disabled");

        $(eventArgs.Makes).each(function () {
            $("<option />", {
                val: this,
                text: this
            }).appendTo(control);
        });

        control.prepend("<option value='' selected='selected'>-- SELECT --</option>");

        // As the make dropdown is actually hidden, populate the programmes on load

        me.populateProgrammes(vehicleIndex);

        $(".vehicle-filter-programme" + indexFilter).removeAttr("disabled");
    };
    me.notifyProgrammesEventHandler = function (sender, eventArgs) {
        var control = $(this);
        var vehicleIndex = parseInt(control.attr("data-index"));

        // If this event is not intended for this specific control, return
        if (eventArgs.VehicleIndex != null && eventArgs.VehicleIndex != vehicleIndex)
            return;

        control.empty();
        control.attr("disabled", "disabled");

        var indexFilter = "";
        if (eventArgs.VehicleIndex != null) {
            indexFilter = "[data-index='" + vehicleIndex + "']";
        }
        $(".vehicle-filter-modelYear" + indexFilter).empty().attr("disabled", "disabled");
        $(".vehicle-filter-gateway" + indexFilter).empty().attr("disabled", "disabled");

        // If the value of the sender is null or empty, we don't want to populate anything

        $(eventArgs.Programmes).each(function () {
            $("<option />", {
                val: this.VehicleName,
                text: this.Description
            }).appendTo(control);
        });

        if (eventArgs.Programmes.length === 1) {
            control.val(eventArgs.Programmes[0].VehicleName);
            me.populateModelYears(vehicleIndex);
        }
        else {
            control.prepend("<option value='' selected='selected'>-- SELECT --</option>");
        }

        control.removeAttr("disabled");
    };
    me.notifyModelYearsEventHandler = function (sender, eventArgs) {
        var control = $(this);
        var vehicleIndex = parseInt(control.attr("data-index"));

        // If this event is not intended for this specific control, return
        if (eventArgs.VehicleIndex != null && eventArgs.VehicleIndex !== vehicleIndex)
            return;

        control.empty();
        control.attr("disabled", "disabled");
        $(".vehicle-filter-gateway[data-index='" + vehicleIndex + "']").empty().attr("disabled", "disabled");

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
        var pageIndex = eventArgs;
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
        var pager = getPager();
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
    me.notifyPageContentChangedEventHandler = function (sender, eventArgs) {
        $.ajax({
            type: "POST",
            url: $(sender.target).attr("action"),
            data: eventArgs.PageIndex,
            success: function(response) {
                $(sender.target).html(response.data);
            },
            async: true
        });
    };
    me.notifyGatewaysEventHandler = function (sender, eventArgs) {
        var control = $(this);
        var vehicleIndex = parseInt(control.attr("data-index"));

        // If this event is not intended for this specific control, return

        if (eventArgs.VehicleIndex != null && eventArgs.VehicleIndex !== vehicleIndex)
            return;

        control.empty();
        control.attr("disabled", "disabled");

        if (eventArgs.Filter.ModelYear == null) {
            return;
        }

        $(eventArgs.Gateways).each(function () {
            $("<option />", {
                val: this,
                text: this
            }).appendTo(control);
        });

        if (eventArgs.Gateways.length === 1) {
            control.val(eventArgs.Gateways[0]);
        }
        else {
            control.prepend("<option value='' selected='selected'>-- SELECT --</option>");
        }
        control.removeAttr("disabled");
    };
    me.makeChanged = function (data) {
        var control = $(this);
        var vehicleIndex = parseInt(control.attr("data-index"));
        me.populateProgrammes(vehicleIndex);
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
        var control = $(this);
        var vehicleIndex = parseInt(control.attr("data-index"));
        if (vehicleIndex > 0) {
            me.populateVehicle(vehicleIndex);
        } else {
            me.populateGateways(vehicleIndex);
        }
    };
    me.gatewayChanged = function (data) {
        var control = $(this);
        var vehicleIndex = parseInt(control.attr("data-index"));
        me.populateVehicle(vehicleIndex);
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
        var model = getVehicleModel();
        var filter = getFilter(model.getPageSize(), model.getPageIndex(), vehicleIndex);
        model.getProgrammes(filter);
    };
    me.populateModelYears = function (vehicleIndex) {
        var model = getVehicleModel();
        var filter = getFilter(model.getPageSize(), model.getPageIndex(), vehicleIndex);
        model.getModelYears(filter);
    };
    me.populateGateways = function (vehicleIndex) {
        var model = getVehicleModel();
        var filter = getFilter(model.getPageSize(), model.getPageIndex(), vehicleIndex);
        if (vehicleIndex == 0) {
            model.getGateways(filter);
        } else {
            model.getVehicle(filter);
        }
    };
    me.populateVehicle = function (vehicleIndex) {
        var model = getVehicleModel();
        var filter = getFilter(model.getPageSize(), model.getPageIndex(), vehicleIndex);
        model.getVehicle(filter);
    };
    me.getPageIndex = function () {
        return privateStore[me.id].PageIndex;
    };
    me.setPageIndex = function (pageIndex) {
        privateStore[me.id].PageIndex = pageIndex;
    };
    me.saveForecast = function () {
        var forecast = getForecastModel();
        forecast.saveForecast();
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
        var models = getModels();
        $(models).each(function () {
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
    function getFilter(pageSize, pageIndex, vehicleIndex) {
        var filter = new FeatureDemandPlanning.Vehicle.VehicleFilter();
        var classPrefix = ".vehicle-filter";
        var attrFilter = "[data-index='" + vehicleIndex + "']";

        filter.Make = $(classPrefix + "-make" + attrFilter).val();
        filter.Name = $(classPrefix + "-programme" + attrFilter).val();
        filter.ModelYear = $(classPrefix + "-modelYear" + attrFilter).val();
        filter.Gateway = $(classPrefix + "-gateway" + attrFilter).val();
        filter.DerivativeCode = $(classPrefix + "-derivativeCode" + attrFilter).val();

        filter.PageIndex = pageIndex;
        filter.PageSize = pageSize;
        filter.VehicleIndex = vehicleIndex;

        return filter;
    };
};