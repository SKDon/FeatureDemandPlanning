"use strict";

var model = namespace("FeatureDemandPlanning.Volume");

model.PowertrainAction = function(params) {
    var uid = 0;
    var privateStore = {};
    var me = this;

    privateStore[me.id = uid++] = {};
    privateStore[me.id].Config = params.Configuration;
    privateStore[me.id].Parameters = params;

    me.action = function() {
        //$(document).trigger("Filtered", me.getActionParameters());
    };
    me.getActionParameters = function() {
        var actionParameters = getData();
        $.extend(actionParameters, { Filter: me.getFilter() });
        return actionParameters;
    };
    me.getActionTitle = function () {
        return "Powertrain Summary Data";
    };
    me.getFilter = function() {
        return $("#" + me.getIdentifierPrefix() + "_FilterMessage").val();
    };
    me.getIdentifierPrefix = function() {
        return $("#Action_IdentifierPrefix").val();
    };
    me.getParameters = function() {
        return privateStore[me.id].Parameters;
    };
    me.initialise = function() {
        me.registerEvents();
        me.registerSubscribers();

        $("#Modal_OK").hide();
        $("#Modal_Cancel").html("OK");
    };
    me.registerEvents = function() {
        $("#Modal_OK").unbind("click").on("click", me.action);

        $("#" + me.getIdentifierPrefix() + "_FilterMessage").on("keyup", function() {
            var value = $("#" + me.getIdentifierPrefix() + "_FilterMessage").val();
            if (value.length === 0 || value.length >= 3) {
                $(document).trigger("Filtered", me.getActionParameters());
            }
        });
        $("#" + me.getIdentifierPrefix() + "_ClearFilter").on("click", function () {
            $("#" + me.getIdentifierPrefix() + "_FilterMessage").val("");
            $(document).trigger("Filtered", me.getActionParameters());
        });
    };
    me.registerSubscribers = function() {

    };
    me.setParameters = function (parameters) {
        privateStore[me.id].Parameters = parameters;
    };
    function getData() {
        var params = me.getParameters();
        if (params.Data != undefined)
            return JSON.parse(params.Data);

        return {};
    };
}