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
    privateStore[me.id].ConfiguredMappingsUri = params.ConfiguredMappingsUri;

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
    me.registerEvents = function () {
        $(document)
            .unbind("TrimMappingAdded").on("TrimMappingAdded", function (sender, eventArgs) { $(".subscribers-notifyTrimMappingAdded").trigger("OnTrimMappingAddedDelegate", [eventArgs]); })
            .unbind("TrimMappingAdded").on("TrimMappingRemoved", function (sender, eventArgs) { $(".subscribers-notifyTrimMappingRemoved").trigger("OnTrimMappingRemovedDelegate", [eventArgs]); })
        $("#btnAddMapping").unbind("click").on("click", me.addMapping);
    };
    me.registerSubscribers = function () {
        $("#configuredMappings")
            .unbind("OnTrimMappingAddedDelegate").on("OnTrimMappingAddedDelegate", me.onTrimMappingChangedEventHandler)
            .unbind("OnTrimMappingRemovedDelegate").on("OnTrimMappingRemovedDelegate", me.onTrimMappingChangedEventHandler)
    };
    me.onTrimMappingChangedEventHandler = function (sender, eventArgs) {
        $.ajax({
            url: me.getConfiguredMappingsUri(),
            type: "POST",
            async: false,
            dataType: "json",
            contentType: "text/html",
            data: JSON.stringify({
                forecast: me.getForecast(),
                vehicleIndex: me.getVehicleIndex(),
                forecastTrimId: me.getForecastTrimId()
            }),
            complete: getConfiguredMappingsCallback
        });
    };
    me.getConfiguredMappingsCallback = function (response) {
        $("#configuredMappings").html(response.responseText);
    };
    me.getConfiguredMappingsUri = function () {
        return privateStore[me.id].ConfiguredMappingsUri;
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
        return me.getForecast().getComparisonVehicle(me.getVehicleIndex() - 1);
    };
    me.addMapping = function (sender, eventArgs) {
        if ($("#ddlTrimMapping").val()) {
            return;
        }
        var exists = false;
        var id = parseInt($("#ddlTrimMapping").val());
        var mapping = {
            Id: id,
            Name: $("#ddlTrimMapping option[value='" + id + "']").text()
        };
        
        $(privateStore[me.id].Mappings).each(function () {
            if (this.Id == id) {
                exists = true;
                return false;
            }
        });
        if (exists) {
            return false;
        }
        privateStore[me.id].Mappings.push(mapping);
        $(document).trigger("TrimMappingAdded", mapping);
    };
    me.removeMapping = function (sender, eventArgs) {
        var exists = false;
        var id = parseInt($("#ddlTrimMapping").val());
        var mapping = {
            Id: id,
            Name: $("#ddlTrimMapping option[value='" + id + "']").text()
        };

        var i = 0;
        $(privateStore[me.id].Mappings).each(function () {
            if (this.Id == id) {
                exists = true;
                return false;
            }
            i++;
        });
        if (!exists) {
            return false;
        }
        privateStore[me.id].Mappings.splice(i, 1);
        $(document).trigger("TrimMappingRemoved", mapping);
    }
}