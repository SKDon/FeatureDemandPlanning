"use strict";

var model = namespace("FeatureDemandPlanning.Volume");

model.OxoVolume = function (params) {
    var uid = 0;
    var privateStore = {};
    var me = this;

    privateStore[me.id = uid++] = {};
    privateStore[me.id].OxoDocId = params.OxoDocId;
    privateStore[me.id].Vehicle = params.Vehicle;
    privateStore[me.id].Config = params.Configuration;
    privateStore[me.id].EditVolumeUri = params.EditVolumeUri;
    privateStore[me.id].SaveVolumeUri = params.SaveVolumeUri;
    privateStore[me.id].AvailableDocumentsUri = params.AvailableDocumentsUri;
    privateStore[me.id].AvailableImportsUri = params.AvailableImportsUri;
    privateStore[me.id].ValidateUri = params.ValidateUri;
    privateStore[me.id].ValidationMessageUri = params.ValidationMessageUri;
    privateStore[me.id].IsValid = true;
    privateStore[me.id].FdpVolumeHeaders = [];
    privateStore[me.id].CurrentEditValue = null;

    me.ModelName = "OxoVolume";

    me.initialise = function () {
        var me = this;
        $(document).trigger("notifySuccess", me);
    };
    me.getOxoDocId = function () {
        return privateStore[me.id].OxoDocId;
    };
    me.getVehicle = function () {
        return privateStore[me.id].Vehicle;
    }
    me.getConfiguration = function () {
        return privateStore[me.id].Configuration;
    };
    me.getAvailableDocumentsUri = function () {
        return privateStore[me.id].AvailableDocumentsUri;
    };
    me.getAvailableImportsUri = function () {
        return privateStore[me.id].AvailableImportsUri;
    };
    me.getEditVolumeUri = function () {
        return privateStore[me.id].EditVolumeUri;
    };
    me.getSaveVolumeUri = function () {
        return privateStore[me.id].SaveVolumeUri;
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
    me.getAvailableDocuments = function (callback) {
        var volume = me.getVolume();
        var encodedVolume = JSON.stringify(volume);

        $.ajax({
            type: "POST",
            url: me.getAvailableDocumentsUri(),
            data: encodedVolume,
            context: this,
            contentType: "application/json",
            success: function (response) {
                callback.call(this, response);
            },
            error: function (response) {
                alert(response.responseText);
            },
            async: true
        });
    };
    me.getAvailableImports = function (callback) {
        var volume = me.getVolume();
        var encodedVolume = JSON.stringify(volume);

        $.ajax({
            type: "POST",
            url: me.getAvailableImportsUri(),
            data: encodedVolume,
            context: this,
            contentType: "application/json",
            success: function (response) {
                callback.call(this, response);
            },
            error: function (response) {
                alert(response.responseText);
            },
            async: true
        });
    };
    me.saveVolume = function (changesToSave) {
        var params = {
            TakeRateId: me.getOxoDocId(),
            Changes: changesToSave
        };
        $.ajax({
            "dataType": "json",
            "async": true,
            "type": "POST",
            "url": me.getSaveVolumeUri(),
            "data": params,
            "success": function (json) {
                $(document).trigger("Success", json);
            },
            "error": function (jqXHR, textStatus, errorThrown) {
                $(document).trigger("Error", JSON.parse(jqXHR.responseText));
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
            if (this.FdpVolumeHeaderId == fdpVolumeHeaderId) {
                return false;
            }
            i++;
        });
        me.getFdpVolumeHeaders().splice(i, 1);
    };
    me.hasFdpVolumeHeader = function (fdpVolumeHeaderId) {
        var exists = false;
        $(me.getFdpVolumeHeaders()).each(function () {
            if (this.FdpVolumeHeaderId == fdpVolumeHeaderId) {
                exists = true;
                return false;
            }
        });
        return exists;
    };
    function loadVolumeCallback(response) {
        $(document).trigger("Results", response);
    };
    function saveVolumeCallback(response) {
        $(document).trigger("Updated", response);
    };
    function validateVolumeCallback(response) {
        var json = JSON.parse(response.responseText);
        privateStore[me.id].IsValid = json.IsValid;
        $(document).trigger("Validation", [json]);
    };
    function genericErrorCallback(response) {
        if (response.status == 400) {
            var json = JSON.parse(response.responseText);
            privateStore[me.id].IsValid = false;
            $(document).trigger("Validation", [json]);
        } else {
            $(document).trigger("Error", response);
        }
    };
}

