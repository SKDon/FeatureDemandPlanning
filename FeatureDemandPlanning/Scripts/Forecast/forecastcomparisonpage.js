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
        me.resetNumberOfInitialisedModels();
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
    me.resetNumberOfInitialisedModels = function () {
        privateStore[me.id].InitCount = 0;
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
            .unbind("notifySuccess").on("notifySuccess", function (sender, eventArgs) { $(".subscribers-notifySuccess").trigger("notifySuccessEventHandler", [eventArgs]); })
            .unbind("notifyError").on("notifyError", function (sender, eventArgs) { $(".subscribers-notifyError").trigger("notifyErrorEventHandler", [eventArgs]); })
            .unbind("notifyMakes").on("notifyMakes", function (sender, eventArgs) { $(".subscribers-notifyMakes").trigger("notifyMakesEventHandler", [eventArgs]); })
            .unbind("notifyProgrammes").on("notifyProgrammes", function (sender, eventArgs) { $(".subscribers-notifyProgrammes").trigger("notifyProgrammesEventHandler", [eventArgs]); })
            .unbind("notifyModelYears").on("notifyModelYears", function (sender, eventArgs) { $(".subscribers-notifyModelYears").trigger("notifyModelYearsEventHandler", [eventArgs]); })
            .unbind("notifyGateways").on("notifyGateways", function (sender, eventArgs) { $(".subscribers-notifyGateways").trigger("notifyGatewaysEventHandler", [eventArgs]); })
            .unbind("notifyFilterComplete").on("notifyFilterComplete", function (sender, eventArgs) { $(".subscribers-notifyFilterComplete").trigger("notifyFilterCompleteEventHandler", [eventArgs]); })
            .unbind("notifyVehicleLoaded").on("notifyVehicleLoaded", function (sender, eventArgs) { $(".subscribers-notifyVehicle").trigger("notifyVehicleLoadedEventHandler", [eventArgs]); })
            .unbind("notifyVehicleChanged").on("notifyVehicleChanged", function (sender, eventArgs) { $(".subscribers-notifyVehicle").trigger("notifyVehicleChangedEventHandler", [eventArgs]); })
            .unbind("notifyResults").on("notifyResults", function (sender, eventArgs) { $(".subscribers-notifyResults").trigger("notifyResultsEventHandler", [eventArgs]); })
            .unbind("notifyUpdated").on("notifyUpdated", function (sender, eventArgs) { $(".subscribers-notifyUpdated").trigger("notifyUpdatedEventHandler", [eventArgs]); })
            .unbind("notifyPageChanged").on("notifyPageChanged", function (sender, eventArgs) { $(".subscribers-notifyPageChanged").trigger("notifyPageChangedEventHandler", [eventArgs]); })
            .unbind("notifyFirstPage").on("notifyFirstPage", function (sender, eventArgs) { $(".subscribers-notifyFirstPage").trigger("notifyFirstPageEventHandler", [eventArgs]); })
            .unbind("notifyLastPage").on("notifyLastPage", function (sender, eventArgs) { $(".subscribers-notifyLastPage").trigger("notifyLastPageEventHandler", [eventArgs]); })
            .unbind("notifyBeforePageChanged").on("notifyBeforePageChanged", function (sender, eventArgs) { $(".subscribers-notifyBeforePageChanged").trigger("notifyBeforePageChangedEventHandler", [eventArgs]); })
            .unbind("notifyValidation").on("notifyValidation", function (sender, eventArgs) { $(".subscribers-notifyValidation").trigger("notifyValidationEventHandler", [eventArgs]); });
    };
    me.registerSubscribers = function () {
        // The #notifier displays status changed message, therefore it makes sense for it to listen to status
        // events and dispatch accordingly

        $("#notifier")
            .unbind("notifySuccessEventHandler")
            .on("notifySuccessEventHandler", me.notifySuccessEventHandler)
            .unbind("notifyVehicleChangedEventHandler")
            .on("notifyVehicleChangedEventHandler", me.notifyVehicleChangedEventHandler)
            .unbind("notifyErrorEventHandler")
            .on("notifyErrorEventHandler", me.notifyErrorEventHandler)
            .unbind("notifyUpdatedEventHandler")
            .on("notifyUpdatedEventHandler", me.notifyUpdatedEventHandler)
            .unbind("notifyBeforePageChangedEventHandler")
            .on("notifyBeforePageChangedEventHandler", me.notifyBeforePageChangedEventHandler)
            .unbind("notifyValidationEventHandler")
            .on("notifyValidationEventHandler", me.notifyValidationEventHandler)

        // The page and vehicle descriptions need to respond and update if the forecast vehicle is changed
        // or the page is changed

        $("#lblPageDescription")
            .unbind("notifyPageChangedEventHandler")
            .on("notifyPageChangedEventHandler", me.notifyDescriptionPageChangedEventHandler);
        $("#lblVehicleDescription")
            .unbind("notifyVehicleLoadedEventHandler")
            .on("notifyVehicleLoadedEventHandler", me.notifyVehicleDescriptionEventHandler)
            .unbind("notifyVehicleChangedEventHandler")
            .on("notifyVehicleChangedEventHandler", me.notifyVehicleDescriptionEventHandler);

        // Notify the pager buttons of any page changes so they can toggle visibility as appropriate

        $("#btnPrevious,#btnNext")
            .unbind("notifyPageChangedEventHandler")
            .on("notifyPageChangedEventHandler", me.notifyPageChangedEventHandler);

        // Notify the parent form of any page changes so we can actually render the appropriate content for the page

        $("#frmContent")
            .unbind("notifyPageChangedEventHandler")
            .on("notifyPageChangedEventHandler", me.notifyPageContentChangedEventHandler);

        // For both forecast and comparisons, we have a pair of controls, one with selection controls, the other read-only fields
        // Both will listen for "notifyVehicleLoaded" events and take appropriate action (basically toggling the display)

        $(".vehicle-filter,.vehicle-readonly")
            .unbind("notifyVehicleChangedEventHandler")
            .on("notifyVehicleChangedEventHandler", me.notifyVehicleLoadedFilterEventHandler)
            .unbind("notifyVehicleLoadedEventHandler")
            .on("notifyVehicleLoadedEventHandler", me.notifyVehicleLoadedFilterEventHandler);

        // Each of the individual dropdowns and other controls for forecast / comparison will listen for
        // broadcast changes to makes, programmes, etc.
        // They will only respond if the message is intended for them

        $(".vehicle-filter-make")
            .unbind("notifyMakesEventHandler")
            .on("notifyMakesEventHandler", me.notifyMakesEventHandler);
        $(".vehicle-filter-programme")
            .unbind("notifyProgrammesEventHandler")
            .on("notifyProgrammesEventHandler", me.notifyProgrammesEventHandler);
        $(".vehicle-filter-modelYear")
            .unbind("notifyModelYearsEventHandler")
            .on("notifyModelYearsEventHandler", me.notifyModelYearsEventHandler);
        $(".vehicle-filter-gateway")
            .unbind("notifyGatewaysEventHandler")
            .on("notifyGatewaysEventHandler", me.notifyGatewaysEventHandler);
        $(".vehicle-filter-trim")
            .unbind("notifyTrimEventHandler")
            .on("notifyTrimEventHandler", me.notifyTrimEventHandler);

        // Each of the dropdowns will listen for validation messages if the data the hold is somehow in error
        // They will only respond if the validation message is intended for them

        $(".vehicle-filter-make,.vehicle-filter-programme,.vehicle-filter-modelYear,.vehicle-filter-gateway,.vehicle-filter-trim")
            .unbind("notifyValidationEventHandler")
            .on("notifyValidationEventHandler", me.notifyValidationFilterEventHandler);

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
        $(".vehicle-filter-trim").each(function () {
            $(this).unbind("change").on("change", me.trimChanged);
        });

        $("#btnNext").unbind("click").on("click", me.nextPage);
        $("#btnPrevious").unbind("click").on("click", me.previousPage);
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

        if ($(sender.target).hasClass("vehicle-readonly")) {

            if (eventArgs.Vehicle == null ||
            eventArgs.Vehicle.VehicleId == null ||
            eventArgs.Vehicle.VehicleId == 0) {
                $(sender.target).hide();
            } else {
                $(sender.target).show();
            }

        } else {

            if (eventArgs.Vehicle == null ||
             eventArgs.Vehicle.VehicleId == null ||
             eventArgs.Vehicle.VehicleId == 0) {
                $(sender.target).show();
            } else {
                $(sender.target).hide();
            }
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
        if (eventArgs.Vehicle == null || eventArgs.Vehicle.ProgrammeId == null) {
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
        var control = $(this);
        var vehicleIndex = parseInt(control.attr("data-index"));

        // If this event is not intended for this specific control, return
        if (eventArgs.VehicleIndex != null && eventArgs.VehicleIndex != vehicleIndex)
            return;

        control.empty();

        $(".vehicle-filter-programme,.vehicle-filter-modelYear,.vehicle-filter-gateway")
            .filter(function () { return control.attr("data-index") == vehicleIndex; }).empty().attr("disabled", "disabled");

        $(eventArgs.Makes).each(function () {
            $("<option />", {
                val: this,
                text: this
            }).appendTo(control);
        });

        control.prepend("<option value='' selected='selected'>-- SELECT --</option>");

        // As the make dropdown is actually hidden, populate the programmes on load

        me.populateProgrammes(vehicleIndex);

        $(".vehicle-filter-programme").filter(function() { $(this).attr("data-index") == vehicleIndex; }).removeAttr("disabled");
    };
    me.notifyProgrammesEventHandler = function (sender, eventArgs) {
        var control = $(this);
        var vehicleIndex = parseInt($(this).attr("data-index"));

        // If this event is not intended for this specific control, return
        if (eventArgs.VehicleIndex != null && eventArgs.VehicleIndex != vehicleIndex)
            return;

        control.empty().attr("disabled", "disabled");

        $(".vehicle-filter-modelYear,.vehicle-filter-gateway")
            .filter(function () { return $(this).attr("data-index") == vehicleIndex; }).empty().attr("disabled", "disabled");

        // If the value of the sender is null or empty, we don't want to populate anything

        $(eventArgs.Programmes).each(function () {
            $("<option />", {
                val: this.VehicleName,
                text: this.Description
            }).appendTo(control);
        });

        if (eventArgs.Programmes.length === 1) {
            control.val(eventArgs.Programmes[0].VehicleName).removeAttr("disabled");
            me.populateModelYears(vehicleIndex);
        }
        else {
            control.prepend("<option value='' selected='selected'>-- SELECT --</option>").removeAttr("disabled");
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
        var descriptions = $(".page-description").hide().filter(function () {
            return $(this).attr("data-index") == eventArgs.PageIndex;
        }).show();
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
    me.notifyPageContentChangedEventHandler = function (sender, eventArgs) {

        var forecast = getForecastModel().getForecast();
        var params = JSON.stringify({ forecast: forecast, pageIndex: eventArgs.PageIndex });

        $.ajax({
            type: "POST",
            url: getPager().getPageUri(),
            data: params,
            contentType: "application/json",
            success: me.notifyPageContentChangedCallback,
            error: function(response) {
                alert(response.responseText);
            },
            async: true
        });
    };
    me.notifyPageContentChangedCallback = function (content) {
        $("#frmContent").html(content);
        me.registerEvents();
        me.registerSubscribers();
        me.initialiseComparisonVehicles();
    };
    me.notifyGatewaysEventHandler = function (sender, eventArgs) {
        var control = $(this);
        var vehicleIndex = parseInt(control.attr("data-index"));

        // If this event is not intended for this specific control, return

        if (eventArgs.VehicleIndex != null && eventArgs.VehicleIndex !== vehicleIndex)
            return;

        control.empty().attr("disabled", "disabled");

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
            control.val(eventArgs.Gateways[0]).removeAttr("disabled");
        }
        else {
            control.prepend("<option value='' selected='selected'>-- SELECT --</option>").removeAttr("disabled");
        }
    };
    me.makeChanged = function (data) {
        var model = getVehicleModel();
        var vehicleIndex = parseInt(control.attr("data-index"));
        $(document).trigger("notifyVehicleChanged", { VehicleIndex: vehicleIndex, Vehicle: model.getEmptyVehicle() });
        me.populateProgrammes(vehicleIndex);
    };
    me.programmeChanged = function (data) {
        var control = $(this);
        var model = getVehicleModel();
        var vehicleIndex = parseInt(control.attr("data-index"));
        $(document).trigger("notifyVehicleChanged", { VehicleIndex: vehicleIndex, Vehicle: model.getEmptyVehicle() });
        me.populateModelYears(vehicleIndex);
    };
    me.modelYearChanged = function (data) {
        var vehicleIndex = parseInt($(this).attr("data-index"));
        var model = getVehicleModel();
        $(document).trigger("notifyVehicleChanged", { VehicleIndex: vehicleIndex, Vehicle: model.getEmptyVehicle() });
        if (vehicleIndex > 0) {
            me.populateVehicle(vehicleIndex);
        } else {
            me.populateGateways(vehicleIndex);
        }
    };
    me.gatewayChanged = function (data) {
        var vehicleIndex = parseInt($(this).attr("data-index"));
        var model = getVehicleModel();
        if ($(this).val() == "") {
            $(document).trigger("notifyVehicleChanged", { VehicleIndex: vehicleIndex, Vehicle: model.getEmptyVehicle() });
        }
        else {
            me.populateVehicle(vehicleIndex);
        }
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
        getVehicleModel().getProgrammes(getVehicleFilter(vehicleIndex));
    };
    me.populateModelYears = function (vehicleIndex) {
        getVehicleModel().getModelYears(getVehicleFilter(vehicleIndex));
    };
    me.populateGateways = function (vehicleIndex) {
        if (vehicleIndex == 0) {
            getVehicleModel().getGateways(getVehicleFilter(vehicleIndex));
        } else {
            getVehicleModel().getVehicle(getVehicleFilter(vehicleIndex));
        }
    };
    me.populateVehicle = function (vehicleIndex) {
        getVehicleModel().getVehicle(getVehicleFilter(vehicleIndex));
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

        filter.Make = ""; //$(classPrefix + "-make" + attrFilter).val();
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