var model = namespace("FeatureDemandPlanning.User");

model.UserFilter = function () {
    var me = this;
    me.CDSId = "";
    me.FilterMessage = "";
    me.HideInactiveUsers = true;
};
model.User = function (params) {
    var uid = 0;
    var privateStore = {};
    var me = this;

    privateStore[me.id = uid++] = {};
    privateStore[me.id].UsersUri = params.UsersUri;
    privateStore[me.id].ActionsUri = params.ActionsUri;
    privateStore[me.id].Configuration = params.Configuration;
    privateStore[me.id].ModalContentUri = params.ModalContentUri;
    privateStore[me.id].ModalActionUri = params.ModalActionUri;
    privateStore[me.id].PageSize = params.PageSize;
    privateStore[me.id].PageIndex = params.PageIndex;
    privateStore[me.id].Parameters = params;

    me.ModelName = "User";

    me.getActionContentUri = function (action) {
        return privateStore[me.id].ModalContentUri;
    };
    me.getActionModel = function (action) {
        var actionModel = null;

        switch (action) {
            case 1:
                actionModel = new FeatureDemandPlanning.User.EnableUserAction(me.getParameters());
                break;
            case 2:
                actionModel = new FeatureDemandPlanning.User.DisableUserAction(me.getParameters());
                break;
            case 3:
                actionModel = new FeatureDemandPlanning.User.ManageProgrammesAction(me.getParameters());
                break;
            case 4:
                actionModel = new FeatureDemandPlanning.User.AddNewUserAction(me.getParameters());
                break;
            case 7:
                actionModel = new FeatureDemandPlanning.User.UnsetAdministratorAction(me.getParameters());
                break;
            case 8:
                actionModel = new FeatureDemandPlanning.User.SetAdministratorAction(me.getParameters());
                break;
            default:
                break;
        }
        return actionModel;
    };
    me.getActionTitle = function (action, cdsId) {
        var title = "";
        switch (action) {
            case 1:
                title = "Enable User '" + cdsId + "'";
                break;
            case 2:
                title = "Disable User '" + cdsId + "'";
                break;
            case 3:
                title = "Manage Programmes for '" + cdsId + "'";
                break;
            case 4:
                title = "Add New User";
                break;
            case 7:
                title: "Set '" + cdsId + "' as Administrator";
                break;
            case 8:
                title: "Unset '" + cdsId + "' as Administrator";
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
    me.getPageSize = function () {
        return privateStore[me.id].PageSize;
    };
    me.getPageIndex = function () {
        return privateStore[me.id].PageIndex;
    };
    me.getParameters = function () {
        return privateStore[me.id].Parameters;
    };
    me.getUsersUri = function () {
        return privateStore[me.id].UsersUri;
    };
    me.loadUsers = function () {
        $.ajax({
            url: me.getUsersUri(),
            type: "GET",
            dataType: "json",
            data: filter,
            success: loadUsersCallback,
            error: genericErrorCallback
        });
    }
    me.initialise = function () {
        var me = this;
        $(document).trigger("notifySuccess", me);
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
                callback(json);
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
    function loadUsersCallback(response) {
        $(document).trigger("notifyResults", response);
    };
};