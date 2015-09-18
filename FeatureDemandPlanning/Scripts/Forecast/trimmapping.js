"use strict";

/* Provides handling for trim mapping functionality */

var model = namespace("FeatureDemandPlanning.TrimMapping");

model.TrimMapping = function (params) {
    var uid = 0;
    var privateStore = {};
    var me = this;

    privateStore[me.id = uid++] = {};
    privateStore[me.id].Mappings = [];
    privateStore[me.id].Forecast = {};
    privateStore[me.id].VehicleIndex = 0;
    privateStore[me.id].ForecastTrimId = 0;
    privateStore[me.id].TrimMappingUri = params.TrimMappingUri;

    me.ModelName = "TrimMapping";

    me.initialise = function (data) {
        if (data === undefined) {
            return;
        }
        privateStore[me.id].Forecast = data.Forecast;
        privateStore[me.id].VehicleIndex = data.VehicleIndex;
        privateStore[me.id].ForecastTrimId = data.ForecastTrimId;
        privateStore[me.id].OldMappings = me.getComparisonVehicle().TrimMappings; // So we can revert back if cancelled
        me.registerEvents();
        me.registerSubscribers();
    };
    me.getDisplayText = function (trimMappings) {
        var displayText = "";
        $(trimMappings.ComparisonVehicleTrimMappings).each(function () {
            displayText += this.Name;
            displayText += ", ";
        });
        if (displayText.length > 0) {
            displayText = displayText.substring(0, displayText.length - 2);
        } else {
            displayText = "Select..."
        }
        return displayText;
    };
    me.registerEvents = function () {
        $(document)
            .unbind("TrimMappingAdded").on("TrimMappingAdded", function (sender, eventArgs) { $(".subscribers-notifyTrimMappingAdded").trigger("OnTrimMappingAddedDelegate", [eventArgs]); })
            .unbind("TrimMappingRemoved").on("TrimMappingRemoved", function (sender, eventArgs) { $(".subscribers-notifyTrimMappingRemoved").trigger("OnTrimMappingRemovedDelegate", [eventArgs]); })
            .unbind("ModalOk").on("ModalOk", me.onTrimMappingUpdatedEventHandler);
        $("#btnAddMapping").unbind("click").on("click", me.addMapping);
    };
    me.registerSubscribers = function () {
        $(".subscribers-notifyTrimMappingAdded").unbind("OnTrimMappingAddedDelegate")
            .on("OnTrimMappingAddedDelegate", me.onTrimMappingChangedEventHandler);
        $(".subscribers-notifyTrimMappingRemoved").unbind("OnTrimMappingRemovedDelegate")
            .on("OnTrimMappingRemovedDelegate", me.onTrimMappingChangedEventHandler);
        //$(".subscribers-notifyTrimMappingChanged").unbind("OnTrimMappingChangedDelegate")
        //    .on("OnTrimMappingUpdatedDelegate", me.onTrimMappingUpdatedEventHandler);
    };
    me.onTrimMappingChangedEventHandler = function (sender, eventArgs) {
        $.ajax({
            url: me.getTrimMappingUri(),
            method: "POST",
            async: true,
            contentType: "application/json",
            data: JSON.stringify({
                forecast: me.getForecast(),
                vehicleIndex: me.getVehicleIndex(),
                forecastTrimId: me.getForecastTrimId()
            }),
            dataType: "html",
            complete: me.getConfiguredMappingsCallback
        });
    };
    me.onTrimMappingUpdatedEventHandler = function (sender, eventArgs) {
        $(document).trigger("TrimMappingUpdated", {
            Forecast: me.getForecast(),
            VehicleIndex: me.getVehicleIndex(),
            ForecastTrimId: me.getForecastTrimId()
        });
    };
    me.getConfiguredMappingsCallback = function (response) {
        $("#configuredMappings").html(response.responseText);
        $(".removeMapping").on("click", me.removeMapping);
    };
    me.getTrimMappingUri = function () {
        return privateStore[me.id].TrimMappingUri;
    };
    me.getForecast = function () {
        return privateStore[me.id].Forecast;
    };
    me.getVehicleIndex = function () {
        return privateStore[me.id].VehicleIndex;
    };
    me.getForecastTrimId = function () {
        return privateStore[me.id].ForecastTrimId;
    };
    me.getComparisonVehicle = function () {
        return me.getForecast().ComparisonVehicles[me.getVehicleIndex() - 1];
    };
    me.getMappings = function () {
        return me.getComparisonVehicle().TrimMappings;
    };
    me.getMapping = function () {
        var mapping = null;
        $(me.getMappings()).each(function (m) {
            if (this.ForecastVehicleTrim.Id == me.getForecastTrimId()) {
                mapping = this;
                return false;
            }
        });
        return mapping;
    };
    me.getNewComparisonTrimLevelMapping = function (trimId) {
        return {
            Id: trimId,
            Name: $("#ddlTrimMapping option[value='" + trimId + "']").text()
        };
    };
    me.getSelectedComparisonTrimLevel = function () {
        if ($("#ddlTrimMapping").val() == "")
            return -1;

        return parseInt($("#ddlTrimMapping").val());
    };
    me.addMappingForForecastTrimLevel = function () {
        var mappingForForecastTrimLevel = {
            ForecastVehicleTrim: { Id: me.getForecastTrimId() },
            ComparisonVehicleTrimMappings: []
        }
        me.getComparisonVehicle().TrimMappings.push(mappingForForecastTrimLevel);
    };
    me.addMapping = function (sender, eventArgs) {
        var comparisonTrimLevel = me.getSelectedComparisonTrimLevel();
        if (comparisonTrimLevel == -1) {
            return;
        }
        var exists = false;
        var currentMapping = me.getMapping();

        if (currentMapping == null) {
            me.addMappingForForecastTrimLevel();
            currentMapping = me.getMapping();
        }
        $(currentMapping.ComparisonVehicleTrimMappings).each(function () {
            exists = (this.Id == comparisonTrimLevel);
        });
        if (!exists) {
            var newMapping = me.getNewComparisonTrimLevelMapping(comparisonTrimLevel);
            currentMapping.ComparisonVehicleTrimMappings.push(newMapping);
            $(document).trigger("TrimMappingAdded", newMapping);
        }
    };
    me.removeMapping = function (sender, eventArgs) {
        var target = $(sender.target);
        var comparisonTrimId = parseInt(target.attr("data-trim-id"));
        var mapping = me.getMapping();
        var i = 0;
        $(mapping.ComparisonVehicleTrimMappings).each(function () {
            if (this.Id == comparisonTrimId) {
                return false;
            }
            i++;
        });
        mapping.ComparisonVehicleTrimMappings.splice(i, 1);
        $(document).trigger("TrimMappingRemoved", mapping);
    }
}