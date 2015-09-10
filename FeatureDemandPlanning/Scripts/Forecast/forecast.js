"use strict";

var model = namespace("FeatureDemandPlanning.Forecast");

model.TrimMapping = function () {
    var me = this;
    me.VehicleIndex = null,
    me.ForecastVehicleTrimId = null,
    me.ComparisonVehicleTrimId = null
};

model.Forecast = function (params) {
    var uid = 0;
    var privateStore = {};
    var me = this;

    privateStore[me.id = uid++] = {};
    privateStore[me.id].ForecastVehicle = params.ForecastVehicle;
    privateStore[me.id].ForecastId = params.ForecastId;
    privateStore[me.id].ComparisonVehicles = params.ComparisonVehicles;
    privateStore[me.id].Config = params.Configuration;
    privateStore[me.id].SaveForecastUri = params.SaveForecastUri;
    privateStore[me.id].ValidateForecastUri = params.ValidateForecastUri;
    privateStore[me.id].ValidationMessageUri = params.ValidationMessageUri;
    privateStore[me.id].TrimMapping = params.TrimMapping;
    privateStore[me.id].IsValid = true;

    me.ModelName = "Forecast";

    me.initialise = function () {
        var me = this;
        $(document).trigger("notifySuccess", me);
    };
    me.getSaveForecastUri = function () {
        return privateStore[me.id].SaveForecastUri;
    };
    me.getValidateForecastUri = function () {
        return privateStore[me.id].ValidateForecastUri;
    };
    me.getValidationMessageUri = function () {
        return privateStore[me.id].ValidationMessageUri;
    };
    me.setComparisonVehicle = function (vehicleIndex, comparisonVehicle) {
        if (privateStore[me.id].ComparisonVehicles.length > vehicleIndex) {
            privateStore[me.id].ComparisonVehicles[vehicleIndex] = comparisonVehicle;
        }
    };
    me.isValid = function () {
        return privateStore[me.id].IsValid;
    };
    me.setComparisonVehicleTrim = function (trim) {
        var existingTrim = null;
        var existingTrimIndex = 0
        $(privateStore[me.id].TrimMapping).each(function () {
            // If the trim mapping has changed, return so it can be removed and the new mapping added
            if (this.ForecastVehicleTrimId == trim.ForecastVehicleTrimId &&
                this.VehicleIndex == trim.VehicleIndex) {
                existingTrim = this;
                return false;
            }
            existingTrimIndex++;
        });

        // Replace mapping if one exists, note we don't handle removal here, let the controller code do that
        if (existingTrim != null) {
            privateStore[me.id].TrimMapping[existingTrimIndex] = trim;
        } else {
            privateStore[me.id].TrimMapping.push(trim);
        }

        me.saveForecast();
    };
    me.getComparisonVehicle = function (vehicleIndex) {
        var comparisonVehicle = null;
        if (privateStore[me.id].ComparisonVehicles.length > vehicleIndex) {
            comparisonVehicle = privateStore[me.id].ComparisonVehicles[vehicleIndex];
        }
        return comparisonVehicle;
    };
    me.getComparisonVehicles = function () {
        return privateStore[me.id].ComparisonVehicles;
    };
    me.getTrimMapping = function () {
        return privateStore[me.id].TrimMapping;
    };
    me.getForecastId = function () {
        return privateStore[me.id].ForecastId;
    };
    me.setForecastId = function (forecastId) {
        privateStore[me.id].ForecastId = value;
    };

    me.getForecastVehicle = function () {
        return privateStore[this.id].ForecastVehicle;
    };

    me.setForecastVehicle = function (forecastVehicle) {
        privateStore[me.id].ForecastVehicle = forecastVehicle;
    };

    me.getForecast = function () {
        return {
            ForecastId: me.getForecastId(),
            ForecastVehicle: me.getForecastVehicle(),
            ComparisonVehicles: me.getComparisonVehicles(),
            TrimMapping: me.getTrimMapping()
        }
    };

    me.saveForecast = function () {
        var forecast = me.getForecast();
        var encodedForecast = JSON.stringify(forecast);

        $(document).trigger("BeforeValidation", forecast);

        $.ajax({
            url: me.getSaveForecastUri(),
            type: "POST",
            dataType: "json",
            contentType: "application/json; charset=utf-8",
            data: encodedForecast,
            success: saveForecastCallback,
            error: genericErrorCallback
        });
    };

    me.validateForecast = function (sectionToValidate, isAsync) {

        var forecast = me.getForecast();
        var encodedForecast = JSON.stringify({ forecastToValidate: forecast, sectionToValidate: sectionToValidate });

        $(document).trigger("BeforeValidation", forecast);

        $.ajax({
            url: me.getValidateForecastUri(),
            type: "POST",
            async: isAsync != undefined ? isAsync : false, // Need to validate before we are allowed to do anything else
            dataType: "json",
            contentType: "application/json; charset=utf-8",
            data: encodedForecast,
            complete: validateForecastCallback
        });
    };

    function loadForecastCallback(response) {
        $(document).trigger("Results", response);
    };

    function saveForecastCallback(response) {

        $(document).trigger("Updated", response);
    };

    function validateForecastCallback(response) {
        var json = JSON.parse(response.responseText);
        privateStore[me.id].IsValid = json.IsValid;
        $(document).trigger("Validation", [json]);
    }

    function genericErrorCallback(response) {
        if (response.status == 400) {
            var json = JSON.parse(response.responseText);
            privateStore[me.id].IsValid = false;
            $(document).trigger("Validation", [json]);
        } else {
            $(document).trigger("Error", response);
        }
    };
}

