"use strict";

var model = namespace("FeatureDemandPlanning.Vehicle");

model.VehicleFilter = function () {
    var me = this;
    me.Make = "";
    me.Name = "";
    me.ModelYear = "";
    me.Gateway = "";
    me.DerivativeCode = "";
    me.VehicleIndex = null;
    me.ModelName = "VehicleFilter";
}

model.Vehicle = function (params) {
    var uid = 0;
    var privateStore = {};
    var me = this;

    privateStore[me.id = uid++] = {};
    privateStore[me.id].Makes = {};
    privateStore[me.id].Programmes = {};
    privateStore[me.id].ModelYears = {};
    privateStore[me.id].Gateways = {};
    privateStore[me.id].DerivativeCodes = {};
    privateStore[me.id].FilterVehiclesUri = params.FilterVehiclesUri;
    privateStore[me.id].Config = params.Configuration;
    privateStore[me.id].PageSize = params.PageSize;
    privateStore[me.id].PageIndex = params.PageIndex;

    me.ModelName = "Vehicle";

    me.getPageSize = function () {
        return privateStore[me.id].PageSize;
    }

    me.getPageIndex = function () {
        return privateStore[me.id].PageIndex
    }

    me.initialise = function (callback) {
        // trigger automatic load of the vehicle makes
        // this will trigger broadcast events that all dropdowns will listen to, as vehicle index is not specified
        me.getMakes();
        callback();
    };

    me.getMakes = function () {
        getData({}, getMakesCallback);
    };

    me.getNumberOfComparisonVehicles = function () {
        var config = getConfiguration();
        return config.NumberOfComparisonVehicles;
    };

    me.getProgrammes = function (filter) {
        getData({ make: filter.Make, vehicleIndex: filter.VehicleIndex }, getProgrammesCallback);
    };

    me.getModelYears = function (filter) {
        getData({ make: filter.Make, name: filter.Name, vehicleIndex: filter.VehicleIndex }, getModelYearsCallback);
    };

    me.getGateways = function (filter) {
        getData({ make: filter.Make, name: filter.Name, modelYear: filter.ModelYear, vehicleIndex: filter.VehicleIndex }, getGatewaysCallback);
    };

    me.getDerivativeCodes = function (filter) {
        getData({ make: filter.Make, name: filter.Name, modelYear: filter.ModelYear, vehicleIndex: filter.VehicleIndex }, getDerivativeCodesCallback);
    };

    me.getVehicle = function (filter) {
        getData({ make: filter.Make, name: filter.Name, modelYear: filter.ModelYear, gateway: filter.Gateway, vehicleIndex: filter.VehicleIndex }, getVehicleCallback);
    };

    me.filterResults = function () {
        $(document).trigger("notifyFilterComplete");
    };

    function getData(data, callback) {
        $.ajax({
            url: privateStore[me.id].FilterVehiclesUri,
            type: "POST",
            dataType: "json",
            data: data,
            success: callback,
            error: genericErrorCallback
        });
    }

    function getConfiguration() {
        return privateStore[me.id].Config;
    }

    function getMakesCallback(response) {
        setFilteredVehicleDetailsFromResponse(response);
        $(document).trigger("notifyMakes", response);
    };

    function getProgrammesCallback(response) {
        setFilteredVehicleDetailsFromResponse(response);
        $(document).trigger("notifyProgrammes", response);
    };

    function getModelYearsCallback(response) {
        setFilteredVehicleDetailsFromResponse(response);
        $(document).trigger("notifyModelYears", response);
    };

    function getGatewaysCallback(response) {
        setFilteredVehicleDetailsFromResponse(response);
        $(document).trigger("notifyGateways", response);
    };

    function getDerivativeCodesCallback(response) {
        setFilteredVehicleDetailsFromResponse(response);
        $(document).trigger("notifyDerivativeCodes", response);
    };

    function getVehicleCallback(response) {
        var vehicle = null;
        if (response.AvailableVehicles.length > 0)
            vehicle = response.AvailableVehicles[0];

        $(document).trigger("notifyVehicleChanged", { VehicleIndex: response.VehicleIndex, Vehicle: vehicle });
    }

    function setFilteredVehicleDetailsFromResponse(response) {
        privateStore[me.id].Config = response.Configuration;
        privateStore[me.id].Makes = response.Makes;
        privateStore[me.id].Programmes = response.Programmes;
        privateStore[me.id].ModelYears = response.ModelYears;
        privateStore[me.id].Gateways = response.Gateways;
        privateStore[me.id].DerivativeCodes = response.DerivativeCodes;
    };

    function genericErrorCallback(response) {
        privateStore[me.id].Config = response.Configuration;
        $(document).trigger("notifyError", response);
    };


}