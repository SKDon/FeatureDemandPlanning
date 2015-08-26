"use strict";

var model = namespace("FeatureDemandPlanning.Forecast");

model.ComparisonVehicles = function (params) {
    var uid = 0;
    var privateStore = {};
    var me = this;

    privateStore[me.id = uid++] = {};
    privateStore[me.id].ForecastId = params.ForecastId;
    privateStore[me.id].ComparisonVehicles = params.ComparisonVehicles;
    privateStore[me.id].Config = params.Configuration;
    privateStore[me.id].Vehicles = [
        new FeatureDemandPlanning.Vehicle.Vehicle(params),
        new FeatureDemandPlanning.Vehicle.Vehicle(params),
        new FeatureDemandPlanning.Vehicle.Vehicle(params),
        new FeatureDemandPlanning.Vehicle.Vehicle(params),
        new FeatureDemandPlanning.Vehicle.Vehicle(params)
    ];

    me.initialise = function () {
    };
}