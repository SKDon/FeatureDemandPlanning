var model = namespace("FeatureDemandPlanning.Bmc");

model.BrochureModelCodeFilter = function () {
    var me = this;
    me.ProgrammeId = null;
    me.Gateway = "";
    me.DocumentId = null;
    me.FilterMessage = "";
};
model.BrochureModelCode = function (params) {
    var uid = 0;
    var privateStore = {};
    var me = this;

    privateStore[me.id = uid++] = {};
    privateStore[me.id].BmcUri = params.BmcUri;
    privateStore[me.id].ActionsUri = params.ActionsUri;
    privateStore[me.id].Configuration = params.Configuration;
    privateStore[me.id].ModalContentUri = params.ModalContentUri;
    privateStore[me.id].ModalActionUri = params.ModalActionUri;
    privateStore[me.id].UpdateBrochureModelCodeUri = params.UpdateBrochureModelCodeUri;
    privateStore[me.id].PageSize = params.PageSize;
    privateStore[me.id].PageIndex = params.PageIndex;
    privateStore[me.id].Parameters = params;

    me.ModelName = "Bmc";

    me.getActionContentUri = function (action) {
        return privateStore[me.id].ModalContentUri;
    };
    me.getActionModel = function (action) {
        var actionModel = null;

        switch (action) {
            case 1:
                actionModel = new FeatureDemandPlanning.Derivative.DeleteDerivativeMappingAction(me.getParameters());
                break;
            case 4:
                actionModel = new FeatureDemandPlanning.Derivative.CopyDerivativeMappingAction(me.getParameters());
                break;
            case 5:
                actionModel = new FeatureDemandPlanning.Derivative.CopyAllDerivativeMappingAction(me.getParameters());
                break;
            default:
                break;
        }
        return actionModel;
    };
    me.getActionTitle = function (action, derivativeMapping) {
        var title = "";
        switch (action) {
            case 1:
                title = "Delete Derivative Mapping '" + derivativeMapping + "'";
                break;
            case 4:
                title = "Copy Derivative Mapping '" + derivativeMapping + "' to Gateway";
                break;
            case 5:
                title = "Copy All Derivative Mappings '" + derivativeMapping + "' to Gateway";
                break;
            default:
                break;
        }
        return title;
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
    me.getBmcUri = function () {
        return privateStore[me.id].BmcUri;
    };
    me.getUpdateBrochureModelCodeUri = function() {
        return privateStore[me.id].UpdateBrochureModelCodeUri;
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
    me.loadUsers = function () {
        $.ajax({
            url: me.getDerivativeMappingsUri(),
            type: "GET",
            dataType: "json",
            data: filter,
            success: loadDerivativesCallback,
            error: genericErrorCallback
        });
    }
    me.initialise = function () {
    };
    me.setParameters = function (parameters) {
        privateStore[me.id].Parameters = parameters;
    };
    me.saveData = function(data, callback) {
        sendData(me.getUpdateBrochureModelCodeUri(), data, callback);
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
            },
            "error": function (jqXhr) {
                $(document).trigger("Error", JSON.parse(jqXhr.responseText));
            }
        });
    };
    function genericErrorCallback(response) {
        if (response.status === 200) {
            return false;
        }
        privateStore[me.id].Config = response.Configuration;
        $(document).trigger("notifyError", response);
    };
    function loadDerivativesCallback(response) {
        $(document).trigger("notifyResults", response);
    };
};