"use strict";

var page = namespace("FeatureDemandPlanning.Import");

page.ExceptionsPage = function (models) {
    var uid = 0;
    var privateStore = {};
    var me = this;

    privateStore[me.id = uid++] = {};
    privateStore[me.id].DataTable = null;
    privateStore[me.id].Models = models;
    privateStore[me.id].SelectedExceptionType = "";
    privateStore[me.id].SelectedExceptionTypeId = 0;
    privateStore[me.id].ExceptionIds = [];

    me.displaySelectedExceptionType = function () {
        $("#" + me.getIdentifierPrefix() + "_SelectedExceptionType").html(me.getSelectedExceptionType());
    };
    me.getSelectedExceptionType = function () {
        return privateStore[me.id].SelectedExceptionType;
    };
    me.getSelectedExceptionTypeId = function () {
        return privateStore[me.id].SelectedExceptionTypeId;
    };
    me.exceptionTypeSelectedEventHandler = function (sender) {
        me.setSelectedExceptionTypeId(parseInt($(sender.target).attr("data-target")));
        me.setSelectedExceptionType($(sender.target).attr("data-content"));
        me.displaySelectedExceptionType();
        me.redrawDataTable();
    };
    me.setSelectedExceptionType = function (exceptionType) {
        privateStore[me.id].SelectedExceptionType = exceptionType;
    };
    me.setSelectedExceptionTypeId = function (exceptionTypeId) {
        privateStore[me.id].SelectedExceptionTypeId = exceptionTypeId;
    };
    me.initialise = function () {
        me.registerEvents();
        me.registerSubscribers();

        $(privateStore[me.id].Models).each(function () {
            this.initialise();
        });
        me.loadData();
    };
    me.setDataTable = function (dataTable) {
        privateStore[me.id].DataTable = dataTable;
    };
    me.getDataTable = function () {
        if (privateStore[me.id].DataTable == null)
        {
            me.configureDataTables();
        }
        return privateStore[me.id].DataTable;
    };
    me.getExceptionType = function () {
        return parseInt($("#ddlExceptionType").val());
    };
    me.getFilterMessage = function () {
        return $("#" + me.getIdentifierPrefix() + "_FilterMessage").val();
    };
    me.getIdentifierPrefix = function () {
        return $("#Page_IdentifierPrefix").val();
    };
    me.loadData = function () {
        me.configureDataTables(getFilter());
    };
    me.getData = function (data, callback, settings) {
        var params = me.getParameters(data);
        var model = getExceptionsModel();
        var uri = model.getExceptionsUri();
        settings.jqXHR = $.ajax({
            "dataType": "json",
            "type": "POST",
            "url": uri,
            "data": params,
            "success": function (json) {
                // Additional data not provided by the regular datatables implementation
                model.setTotalSuccessRecords(json.TotalSuccess);
                model.setTotalFailRecords(json.TotalFail);
                callback(json);
                me.updatePaging();
                me.updateTotals();
            },
            "error": function (jqXHR, textStatus, errorThrown) {
                alert(errorThrown);
            }
        });
    };
    me.getContextMenu = function (exceptionId) {
        var params = { ExceptionId: exceptionId };
        $.ajax({
            "dataType": "html",
            "async": true,
            "type": "POST",
            "url": getExceptionsModel().getActionsUri(),
            "data": params,
            "success": function (response) {
                $("#contextMenu").html(response);
            },
            "error": function (jqXHR, textStatus, errorThrown) {
                alert(errorThrown);
            }
        });
    };
    me.getParameters = function (data) {
        var filter = getFilter();
        var params = $.extend({}, data, {
            "ImportQueueId": filter.ImportQueueId,
            "ExceptionType": filter.ExceptionType,
            "FilterMessage": filter.FilterMessage,
            "ProgrammeId": filter.ProgrammeId,
            "Gateway": filter.Gateway
        });
        return params;
    };
    me.configureDataTables = function (filter) {
        var prefix = me.getIdentifierPrefix();
        var table = $("#tblImportExceptions").DataTable({
            "serverSide": true,
            "pagingType": "full_numbers",
            "processing": true,
            "ajax": me.getData,
            "sDom": "ltp",
            "columnDefs": [
            {
                "targets": 0,
                "searchable": false,
                "orderable": false,
                "className": "checkbox-column",
                "render": function(data, type, full, meta) {
                    return '<input type="checkbox" class="selected-item" value="' + $('<div/>').text(data).html() + '">';
                },
                "width": "10%"
            },
            {
                "targets": 1,
                "visible": false
            },
            {
                "targets": 4,
                "className": "text-center"
            }],
            "fnCreatedRow": function (row, data, index) {
                var importExceptionId = data[0];
                $(row).attr("data-import-exception-id", importExceptionId);
            },
            "fnDrawCallback": function (oSettings) {
                $(document).trigger("Results", me.getSummary());
                me.bindContextMenu();
                $("#pnlImportExceptions").show();
            }
        });

        // Handle click on "Select all" control
        $("#" + prefix + "_SelectAll").unbind("click").on("click", function () {
            var rows = table.rows({ "search": "applied" }).nodes();
            var checkboxes = $('input[type="checkbox"]', rows).prop("checked", this.checked);

            privateStore[me.id].ExceptionIds = [];
            if (this.checked) {
                $(checkboxes).each(function() {
                    privateStore[me.id].ExceptionIds.push($(this).val());
                });
            }

            if (privateStore[me.id].ExceptionIds.length === 0) {
                $("#" + prefix + "_IgnoreAll").html("Ignore Selected").attr("disabled", "disabled");
            } else {
                $("#" + prefix + "_IgnoreAll").html("Ignore " + privateStore[me.id].ExceptionIds.length + " Exception(s)").removeAttr("disabled");
            }
        });

        // Handle click on checkbox to set state of "Select all" control
        $("#tblImportExceptions tbody").on("change", 'input[type="checkbox"]', function () {
            // If checkbox is not checked
            if (!this.checked) {
                var el = $("#" + prefix + "_SelectAll").get(0);
                // If "Select all" control is checked and has 'indeterminate' property
                if (el && el.checked && ('indeterminate' in el)) {
                    // Set visual state of "Select all" control 
                    // as 'indeterminate'
                    el.indeterminate = true;
                }
            }

            // Get all rows with search applied
            var rows = table.rows({ "search": "applied" }).nodes();
            // Check/uncheck checkboxes for all rows in the table
            var checkboxes = $('input[type="checkbox"]', rows);
            privateStore[me.id].ExceptionIds = [];
            $(checkboxes).each(function () {
                if (this.checked) {
                    privateStore[me.id].ExceptionIds.push($(this).val());
                }
            });

            if (privateStore[me.id].ExceptionIds.length === 0) {
                $("#" + prefix + "_IgnoreAll").html("Ignore Selected").attr("disabled", "disabled");
            } else {
                $("#" + prefix + "_IgnoreAll").html("Ignore " + privateStore[me.id].ExceptionIds.length + " Exception(s)").removeAttr("disabled");
            }
        });

        $("#" + prefix + "_IgnoreAll").unbind("click").on("click", function () {
            var params = $.extend({}, me.getParameters(), {
                "Action": 14, // Ignore all
                "ExceptionId": 0,
                "ExceptionIds": privateStore[me.id].ExceptionIds,
                "ProgrammeId": 0,
                "Gateway": "None"
            });
            $(document).trigger("Action", params);
        });
    };
    me.getExceptionId = function (cell) {
        return $(cell).closest("tr").attr("data-import-exception-id");
    };
    me.bindContextMenu = function () {
        $("#tblImportExceptions td").contextMenu({
            menuSelector: "#contextMenu",
            dynamicContent: me.getContextMenu,
            contentIdentifier: me.getExceptionId,
            menuSelected: me.actionTriggered
        });
    };
    me.getSummary = function () {
        var params = me.getParameters({});
        $.ajax({
            "dataType": "html",
            "async": true,
            "type": "GET",
            "url": getExceptionsModel().getSummaryUri(),
            "data": params,
            "success": function (response) {
                $("#" + me.getIdentifierPrefix() + "_ImportSummary").html(response);
            },
            "error": function (jqXHR, textStatus, errorThrown) {
                alert(errorThrown);
            }
        });
    };
    me.registerEvents = function () {
        var prefix = me.getIdentifierPrefix();
        $(document)
            .unbind("Success").on("Success", function (sender, eventArgs) { $(".subscribers-notify").trigger("OnSuccessDelegate", [eventArgs]); })
            .unbind("Error").on("Error", function (sender, eventArgs) { $(".subscribers-notify").trigger("OnErrorDelegate", [eventArgs]); })
            .unbind("Results").on("Results", function (sender, eventArgs) { $(".subscribers-notify").trigger("OnResultsDelegate", [eventArgs]); })
            .unbind("Updated").on("Updated", function (sender, eventArgs) { $(".subscribers-notify").trigger("OnUpdatedDelegate", [eventArgs]); })
            .unbind("Action").on("Action", function (sender, eventArgs) { $(".subscribers-notify").trigger("OnActionDelegate", [eventArgs]); })
            .unbind("ModalLoaded").on("ModalLoaded", function (sender, eventArgs) { $(".subscribers-notify").trigger("OnModalLoadedDelegate", [eventArgs]); })
            .unbind("ModalOk").on("ModalOk", function (sender, eventArgs) { $(".subscribers-notify").trigger("OnModalOkDelegate", [eventArgs]); });

        $("#" + prefix + "_ExceptionTypeList").find("a.type-item").on("click", function (e) {
            me.exceptionTypeSelectedEventHandler(e);
            e.preventDefault();
        });
    };
    me.registerSubscribers = function () {
        var prefix = me.getIdentifierPrefix();
        $("#notifier")
            .unbind("OnSuccessDelegate").on("OnSuccessDelegate", me.onSuccessEventHandler)
            .unbind("OnErrorDelegate").on("OnErrorDelegate", me.onErrorEventHandler)
            .unbind("OnUpdatedDelegate").on("OnUpdatedDelegate", me.onUpdatedEventHandler)
            .unbind("OnFilterCompleteDelegate").on("OnFilterCompleteDelegate", me.onFilterCompleteEventHandler)
            .unbind("OnActionDelegate").on("OnActionDelegate", me.onActionEventHandler);

        $("#dvImportSummary").on("OnResultsDelegate", me.onImportSummaryEventHandler);
        $("#spnFilteredRecords").on("OnResultsDelegate", me.onFilteredRecordsEventHandler);
        $("#dvFilter").on("FilterCompleteEventHandler", me.onFilterCompleteEventHandler);
        $("#ddlExceptionType").on("change", me.onFilterChangedEventHandler);
        $("#" + prefix + "_FilterMessage").on("keyup", function (sender, eventArgs) {
            var length = $("#" + prefix + "_FilterMessage").val().length;
            if (length == 0 || length > 2) {
                me.onFilterChangedEventHandler(sender, eventArgs);
            }
        });
    };
    me.onSuccessEventHandler = function (sender, eventArgs) {
        me.redrawDataTable();
    };
    me.onErrorEventHandler = function (sender, eventArgs) {
    };
    me.onUpdatedEventHandler = function (sender, eventArgs) {
    };
    me.onResultsEventHandler = function (sender, eventArgs) {
    };
    me.onImportSummaryEventHandler = function (sender, eventArgs) {
        me.getSummary();
    };
    me.onFilteredRecordsEventHandler = function (sender, eventArgs) {
        var summary = eventArgs;
        if (summary.getTotalRecords() > 0) {
            $("#spnFilteredRecords").html("Page " + (summary.getPageIndex() + 1) + " of " + summary.getTotalPages() + " (" + summary.getTotalRecords() + " total records)");
        }
    };
    me.onFilterChangedEventHandler = function (sender, eventArgs) {
        me.redrawDataTable();
    };
    me.actionTriggered = function (invokedOn, action) {
        var eventArgs = {
            ExceptionId: parseInt($(this).attr("data-target")),
            Action: parseInt($(this).attr("data-role")),
            DocumentId: getExceptionsModel().getDocumentId(),
            ProgrammeId: getExceptionsModel().getProgrammeId(),
            Gateway: getExceptionsModel().getGateway(),
            ErrorMessage: $(this).attr("data-content")
        };
        $(document).trigger("Action", eventArgs);
    };
    me.onActionEventHandler = function (sender, eventArgs) {
        var action = eventArgs.Action;
        var model = getModelForExceptionTypeAndAction(action);
        var actionModel = model.getActionModel(action);

        getModal().showModal({
            Title: model.getActionTitle(action),
            Uri: model.getActionContentUri(action),
            Data: JSON.stringify(eventArgs),
            Model: model,
            ActionModel: actionModel
        });
    };
    me.onActionCallback = function (response) {
        me.redrawDataTable();
    };
    me.redrawDataTable = function () {
        var prefix = me.getIdentifierPrefix();
        $("#tblImportExceptions").DataTable().draw();
        $("#" + prefix + "_IgnoreAll").html("Ignore Selected").attr("disabled", "disabled");
        $("#" + prefix + "_SelectAll").prop("checked", false);
    };
    
    // TO DO move this to the market.js file
    me.initialiseMapMarketModal = function () {
        var selector = $("#txtMapMarketName").typeahead({
            source: getMarketModel().getAvailableMarkets(),
            minLength: 1,
            items: 10
        });
    };
    me.updatePaging = function () {
        var info = $("#tblImportExceptions").DataTable().page.info();
        var pageIndex = info.page + 1;
        var totalPages = info.pages;
        $(".results-paging").html("Page " + pageIndex + " of " + totalPages);
    };
    me.updateTotals = function () {
        var info = $("#tblImportExceptions").DataTable().page.info();
        var prefix = me.getIdentifierPrefix();
        var total = info.recordsTotal;
        $(".results-total").html(total + " Exceptions");
    }
    function getModal() {
        return getModel("Modal");
    };
    function getModels() {
        return privateStore[me.id].Models;
    };
    function getModel(modelName) {
        var model = null;
        $(getModels()).each(function () {
            if (this.ModelName == modelName) {
                model = this;
                return false;
            }
        });
        return model;
    };
    function getExceptionsModel() {
        return getModel("Exceptions");
    };
    function getMarketModel() {
        return getModel("Market");
    };
    function getDerivativeModel() {
        return getModel("Derivative");
    }
    function getTrimModel() {
        return getModel("Trim");
    }
    function getFeatureModel() {
        return getModel("Feature");
    }
    function getIgnoreModel() {
        return getModel("Ignore");
    }
    function getModelForExceptionTypeAndAction(actionId) {
        var model = null;
        switch (actionId) {
            case 1:
                model = getMarketModel();
                break;
            case 2:
            case 3:
                model = getDerivativeModel();
                break;
            case 4:
            case 5:
                model = getFeatureModel();
                break;
            case 6:
            case 7:
                model = getTrimModel();
                break;
            case 8:
                model = getIgnoreModel();
                break;
            case 9:
                model = getFeatureModel();
                break;
            case 13:
                model = getDerivativeModel();
                break;
            case 14:
                model = getIgnoreModel();
                break;
            case 15:
                model = getTrimModel();
                break;
            case 16:
                model = getFeatureModel();
                break;
            default:
                break;
        };
        return model;
    }
    function getFilter() {
        var model = getExceptionsModel();
        var pageSize = model.getPageSize();
        var pageIndex = model.getPageIndex();
        var filter = new FeatureDemandPlanning.Import.ExceptionsFilter();

        filter.ImportQueueId = model.getImportQueueId();
        filter.ExceptionType = me.getSelectedExceptionTypeId();
        filter.FilterMessage = me.getFilterMessage();
        filter.PageIndex = pageIndex;
        filter.PageSize = pageSize;

        return filter;
    }
}