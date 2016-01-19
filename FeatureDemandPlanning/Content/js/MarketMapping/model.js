var model = namespace("FeatureDemandPlanning.Market");

model.MarketMappingFilter = function () {
    var me = this;
    me.ProgrammeId = null;
    me.Gateway = "";
    me.FilterMessage = "";
};
model.MarketMapping = function (params) {
    var uid = 0;
    var privateStore = {};
    var me = this;

    privateStore[me.id = uid++] = {};
    privateStore[me.id].MarketMappingsUri = params.MarketMappingsUri;
    privateStore[me.id].ActionsUri = params.ActionsUri;
    privateStore[me.id].Configuration = params.Configuration;
    privateStore[me.id].ModalContentUri = params.ModalContentUri;
    privateStore[me.id].ModalActionUri = params.ModalActionUri;
    privateStore[me.id].PageSize = params.PageSize;
    privateStore[me.id].PageIndex = params.PageIndex;
    privateStore[me.id].Parameters = params;

    me.ModelName = "MarketMapping";

    me.getActionContentUri = function (action) {
        return privateStore[me.id].ModalContentUri;
    };
    me.getActionModel = function (action) {
        var actionModel = null;

        switch (action) {
            case 1:
                actionModel = new FeatureDemandPlanning.Market.DeleteMarketMappingAction(me.getParameters());
                break;
            case 4:
                actionModel = new FeatureDemandPlanning.Market.CopyMarketMappingAction(me.getParameters());
                break;
            case 5:
                actionModel = new FeatureDemandPlanning.Market.CopyAllMarketMappingAction(me.getParameters());
                break;
            default:
                break;
        }
        return actionModel;
    };
    me.getActionTitle = function (action, marketMapping) {
        var title = "";
        switch (action) {
            case 1:
                title = "Delete Market Mappping '" + marketMapping + "'";
                break;
            case 4:
                title = "Copy Market Mapping '" + marketMapping + "' to Gateway";
                break;
            case 5:
                title = "Copy All Market Mappings '" + marketMapping + "' to Gateway";
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
    me.getMarketMappingsUri = function () {
        return privateStore[me.id].MarketMappingsUri;
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
            url: me.getMarketMappingsUri(),
            type: "GET",
            dataType: "json",
            data: filter,
            success: loadMarketsCallback,
            error: genericErrorCallback
        });
    }
    me.initialise = function () {
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
    function genericErrorCallback(response) {
        if (response.status === 200) {
            return false;
        }
        privateStore[me.id].Config = response.Configuration;
        $(document).trigger("notifyError", response);
    };
    function loadMarketsCallback(response) {
        $(document).trigger("notifyResults", response);
    };
};