"use strict";

var model = namespace("FeatureDemandPlanning.Volume");

model.ValidationResult = function () {
    var me = this;
    me.MarketId = null,
    me.ModelIdentifier = null,
    me.FeatureIdentifier = null,
    me.Message = null
};