var model = namespace("FeatureDemandPlanning.FeatureCode");

model.FeatureCodeFilter = function () {
    var me = this;
    me.ProgrammeId = null;
    me.Gateway = "";
    me.DocumentId = null;
    me.FilterMessage = "";
};
model.FeatureCode = function (params) {
    var uid = 0;
    var privateStore = {};
    var me = this;

    privateStore[me.id = uid++] = {};
    privateStore[me.id].FeatureCodeUri = params.FeatureCodeUri;
    privateStore[me.id].ActionsUri = params.ActionsUri;
    privateStore[me.id].Configuration = params.Configuration;
    privateStore[me.id].ModalContentUri = params.ModalContentUri;
    privateStore[me.id].ModalActionUri = params.ModalActionUri;
    privateStore[me.id].UpdateFeatureCodeUri = params.UpdateFeatureCodeUri;
    privateStore[me.id].PageSize = params.PageSize;
    privateStore[me.id].PageIndex = params.PageIndex;
    privateStore[me.id].Parameters = params;

    me.ModelName = "FeatureCode";

    me.getActionContentUri = function (action) {
        return privateStore[me.id].ModalContentUri;
    };
    me.getActionsUri = function () {
        return privateStore[me.id].ActionsUri;
    };
    me.getActionUri = function () {
        return privateStore[me.id].ModalActionUri;
    };
    me.getConfiguration = function () {
        return privateStore[me.id].Configuration;
    };
    me.getFeatureCodeUri = function () {
        return privateStore[me.id].FeatureCodeUri;
    };
    me.getUpdateFeatureCodeUri = function() {
        return privateStore[me.id].UpdateFeatureCodeUri;
    };
    me.getIdentifierPrefix = function () {
        return $("#Page_IdentifierPrefix").val();
    };
    me.getPageSize = function () {
        return privateStore[me.id].PageSize;
    };
    me.getPageIndex = function () {
        return privateStore[me.id].PageIndex
    };
    me.getParameters = function () {
        return privateStore[me.id].Parameters;
    };
    me.initialise = function () {
    };
    me.setParameters = function (parameters) {
        privateStore[me.id].Parameters = parameters;
    };
    me.saveData = function(data, callback) {
        sendData(me.getUpdateFeatureCodeUri(), data, callback);
    };
    function sendData(uri, params, callback) {
        $.ajax({
            "dataType": "json",
            "async": true,
            "type": "POST",
            "url": uri,
            "data": params,
            "success": function (json) {
                callback(json);
            }
        });
    };
};