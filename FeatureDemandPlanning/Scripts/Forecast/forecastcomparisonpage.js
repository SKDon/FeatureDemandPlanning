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
    privateStore[me.id].EventComplete = true;

    me.initialise = function () {
        me.resetNumberOfInitialisedModels();
        me.registerEvents();
        me.registerSubscribers();
        $(privateStore[me.id].Models).each(function () {
            this.initialise(me.initialiseCallback);
        });
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
    me.initialiseCallback = function () {
        me.incrementNumberOfInitialisedModels();
        if (!me.isInitComplete()) {
            return;
        }
    };
    me.getNumberOfInitialisedModels = function () {
        return privateStore[me.id].InitCount;
    };
    me.incrementNumberOfInitialisedModels = function () {
        privateStore[me.id].InitCount++;
    };
    me.isInitComplete = function () {
        return privateStore[me.id].InitCount < getModels().length - 1
    };
    me.resetNumberOfInitialisedModels = function () {
        privateStore[me.id].InitCount = 0;
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
        me.notifyDown();
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
            control.fadeOut("slow").html("");
            return;
        }

        $(eventArgs.Errors).each(function () {
            errorHtml += me.parseError(this);
        });
        errorHtml += "</ul></div>";

        control.fadeOut("fast", function () {
            control.html(errorHtml).fadeIn("slow");
        });
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
        $(eventArgs.Errors).each(function () {
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
        var notifier = $("#notifier")

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
        notifier.fadeIn("slow");
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
        me.setVehicle(eventArgs.VehicleIndex, eventArgs.Vehicle)
        me.toggleEvent();
        me.validateForecast(getPager().getPageIndex() + 1, true);
    };
    me.notifyVehicleDescriptionEventHandler = function (sender, eventArgs) {
        if (eventArgs.VehicleIndex != 0) {
            return;
        }
        if (eventArgs.Vehicle == null || eventArgs.Vehicle.ProgrammeId == null || eventArgs.MultipleResults == true) {
            $(sender.target).html("");
        } else {
            $(sender.target).html(eventArgs.Vehicle.FullDescription);
        }
    };
    me.notifyDown = function () {
        //$("#notifier").fadeOut("slow").html("");
    };
    me.clearVehicle = function (vehicleIndex) {
        var emptyVehicle = getVehicleModel().getEmptyVehicle();
        me.setVehicle(vehicleIndex, emptyVehicle);
    };
    me.setVehicle = function (vehicleIndex, vehicle) {
        if (vehicleIndex == 0) {
            me.setForecastVehicle(vehicle);
        } else {
            me.setComparisonVehicle(vehicleIndex - 1, vehicle);
        }
    }
    me.notifyErrorEventHandler = function (sender, eventArgs) {
        $("#notifier").html("<div class=\"alert alert-dismissible alert-danger\">" + eventArgs.statusText + "</div>");
    };
    me.notifyUpdatedEventHandler = function (sender, eventArgs) {
        $("#notifier").html("<div class=\"alert alert-dismissible alert-success\">" + eventArgs.StatusMessage + "</div>");
    };
    me.isEventForControl = function (control, vehicleIndex) {
        return vehicleIndex != null && vehicleIndex == parseInt(control.attr("data-index"));
    };
    me.notifyMakesEventHandler = function (sender, eventArgs) {
        var control = $(this);
        var vehicleIndex = parseInt(control.attr("data-index"));

        if (!me.isEventForControl(control, eventArgs.VehicleIndex))
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

        $(".vehicle-filter-programme").filter(function () { $(this).attr("data-index") == vehicleIndex; }).removeAttr("disabled");
    };
    me.notifyProgrammesEventHandler = function (sender, eventArgs) {
        var control = $(this);
        var vehicleIndex = parseInt($(this).attr("data-index"));

        if (!me.isEventForControl(control, eventArgs.VehicleIndex))
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

        if (eventArgs.Programmes.length == 1) {
            control.val(eventArgs.Programmes[0].VehicleName).removeAttr("disabled");
            me.populateModelYears(vehicleIndex);
        }
        else {
            me.toggleEvent();
            control.prepend("<option value='' selected='selected'>-- SELECT --</option>").removeAttr("disabled");
        }
        me.populateVehicle(vehicleIndex);
    };
    me.notifyModelYearsEventHandler = function (sender, eventArgs) {
        var control = $(this);
        var vehicleIndex = parseInt(control.attr("data-index"));

        if (!me.isEventForControl(control, eventArgs.VehicleIndex))
            return;

        control.empty().attr("disabled", "disabled");

        $(".vehicle-filter-gateway").filter(function () { return $(this).attr("data-index") == vehicleIndex; }).empty().attr("disabled", "disabled");

        //if (eventArgs.Filter.Name == null) {
        //    return;
        //}

        $(eventArgs.ModelYears).each(function () {
            $("<option />", {
                val: this,
                text: this
            }).appendTo(control);
        });

        if (eventArgs.ModelYears.length == 1) {
            control.val(eventArgs.ModelYears[0]);
            if (vehicleIndex > 0) {
                me.toggleEvent(); // No gateway to choose on the comparison vehicle
            }
            me.populateGateways(vehicleIndex);
        }
        else {
            me.toggleEvent();
            control.prepend("<option value='' selected='selected'>-- SELECT --</option>");
        }

        control.removeAttr("disabled");
        me.populateVehicle(vehicleIndex);
    };
    me.notifyGatewaysEventHandler = function (sender, eventArgs) {
        var control = $(this);
        var vehicleIndex = parseInt(control.attr("data-index"));

        if (!me.isEventForControl(control, eventArgs.VehicleIndex))
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
        me.toggleEvent()
        me.populateVehicle(vehicleIndex);
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
        var pager = getPager();

        pager.getPageContent(params, me.notifyPageContentChangedCallback)
    };
    me.notifyPageContentChangedCallback = function (content) {
        $("#frmContent").html(content);
        me.initialise();
    };
    me.resetVehicle = function (vehicleIndex, startEventChain) {
        me.notifyDown();
        me.clearVehicle(vehicleIndex);
        me.resetEvent();
        if (startEventChain == true)
            me.toggleEvent();
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
            me.toggleEvent();
            me.populateVehicle(vehicleIndex);
        }
    };
    me.populateVehicle = function (vehicleIndex) {
        if (me.isEventCompleted())
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

        filter.Make = "";
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