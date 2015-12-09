"use strict";

var model = namespace("FeatureDemandPlanning.Volume");

model.Change = function (modelIdentifier, featureIdentifier) {
    var uid = 0;
    var privateStore = {};
    var me = this;

    privateStore[me.id = uid++] = {};
    privateStore[me.id].OriginalVolume = null;
    privateStore[me.id].OriginalTakeRate = null;
    privateStore[me.id].Comment = "";
    privateStore[me.id].ChangedVolume = null;
    privateStore[me.id].ChangedTakeRate = null;
    privateStore[me.id].ModelIdentifier = modelIdentifier;
    privateStore[me.id].FeatureIdentifier = featureIdentifier;
    privateStore[me.id].Mode = "PercentageTakeRate";
    privateStore[me.id].Index = 0;

    me.getOriginalVolume = function () {
        return privateStore[me.id].OriginalVolume;
    };
    me.setOriginalVolume = function (originalVolume) {
        privateStore[me.id].OriginalVolume = originalVolume
    };
    me.getOriginalTakeRate = function () {
        return privateStore[me.id].OriginalTakeRate;
    };
    me.setOriginalTakeRate = function (originalTakeRate) {
        privateStore[me.id].OriginalTakeRate = originalTakeRate;
    };
    me.getChangedVolume = function () {
        return privateStore[me.id].ChangedVolume;
    };
    me.setChangedVolume = function (changedVolume) {
        privateStore[me.id].ChangedVolume = changedVolume;
    };
    me.getChangedTakeRate = function () {
        return privateStore[me.id].ChangedTakeRate;
    };
    me.setChangedTakeRate = function (changedTakeRate) {
        privateStore[me.id].ChangedTakeRate = changedTakeRate;
    };
    me.getComment = function () {
        return privateStore[me.id].Comment;
    };
    me.setComment = function (comment) {
        privateStore[me.id].Comment = comment;
    };
    me.getModelIdentifier = function () {
        return privateStore[me.id].ModelIdentifier;
    };
    me.getFeatureIdentifier = function () {
        return privateStore[me.id].FeatureIdentifier;
    };
    me.getMode = function () {
        return privateStore[me.id].Mode;
    };
    me.setModel = function (mode) {
        privateStore[me.id].Model = mode;
    };
    me.isValid = function () {
        return (me.getChangedTakeRate() == null || (me.getChangedTakeRate() >= 0 && me.getChangedTakeRate() <= 100)) &&
            (me.getChangedVolume() == null || me.getChangedVolume() >= 0)
    }
    me.isChanged = function () {
        return me.getOriginalTakeRate() != me.getChangedTakeRate() || 
            me.getOriginalVolume() != me.getChangedVolume();
    };
    me.getIndex = function () {
        return privateStore[me.id].Index;
    };
    me.setIndex = function (index) {
        privateStore[me.id].Index = index;
    }
};
model.Changeset = function (params) {
    var uid = 0;
    var privateStore = {};
    var me = this;
    
    privateStore[me.id = uid++] = {};
    privateStore[me.id].Changes = [];

    me.getChange = function (modelIdentifier, featureIdentifier) {
        var retVal = null;
        for (var i = 0; i < privateStore[me.id].Changes.length; i++) {
            var currentModelIdentifier = privateStore[me.id].Changes[i].getModelIdentifier();
            var currentFeatureIdentifier = privateStore[me.id].Changes[i].getFeatureIdentifier();

            if (modelIdentifier === currentModelIdentifier && featureIdentifier === currentFeatureIdentifier) {
                retVal = privateStore[me.id].Changes[i];
                retVal.setIndex(i);
                break;
            }
        }
        return retVal;
    };
    me.getChangesForFeature = function (featureIdentifier) {
        var retVal = [];
        for (var i = 0; i < privateStore[me.id].Changes.length; i++) {
            var currentFeatureIdentifier = privateStore[me.id].Changes[i].getFeatureIdentifier();

            if (featureIdentifier === currentFeatureIdentifier) {
                retVal.push(privateStore[me.id].Changes[i]);
            }
        }
        return retVal;
    };
    me.getChangesForModel = function (modelIdentifier) {
        var retVal = [];
        for (var i = 0; i < privateStore[me.id].Changes.length; i++) {
            var currentModelIdentifier = privateStore[me.id].Changes[i].getModelIdentifier();

            if (modelIdentifier === currentModelIdentifier) {
                retVal.push(privateStore[me.id].Changes[i]);
            }
        }
        return retVal;
    };
    me.addChange = function (change) {
        for (var i = 0; i < privateStore[me.id].Changes.length; i++) {
            var currentChange = me.getChange(change.getModelIdentifier(), change.getFeatureIdentifier())
            // If the change exists, overwrite it, but preserve the original value
            if (currentChange !== null) {
                privateStore[me.id].Changes[i].setChangedVolume(change.getChangedVolume());
                privateStore[me.id].Changes[i].setChangedTakeRate(change.getChangedTakeRate());
                privateStore[me.id].Changes[i].setComment(change.getComment());

                return;
            }
        }
        privateStore[me.id].Changes.push(change);
    };
    me.removeChanges = function (modelIdentifier, featureIdentifier) {
        // As the array indexes will change, we need to delete any changes one at a time
        var currentChange = me.getChange(modelIdentifier, featureIdentifier);
        while (currentChange !== null) {
            privateStore[me.id].Changes.splice(currentChange.getIndex(), 1);
            currentChange = me.getChange(modelIdentifier, featureIdentifier);
        }
    };
    me.clear = function () {
        privateStore[me.id].Changes = [];
    };
};