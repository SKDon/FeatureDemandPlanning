"use strict";

var model = namespace("FeatureDemandPlanning.Volume");

model.Details = function(params) {
    var uid = 0;
    var privateStore = {};
    var me = this;

    privateStore[me.id = uid++] = {};
    privateStore[me.id].Config = params.Configuration;
    privateStore[me.id].ModalContentUri = params.ModalContentUri;
    privateStore[me.id].ModalActionUri = params.ModalActionUri;
    privateStore[me.id].AddNoteUri = params.AddNoteUri;
    privateStore[me.id].Parameters = params;

    me.ModelName = "Details";

    me.initialise = function() {
        me.registerEvents();
        me.registerSubscribers();
    };
    me.registerEvents = function() {
        $("#Page_AddNoteButton").unbind("click").on("click", me.addNote);
    };
    me.registerSubscribers = function() {

    };
    me.addNote = function() {
        var addNoteAction = me.getAddNoteAction();
        addNoteAction.action();
    };
    me.getIdentifierPrefix = function() {
        return $("#Action_IdentifierPrefix").val();
    };
    me.getActionContentUri = function () {
        return privateStore[me.id].ModalContentUri;
    };
    me.getActionModel = function () {
        return null;
    };
    me.getAddNoteAction = function() {
        return new FeatureDemandPlanning.Volume.AddNoteAction(me.getParameters());
    };
    me.getActionUri = function () {
        return privateStore[me.id].ModalActionUri;
    };
    me.getActionTitle = function () {
        return "Take Rate Item Details";
    };
    me.getConfiguration = function () {
        return privateStore[me.id].Configuration;
    };
    me.getParameters = function () {
        return privateStore[me.id].Parameters;
    };
    me.getUpdateParameters = function () {
        return $.extend({}, getData(), {
        });
    }
    me.getVehicleId = function () {
        return getData().VehicleId;
    };
    me.setParameters = function (parameters) {
        privateStore[me.id].Parameters = parameters;
    };
    function getData() {
        var params = me.getParameters();
        if (params.Data != undefined)
            return JSON.parse(me.getParameters().Data);

        return {};
    };
    function sendData(uri, params, callback) {
        $.ajax({
            "dataType": "json",
            "async": true,
            "type": "POST",
            "url": uri,
            "data": params,
            "success": function (json) {
                callback(json)
            }
        });
    };
}

