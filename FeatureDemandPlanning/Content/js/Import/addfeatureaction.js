"use strict";

var model = namespace("FeatureDemandPlanning.Import");

model.AddFeatureAction = function (params) {
    var uid = 0;
    var privateStore = {};
    var me = this;

    privateStore[me.id = uid++] = {};
    privateStore[me.id].Config = params.Configuration;
    privateStore[me.id].ActionUri = params.ModalActionUri;
    privateStore[me.id].ListAvailableFeaturesUri = params.ListAvailableFeaturesUri;
    privateStore[me.id].SelectedFeatureGroup = "";
    privateStore[me.id].SelectedFeatureSubGroup = "";
    privateStore[me.id].SelectedFeatureGroupId = null;
    privateStore[me.id].AvailableFeatures = [];
    privateStore[me.id].Parameters = params;

    me.action = function () {
        sendData(me.getActionUri(), me.getActionParameters());
    };
    me.displaySelectedFeatureGroup = function () {
        $("#" + me.getIdentifierPrefix() + "_SelectedFeatureGroup").html(me.getSelectedFeatureGroup());
    }
    me.displaySelectedFeatureSubGroup = function () {
        var selectedFeatureSubGroup = me.getSelectedFeatureSubGroup();
        if (selectedFeatureSubGroup == "") {
            selectedFeatureSubGroup = "Select Feature Sub-Group";
        }
        $("#" + me.getIdentifierPrefix() + "_SelectedFeatureSubGroup").html(selectedFeatureSubGroup);
    };
    me.filterSubGroups = function () {
        var selectedFeatureSubGroup = $("#" + me.getIdentifierPrefix() + "_SelectedFeatureSubGroup");
        var subGroupList = $("#" + me.getIdentifierPrefix() + "_FeatureSubGroupList")
        var subGroups = subGroupList
            .find("a.feature-sub-group-item")
            .hide()
            .filter("[data-filter='" + me.getSelectedFeatureGroup() + "']")
            .show();

        if (subGroups.length == 0)
        {
            me.setSelectedFeatureSubGroup("N/A");
            me.displaySelectedFeatureSubGroup();
            selectedFeatureSubGroup.attr("disabled", "disabled");
        }
        else
        {
            me.setSelectedFeatureSubGroup("");
            me.displaySelectedFeatureSubGroup();
            selectedFeatureSubGroup.removeAttr("disabled");
        }
    };
    me.getActionParameters = function () {
        return $.extend({}, getData(), {
            "FeatureCode": me.getImportFeatureCode(),
            "ImportFeatureCode": me.getImportFeatureCode(),
            "FeatureDescription": me.getSelectedFeatureDescription(),
            "FeatureGroupId": me.getSelectedFeatureGroupId()
        });
    };
    me.getIdentifierPrefix = function () {
        return $("#Action_IdentifierPrefix").val();
    };
    me.getImportFeatureCode = function () {
        return $("#" + me.getIdentifierPrefix() + "_ImportFeatureCode").attr("data-target");
    };
    me.getActionUri = function () {
        return privateStore[me.id].ActionUri;
    };
    me.getParameters = function () {
        return privateStore[me.id].Parameters;
    };
    me.getSelectedFeatureCode = function () {
        return me.getImportFeatureCode();
    };
    me.getSelectedFeatureGroup = function () {
        return privateStore[me.id].SelectedFeatureGroup;
    };
    me.getSelectedFeatureGroupId = function () {
        return privateStore[me.id].SelectedFeatureGroupId;
    };
    me.getSelectedFeatureSubGroup = function () {
        return privateStore[me.id].SelectedFeatureSubGroup;
    };
    me.getSelectedFeatureDescription = function () {
        return $("#" + me.getIdentifierPrefix() + "_FeatureDescription").val().trim();
    };
    me.groupSelectedEventHandler = function (sender) {
        me.setSelectedFeatureGroup($(sender.target).attr("data-target"));
        me.displaySelectedFeatureGroup();
        me.filterSubGroups();
    };
    me.initialise = function () {
        me.listAvailableFeatures();
        me.registerEvents();
        me.registerSubscribers();
        me.filterSubGroups();
    };
    me.listAvailableFeatures = function () {

    };
    me.listAvailableFeaturesCallback = function (response) {

    };
    me.onSuccessEventHandler = function (sender, eventArgs) {
        $("#Modal_Notify")
            .removeClass("alert-danger")
            .removeClass("alert-warning")
            .addClass("alert-success")
            .html("New feature '" + me.getImportFeatureCode() + "' added successfully")
            .show();
        $("#Modal_OK").hide();
        $("#Modal_Cancel").html("Close");
    };
    me.onErrorEventHandler = function (sender, eventArgs) {
        if (eventArgs.IsValidation) {
            $("#Modal_Notify")
                .removeClass("alert-danger")
                .removeClass("alert-success")
                .addClass("alert-warning").html(eventArgs.Message).show();
        } else {
            $("#Modal_Notify")
                .removeClass("alert-warning")
                .removeClass("alert-success")
                .addClass("alert-danger").html(eventArgs.Message).show();
        }
    };
    me.registerEvents = function () {
        var prefix = me.getIdentifierPrefix();
        $("#" + prefix + "_FeatureGroupList").find("a.feature-group-item").on("click", function (e) {
            me.groupSelectedEventHandler(e);
            e.preventDefault();
        });
        $("#" + prefix + "_FeatureSubGroupList").find("a.feature-sub-group-item").on("click", function (e) {
            me.subGroupSelectedEventHandler(e);
            e.preventDefault();
        });
        $("#Modal_OK").unbind("click").on("click", me.action);
        $(document)
            .unbind("Success").on("Success", function (sender, eventArgs) { $(".subscribers-notify").trigger("OnSuccessDelegate", [eventArgs]); })
            .unbind("Error").on("Error", function (sender, eventArgs) { $(".subscribers-notify").trigger("OnErrorDelegate", [eventArgs]); })
    };
    me.registerSubscribers = function () {
        $("#Modal_Notify")
            .unbind("OnSuccessDelegate").on("OnSuccessDelegate", me.onSuccessEventHandler)
            .unbind("OnErrorDelegate").on("OnErrorDelegate", me.onErrorEventHandler)
    };
    me.setParameters = function (parameters) {
        privateStore[me.id].Parameters = parameters;
    };
    me.setSelectedFeatureGroup = function (featureGroup) {
        privateStore[me.id].SelectedFeatureGroup = featureGroup;
    };
    me.setSelectedFeatureSubGroup = function (featureSubGroup) {
        privateStore[me.id].SelectedFeatureSubGroup = featureSubGroup;
    };
    me.setSelectedFeatureGroupId = function (groupId) {
        privateStore[me.id].SelectedFeatureGroupId = groupId;
    };
    me.subGroupSelectedEventHandler = function (sender) {
        me.setSelectedFeatureSubGroup($(sender.target).attr("data-content"));
        me.setSelectedFeatureGroupId(parseInt($(sender.target).attr("data-target")));
        me.displaySelectedFeatureSubGroup();
    };
    function getData() {
        var params = me.getParameters();
        if (params.Data != undefined)
            return JSON.parse(params.Data)

        return {};
    };
    function sendData(uri, params) {
        $.ajax({
            "dataType": "json",
            "async": true,
            "type": "POST",
            "url": uri,
            "data": params,
            "success": function (json) {
                $(document).trigger("Success", json);
            },
            "error": function (jqXHR, textStatus, errorThrown) {
                $(document).trigger("Error", JSON.parse(jqXHR.responseText));
            }
        });
    };
}