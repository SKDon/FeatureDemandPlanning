"use strict";

var model = namespace("FeatureDemandPlanning.Volume");

model.OxoVolume = function (params) {
    var uid = 0;
    var privateStore = {};
    var me = this;

    privateStore[me.id = uid++] = {};
    privateStore[me.id].OxoDocId = params.OxoDocId;
    privateStore[me.id].TakeRateId = params.TakeRateId;
    privateStore[me.id].MarketGroupId = params.MarketGroupId;
    privateStore[me.id].MarketId = params.MarketId;
    privateStore[me.id].ModalContentUri = params.ModalContentUri;
    privateStore[me.id].ModalActionUri = params.ModalActionUri;
    privateStore[me.id].Vehicle = params.Vehicle;
    privateStore[me.id].Config = params.Configuration;
    privateStore[me.id].ActionsUri = params.ActionsUri;
    privateStore[me.id].EditVolumeUri = params.EditVolumeUri;
    privateStore[me.id].GetChangesetUri = params.GetChangesetUri;
    privateStore[me.id].RevertChangesetUri = params.RevertChangesetUri;
    privateStore[me.id].SaveChangesetUri = params.SaveChangesetUri;
    privateStore[me.id].PersistChangesetUri = params.PersistChangesetUri;
    privateStore[me.id].UpdateFilteredDataUri = params.UpdateFilteredDataUri;
    privateStore[me.id].ValidateUri = params.ValidateUri;
    privateStore[me.id].ValidationMessageUri = params.ValidationMessageUri;
    privateStore[me.id].AddNoteUri = params.AddNoteUri;
    privateStore[me.id].RefreshNotesUri = params.RefreshNotesUri;
    privateStore[me.id].IsValid = true;
    privateStore[me.id].FdpVolumeHeaders = [];
    privateStore[me.id].CurrentEditValue = null;
    privateStore[me.id].Parameters = params;

    me.ModelName = "OxoVolume";

    me.initialise = function () {
        $(document).trigger("notifySuccess", me);
    };
    me.getActionsUri = function () {
        return privateStore[me.id].ActionsUri;
    };
    me.getActionModel = function (action) {
        return new FeatureDemandPlanning.Volume.DetailsAction(me.getParameters());
    };
    me.getActionContentUri = function (action) {
        return privateStore[me.id].ModalContentUri;
    };
    me.getTakeRateId = function() {
        return privateStore[me.id].TakeRateId;
    }
    me.getOxoDocId = function () {
        return privateStore[me.id].OxoDocId;
    };
    me.getMarketGroupId = function () {
        return privateStore[me.id].MarketGroupId;
    };
    me.getMarketId = function () {
        return privateStore[me.id].MarketId;
    };
    me.getParameters = function () {
        return privateStore[me.id].Parameters;
    };
    me.getVehicle = function () {
        return privateStore[me.id].Vehicle;
    }
    me.getConfiguration = function () {
        return privateStore[me.id].Configuration;
    };
    me.getEditVolumeUri = function () {
        return privateStore[me.id].EditVolumeUri;
    };
    me.getChangesetUri = function () {
        return privateStore[me.id].GetChangesetUri;
    };
    me.getRevertChangsetUri = function () {
        return privateStore[me.id].RevertChangesetUri;
    };
    me.getSaveChangesetUri = function () {
        return privateStore[me.id].SaveChangesetUri;
    };
    me.getPersistChangesetUri = function () {
        return privateStore[me.id].PersistChangesetUri;
    };
    me.getUpdateFilteredDataUri = function () {
        return privateStore[me.id].UpdateFilteredDataUri;
    };
    me.getValidateUri = function () {
        return privateStore[me.id].ValidateUri;
    };
    me.getValidationMessageUri = function () {
        return privateStore[me.id].ValidationMessageUri;
    };
    me.getCurrentEditValue = function () {
        return privateStore[me.id].CurrentEditValue;
    };
    me.setCurrentEditValue = function (value) {
        privateStore[me.id].CurrentEditValue = value;
    };
    me.setDocument = function (oxoDocument) {
        privateStore[me.id].Document = oxoDocument;
    };
    me.setVehicle = function (vehicle) {
        privateStore[me.id].Vehicle = vehicle;
    };
    me.isValid = function () {
        return privateStore[me.id].IsValid;
    };
    me.getVolume = function () {
        return {
            Document: me.getDocument(),
            Vehicle: me.getVehicle(),
            FdpVolumeHeaders: me.getFdpVolumeHeaders()
        }
    };
    me.loadChangeset = function (callback) {
        var params = getFilter();
        $.ajax({
            "dataType": "json",
            "async": true,
            "type": "POST",
            "url": me.getChangesetUri(),
            "data": params,
            "success": function (response) {
                callback(response);
            },
            "error": function (response) {
                genericErrorCallback(response);
            }
        });
    };
    me.revertChangeset = function (callback) {
        var params = getFilter();
        $.ajax({
            "dataType": "json",
            "async": true,
            "type": "POST",
            "url": me.getRevertChangesetUri(),
            "data": params,
            "success": function (response) {
                callback(response);
            },
            "error": function (response) {
                genericErrorCallback(response);
            }
        });
    };
    me.saveData = function (changesToSave, callback) {
        var params = getFilter();
        params.Changeset = changesToSave;
        $.ajax({
            "dataType": "json",
            "async": true,
            "type": "POST",
            "url": me.getSaveChangesetUri(),
            "data": params,
            "success": function (json) {
                //$(document).trigger("Success", json);
                callback();
            },
            "error": function (response) {
                genericErrorCallback(response);
            }
        });
    };
    me.persistData = function (changesToPersist, callback) {
        var params = getFilter();
        params.Changeset = changesToPersist;
        $.ajax({
            "dataType": "json",
            "async": true,
            "type": "POST",
            "url": me.getPersistChangesetUri(),
            "data": params,
            "success": function (json) {
                $(document).trigger("Success", json);
                callback();
            },
            "error": function (response) {
                genericErrorCallback(response);
            }
        });
    };
    me.validate = function (sectionToValidate, isAsync) {
        var volume = me.getVolume();
        var encodedVolume = JSON.stringify({ volumeToValidate: volume, sectionToValidate: sectionToValidate });

        $(document).trigger("BeforeValidation", volume);

        $.ajax({
            url: me.getValidateUri(),
            method: "POST",
            async: isAsync != undefined ? isAsync : false, // Need to validate before we are allowed to do anything else
            dataType: "json",
            contentType: "application/json",
            data: encodedVolume,
            complete: validateVolumeCallback
        });
    };
    me.getOxoDocuments = function () {
        return privateStore[me.id].OxoDocuments;
    };
    me.getFdpVolumeHeader = function (fdpVolumeHeaderId) {
        return {
            FdpVolumeHeaderId: fdpVolumeHeaderId
        };
    };
    me.getFdpVolumeHeaders = function () {
        return privateStore[me.id].FdpVolumeHeaders;
    };
    me.addFdpVolumeHeader = function (fdpVolumeHeaderId) {
        if (me.hasFdpVolumeHeader(fdpVolumeHeaderId))
            return;

        me.getFdpVolumeHeaders().push(me.getFdpVolumeHeader(fdpVolumeHeaderId));
    };
    me.clearFdpVolumeHeaders = function () {
        privateStore[me.id].FdpVolumeHeaders = [];
    };
    me.removeFdpVolumeHeader = function (fdpVolumeHeaderId) {
        if (!me.hasFdpVolumeHeader(fdpVolumeHeaderId))
            return;

        var i = 0;
        $(me.getFdpVolumeHeaders()).each(function () {
            if (this.FdpVolumeHeaderId === fdpVolumeHeaderId) {
                return false;
            }
            i++;
        });
        me.getFdpVolumeHeaders().splice(i, 1);
    };
    me.hasFdpVolumeHeader = function (fdpVolumeHeaderId) {
        var exists = false;
        $(me.getFdpVolumeHeaders()).each(function () {
            if (this.FdpVolumeHeaderId === fdpVolumeHeaderId) {
                exists = true;
                return false;
            }
        });
        return exists;
    };
    function validateVolumeCallback(response) {
        var json = JSON.parse(response.responseText);
        privateStore[me.id].IsValid = json.IsValid;
        $(document).trigger("Validation", [json]);
    };
    function genericErrorCallback(response) {
        if (response.status === 400) {
            var json = JSON.parse(response.responseText);
            privateStore[me.id].IsValid = false;
            $(document).trigger("Validation", [json]);
        } else {
            $(document).trigger("Error", response);
        }
    };
    function getFilter() {
        return {
            TakeRateId: me.getOxoDocId(),
            MarketId: me.getMarketId(),
            Changeset: null
        }
    };
}

