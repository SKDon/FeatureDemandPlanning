"use strict";

var model = namespace("FeatureDemandPlanning.EngineCodeMapping");

model.EngineCodeMapping = function (params) {
    /* Private members */

    var uid = 0;
    var privateStore = {};
    var me = this;

    /* Constructor */
    privateStore[me.id = uid++] = {};
    privateStore[me.id].EngineCodeMappings = params.EngineCodeMappings;
    privateStore[me.id].EngineCodeMappingsUri = params.EngineCodeMappingsUri;
    privateStore[me.id].EngineCodeMappingsEditUri = params.EngineCodeMappingsEditUri;
    privateStore[me.id].DeleteUri = params.DeleteUri;
    privateStore[me.id].AddUri = params.AddUri;
    privateStore[me.id].Configuration = params.Configuration;
    privateStore[me.id].Config = {};
    privateStore[me.id].PageSize = params.PageSize;
    privateStore[me.id].PageIndex = params.PageIndex;

    me.getPageSize = function () {
        return privateStore[me.id].PageSize;
    }

    me.getPageIndex = function () {
        return privateStore[me.id].PageIndex
    }

    me.getEngineCodeMappingsUri = function () {
        return privateStore[me.id].EngineCodeMappingsUri;
    }

    me.getEngineCodeMappingsEditUri = function () {
        return privateStore[me.id].EngineCodeMappingsEditUri;
    }

    me.getEngineCodeMappings = function () {
        return privateStore[me.id].EngineCodeMappings;
    };

    me.filterResults = function (filter) {
        $(document).trigger("notifyFilterComplete", filter);
    }

    me.loadEngineCodeMappings = function (filter) {

        $.ajax({
            url: privateStore[me.id].EngineCodeMappingsUri,
            type: "GET",
            dataType: "json",
            data: filter,
            success: loadEngineCodeMappingsCallback,
            error: genericErrorCallback
        });
    }

    me.updateEngineCodeMapping = function (programmeId, engineId, engineCode) {
        
        $.ajax({
            url: me.getEngineCodeMappingsEditUri(),
            type: "POST",
            dataType: "json",
            data:
            {
                programmeId: programmeId,
                engineId: engineId,
                engineCode: engineCode
            },
            success: updateEngineCodeMappingCallback,
            error: genericErrorCallback
        });
    };

    me.initialise = function () {
        var me = this;
        $(document).trigger("notifySuccess", me);
    };

    function getConfiguration() {
        $.ajax({
            url: privateStore[me.id].ConfigurationUri,
            type: "POST",
            dataType: "json",
            success: genericSuccessCallback,
            error: genericErrorCallback
        });
    };

    function getMarkets() {
        $.ajax({
            url: privateStore[me.id].MarketsUri,
            type: "POST",
            dataType: "json",
            data: "",
            success: genericSuccessCallback,
            error: genericErrorCallback
        });
    };

    function genericSuccessCallback(response) {
        privateStore[me.id].Config = response.Configuration;
        privateStore[me.id].AvailableMarkets = response.AvailableMarkets;
        privateStore[me.id].TopMarkets = response.TopMarkets;
        $(document).trigger("notifySuccess", response);
    };

    function genericErrorCallback(response) {
        if (response.status === 200) {
            return false;
        }
        privateStore[me.id].Config = response.Configuration;
        privateStore[me.id].AvailableMarkets = response.AvailableMarkets;
        privateStore[me.id].TopMarkets = response.TopMarkets;
        $(document).trigger("notifyError", response);
    };

    function loadEngineCodeMappingsCallback(response) {
        $(document).trigger("notifyResults", response);
    }

    function updateEngineCodeMappingCallback(response) {
        $(document).trigger("notifyUpdated", response);
    }
};