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
    privateStore[me.id].TrimMapping = params.TrimMapping;

    me.ModelName = "Forecast";

    me.initialise = function (callback) {
        var me = this;
        $(document).trigger("notifySuccess", me);
        callback();
    };

    me.getSaveForecastUri = function () {
        return privateStore[me.id].SaveForecastUri;
    }

    me.setComparisonVehicle = function (vehicleIndex, comparisonVehicle) {
        if (privateStore[me.id].ComparisonVehicles.length > vehicleIndex) {
            privateStore[me.id].ComparisonVehicles[vehicleIndex] = comparisonVehicle;
        }
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
    }

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
    }

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

    function loadForecastCallback(response) {
        $(document).trigger("notifyResults", response);
    }

    function saveForecastCallback(response) {
        $(document).trigger("notifyUpdated", response);
    }

    function genericErrorCallback(response) {
        if (response.status == 400) {
            var json = JSON.parse(response.responseText);
            $(document).trigger("notifyValidation", [json]);
        } else {
            $(document).trigger("notifyError", response);
        }
    }
}

