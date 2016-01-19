function namespace(namespaceString)
{
    var parts = namespaceString.split("."),
        parent = window,
        currentPart = "";    
        
    for(var i=0,length=parts.length;i<length; i++) {
        currentPart = parts[i];
        parent[currentPart] = parent[currentPart] || {};
        parent = parent[currentPart];
    }
    
    return parent;
}

var model = namespace("FeatureDemandPlanning.Model");

model.Markets = function (params) {
    /* Private members */

    var uid = 0;
    var privateStore = {};
    var me = this;

    /* Constructor */
    privateStore[me.id = uid++] = {};
    privateStore[me.id].AvailableMarkets = params.AvailableMarkets;
    privateStore[me.id].TopMarkets = params.TopMarkets;
    privateStore[me.id].MarketsUri = params.MarketsUri;
    privateStore[me.id].TopMarketsUri = params.TopMarketsUri;
    privateStore[me.id].DeleteUri = params.DeleteUri;
    privateStore[me.id].AddUri = params.AddUri;
    privateStore[me.id].Configuration = params.Configuration;
    privateStore[me.id].Config = {};

    me.getTopMarketsUri = function () {
        return privateStore[me.id].TopMarketsUri;
    }

    me.getAvailableMarkets = function () {
        return privateStore[me.id].Markets.AvailableMarkets;
    };

    me.getTopMarkets = function () {
        return privateStore[me.id].Markets.TopMarkets;
    };

    me.addMarket = function (marketId) {
        var me = this;
        $.ajax({
            url: privateStore[me.id].AddUri,
            type: "POST",
            dataType: "json",
            data: { marketId: marketId },
            success: genericSuccessCallback,
            error: genericErrorCallback
        });
    };

    me.deleteMarket = function (marketId) {
        var me = this;
        $.ajax({
            url: privateStore[me.id].DeleteUri,
            type: "POST",
            dataType: "json",
            data: { marketId: marketId },
            success: genericSuccessCallback,
            error: genericErrorCallback
        });
    };

    me.initialise = function () {
        var me = this;
        $(document).trigger("notifySuccess", me);
    };

    function getConfiguration() {
        $.ajax({
            url: privateStore[me.id].ConfigurationUri,
            type: "POST",
            dataType: "json",
            success: genericSuccessCallback,
            error: genericErrorCallback
        });
    };

    function getMarkets() {
        $.ajax({
            url: privateStore[me.id].MarketsUri,
            type: "POST",
            dataType: "json",
            data: "",
            success: genericSuccessCallback,
            error: genericErrorCallback
        });
    };

    function genericSuccessCallback(response) {
        privateStore[me.id].Config = response.Configuration;
        privateStore[me.id].AvailableMarkets = response.AvailableMarkets;
        privateStore[me.id].TopMarkets = response.TopMarkets;
        $(document).trigger("notifySuccess", response);
    };

    function genericErrorCallback(response) {
        if (response.status === 200) {
            return false;
        }
        privateStore[me.id].Config = response.Configuration;
        privateStore[me.id].AvailableMarkets = response.AvailableMarkets;
        privateStore[me.id].TopMarkets = response.TopMarkets;
        $(document).trigger("notifyError", response);
    };
};

$(document).ready(function () {

    $(document).on("notifySuccess", function (sender, eventArgs) {
        var subscribers = $(".subscribers-notifySuccess");
        subscribers.trigger("notifySuccessEventHandler", [eventArgs]);
    });

    $(document).on("notifyError", function (sender, eventArgs) {
        var subscribers = $(".subscribers-notifyError");
        subscribers.trigger("notifyErrorEventHandler", [eventArgs]);
    });

    $("#numberOfMarkets").on("notifySuccessEventHandler", function (sender, eventArgs) {

        var notifier = $("#numberOfMarkets");
        notifier.html(eventArgs.TopMarkets.length);

    });

    $("#notifier").on("notifySuccessEventHandler", function (sender, eventArgs) {

        var notifier = $("#notifier");
        
        switch (eventArgs.StatusCode) {
            case "Success":
                notifier.html("<div class=\"alert alert-dismissible alert-success\">" + eventArgs.StatusMessage + "</div>");
                break;
            case "Warning":
                notifier.html("<div class=\"alert alert-dismissible alert-warning\">" + eventArgs.StatusMessage + "</div>");
                break;
            case "Failure":
                notifier.html("<div class=\"alert alert-dismissible alert-danger\">" + eventArgs.StatusMessage + "</div>");
                break;
            case "Information":
                notifier.html("<div class=\"alert alert-dismissible alert-info\">" + eventArgs.StatusMessage + "</div>");
                break;
            default:
                break;
        }

        $.ajax({
            url: markets.getTopMarketsUri(),
            type: "GET",
            cache: false,
            success: function (data) {
                $("#dvTopMarkets").html(data);
            }
        });

        //dvTopMarkets.load(markets.getTopMarketsUri());

        var availableMarkets = $("#ddlAddMarket");
        availableMarkets.empty();
        $(eventArgs.AvailableMarkets).each(function () {
            $("<option />", {
                val: this.Id,
                text: this.Name
            }).appendTo(availableMarkets);
        });
        
        //return true;
    });

    $("#notifier").on("notifyErrorEventHandler", function (sender, eventArgs) {

        var notifier = $("#notifier");

        notifier.html("<div class=\"alert alert-dismissible alert-danger\">" + eventArgs.statusText + "</div>");

        return true;
    });

    $("#btnAddMarket").click(function () {

        var marketId = $("#ddlAddMarket").val();
        markets.addMarket(marketId);

        return false;
    });

});


