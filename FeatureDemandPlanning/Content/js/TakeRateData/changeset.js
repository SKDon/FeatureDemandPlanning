"use strict";

var model = namespace("FeatureDemandPlanning.Volume");

model.DataChangeset = function () {
    var me = this;
    me.DocumentId = null;
    me.DataChanges = [];
};

model.DataChange = function () {
    var me = this;
    me.FdpChangesetDataItemId = null,
        me.MarketId = null,
        me.ModelIdentifier = null,
        me.FeatureIdentifier = null,
        me.Mode = 0,
        me.PercentageTakeRate = null,
        me.Volume = null,
        me.Comment = "",
        me.DerivativeCode = null;
};

model.Change = function (marketIdentifier, 
                         modelIdentifier, 
                         featureIdentifier) {
    var uid = 0;
    var privateStore = {};
    var me = this;

    privateStore[me.id = uid++] = {};
    privateStore[me.id].OriginalVolume = null;
    privateStore[me.id].OriginalTakeRate = null;
    privateStore[me.id].Comment = "";
    privateStore[me.id].ChangedVolume = null;
    privateStore[me.id].ChangedTakeRate = null;
    privateStore[me.id].MarketIdentifier = null;
    privateStore[me.id].ModelIdentifier = modelIdentifier;
    privateStore[me.id].FeatureIdentifier = featureIdentifier;
    privateStore[me.id].MarketIdentifier = marketIdentifier;
    privateStore[me.id].DerivativeCode = null;
    privateStore[me.id].Mode = "PercentageTakeRate";
    privateStore[me.id].Index = 0;
    privateStore[me.id].IsSaved = false;

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
    me.getDerivativeCode = function() {
        return privateStore[me.id].DerivativeCode;
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
    me.getMarketIdentifier = function () {
        return privateStore[me.id].MarketIdentifier;
    };
    me.getMode = function () {
        return privateStore[me.id].Mode;
    };
    me.setMode = function (mode) {
        privateStore[me.id].Mode = mode;
    };
    me.isValid = function () {
        return (me.getChangedTakeRate() == null || (me.getChangedTakeRate() >= 0 && me.getChangedTakeRate() <= 100)) &&
            (me.getChangedVolume() == null || me.getChangedVolume() >= 0)
    }
    me.isChanged = function () {
        return me.getOriginalTakeRate() != me.getChangedTakeRate() || 
            me.getOriginalVolume() != me.getChangedVolume();
    };
    me.isSaved = function () {
        return privateStore[me.id].IsSaved;
    };
    me.setSaved = function () {
        privateStore[me.id].Saved = true;
    };
    me.getIndex = function () {
        return privateStore[me.id].Index;
    };
    me.setIndex = function (index) {
        privateStore[me.id].Index = index;
    };
    me.setDerivativeCode = function(derivativeCode) {
        privateStore[me.id].DerivativeCode = derivativeCode;
    };
    me.toDataChange = function()
    {
        var dataChange = new FeatureDemandPlanning.Volume.DataChange();
        dataChange.ModelIdentifier = me.getModelIdentifier();
        dataChange.FeatureIdentifier = me.getFeatureIdentifier();
        if (me.getMode() === "Raw") {
            dataChange.Mode = 1;
        }
        else {
            dataChange.Mode = 2;
        }
        dataChange.PercentageTakeRate = me.getChangedTakeRate();
        dataChange.Volume = me.getChangedVolume();
        dataChange.MarketId = me.getMarketIdentifier();
        dataChange.DerivativeCode = me.getDerivativeCode();

        return dataChange;
    }
};
model.Changeset = function (params) {
    var uid = 0;
    var privateStore = {};
    var me = this;
    
    privateStore[me.id = uid++] = {};
    privateStore[me.id].Changes = [];
    privateStore[me.id].FdpChangesetId = null;

    me.load = function (changesetData) {
        for (var i = 0; i < changesetData.Changes.length; i++) {
            console.log(changesetData.Changes[i]);
        }
    };
    me.getChange = function (marketIdentifier, modelIdentifier, featureIdentifier, derivativeCode) {
        var retVal = null;
        for (var i = 0; i < privateStore[me.id].Changes.length; i++) {
            var currentMarketIdentifier = privateStore[me.id].Changes[i].getMarketIdentifier();
            var currentModelIdentifier = privateStore[me.id].Changes[i].getModelIdentifier();
            var currentFeatureIdentifier = privateStore[me.id].Changes[i].getFeatureIdentifier();
            var currentDerivativeCode = privateStore[me.id].Changes[i].getDerivativeCode();

            if (marketIdentifier === currentMarketIdentifier &&
                modelIdentifier === currentModelIdentifier &&
                featureIdentifier === currentFeatureIdentifier &&
                derivativeCode === currentDerivativeCode) {
                retVal = privateStore[me.id].Changes[i];
                retVal.setIndex(i);
                break;
            }
        }
        return retVal;
    };
    me.getChangeForMarket = function (marketIdentifier) {
        var retVal = null;
        for (var i = 0; i < privateStore[me.id].Changes.length; i++) {
            var currentMarketIdentifier = privateStore[me.id].Changes[i].getMarketIdentifier();

            if (marketIdentifier === currentMarketIdentifier) {
                retVal = privateStore[me.id].Changes[i];
                retVal.setIndex(i);
                break;
            }
        }
        return retVal;
    };
    me.getChangesForMarket = function (marketIdentifier) {
        var retVal = [];
        for (var i = 0; i < privateStore[me.id].Changes.length; i++) {
            var currentMarketIdentifier = privateStore[me.id].Changes[i].getMarketIdentifier();

            if (marketIdentifier === currentMarketIdentifier) {
                retVal.push(privateStore[me.id].Changes[i]);
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
    me.getChangesForDerivativeCode = function(derivativeCode) {
        var retVal = [];
        for (var i = 0; i < privateStore[me.id].Changes.length; i++) {
            var currentDerivativeCode = privateStore[me.id].Changes[i].getDerivativeCode();

            if (derivativeCode === currentDerivativeCode) {
                retVal.push(privateStore[me.id].Changes[i]);
            }
        }
        return retVal;
    };
    me.addChange = function (change) {
        for (var i = 0; i < privateStore[me.id].Changes.length; i++) {
            var currentChange = me.getChange(change.getModelIdentifier(), change.getFeatureIdentifier(), change.getDerivativeCode());
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
    me.removeChanges = function (marketIdentifier, modelIdentifier, featureIdentifier, derivativeCode) {
        // As the array indexes will change, we need to delete any changes one at a time
        var currentChange = me.getChange(marketIdentifier, modelIdentifier, featureIdentifier, derivativeCode);
        while (currentChange !== null) {
            privateStore[me.id].Changes.splice(currentChange.getIndex(), 1);
            currentChange = me.getChange(marketIdentifier, modelIdentifier, featureIdentifier, derivativeCode);
        }
    };
    me.removeChangesForMarket = function (marketIdentifier) {
        // As the array indexes will change, we need to delete any changes one at a time
        var currentChange = me.getChangeForMarket(marketIdentifier);
        while (currentChange !== null) {
            privateStore[me.id].Changes.splice(currentChange.getIndex(), 1);
            currentChange = me.getChangeForMarket(marketIdentifier);
        }
    }
    me.clear = function () {
        privateStore[me.id].Changes = [];
    };
    me.getFdpChangesetId = function () {
        return privateStore[me.id].FdpChangesetId;
    };
    me.setFdpChangesetId = function (changesetId) {
        privateStore[me.id].FdpChangesetId = changesetId;
    };
    me.getDataChanges = function () {
        // Build up a collection of the changed data and wrap in a lightweight changeset object
        var retVal = {
            Changes: [],
            Comment: ""
        };
        for (var i = 0; i < privateStore[me.id].Changes.length; i++) {
            retVal.Changes.push(privateStore[me.id].Changes[i].toDataChange());
        }
        return retVal;
    };
};