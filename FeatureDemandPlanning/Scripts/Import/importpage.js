"use strict";

var page = namespace("FeatureDemandPlanning.Import.Page");

page.Page = function (models) {
    var uid = 0;
    var privateStore = {};
    var me = this;

    privateStore[me.id = uid++] = {};
    privateStore[me.id].Models = models;

    me.initialise = function () {
        me.registerEvents();
        me.registerSubscribers();
        me.configureDataTables();

        $(privateStore[me.id].Models).each(function () {
            this.initialise(me.initialiseCallback);
        });
    }

    me.initialiseCallback = function () {

        var models = getModels();
        $(models).each(function () {

            if (this.getPageSize !== undefined &&
                this.getPageIndex !== undefined &&
                this.filterResults !== undefined) {
                var pageSize = this.getPageSize();
                var pageIndex = this.getPageIndex();
                var filter = getFilter(pageSize, pageIndex);

                this.filterResults(filter);

                return false;
            }
        });
    };

    me.configureDataTables = function () {

        var tblImportQueue = $("#tblImportQueue");
        var processUri = "";
        var cancelUri = "";
        var importQueueUri = "";
        $(privateStore[me.id].Models).each(function () {
            if (this.getProcessUri != undefined) {
                processUri = this.getProcessUri();
                cancelUri = this.getCancelUri();
                importQueueUri = this.getImportQueueUri();
            }
        });

        var dt = tblImportQueue.DataTable({
            "bServerSide": true,
            "sAjaxSource": importQueueUri,
            "bProcessing": true,
            "iDisplayLength": 10,
            "sDom": "ltip",
            "aoColumns": [
                {
                    "sTitle": "Uploaded On",
                    "sName": "UPLOADED_ON",
                    "bSearchable": true,
                    "bSortable": true
                },
                {
                    "sTitle": "Uploaded By",
                    "sName": "UPLOADED_BY",
                    "bSearchable": true,
                    "bSortable": true
                },
                {
                    "sTitle": "File Path",
                    "sName": "FILE_PATH",
                    "bSearchable": true,
                    "bSortable": true
                },
                {
                    "sTitle": "Status",
                    "sName": "STATUS",
                    "bSearchable": true,
                    "bSortable": true
                },
                {
                    "sTitle": "Action",
                    "sName": "ACTION",
                    "bSearchable": false,
                    "bSortable": false
                }
            ],
            "createdRow": function (row, data, index) {
                // Don't like hard-coding indexes in this way. Must be a better way
                var importQueueId = data[0];

                $(row).attr("data-importQueueId", importQueueId);
            }
        });
    }

    me.registerEvents = function () {
        $(document).on("notifySuccess", function (sender, eventArgs) {
            var subscribers = $(".subscribers-notifySuccess");
            subscribers.trigger("notifySuccessEventHandler", [eventArgs]);
        });

        $(document).on("notifyError", function (sender, eventArgs) {
            var subscribers = $(".subscribers-notifyError");
            subscribers.trigger("notifyErrorEventHandler", [eventArgs]);
        });

        $(document).on("notifyResults", function (sender, eventArgs) {
            var subscribers = $(".subscribers-notifyResults");
            subscribers.trigger("notifyResultsEventHandler", [eventArgs]);
        });

        $(document).on("notifyProcessed", function (sender, eventArgs) {
            var subscribers = $(".subscribers-notifyProcessed");
            subscribers.trigger("notifyProcessedEventHandler", [eventArgs]);
        })

        $(document).on("notifyFilterComplete", function (sender, eventArgs) {
            var subscribers = $(".subscribers-notifyFilterComplete");
            subscribers.trigger("notifyFilterCompleteEventHandler", [eventArgs]);
        });

        $("#uploadForm").submit(function () {
            $("#uploadForm").ajaxSubmit();
            return false; // Prevent the submit handler from refreshing the page
        });

        $(document).on('change', '.btn-file :file', function () {
            var input = $(this),
                numFiles = input.get(0).files ? input.get(0).files.length : 1,
                label = input.val().replace(/\\/g, '/').replace(/.*\//, '');
            $("#txtFilename").val(label);
            input.trigger('fileselect', [numFiles, label]);
        });
    };

    me.registerSubscribers = function () {
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

            return true;
        });

        $("#notifier").on("notifyErrorEventHandler", function (sender, eventArgs) {

            var notifier = $("#notifier");

            notifier.html("<div class=\"alert alert-dismissible alert-danger\">" + eventArgs.statusText + "</div>");

            return true;
        });

        $("#dvImportQueue").on("notifyFiterCompleteEventHandler", function (sender, eventArgs) {

        });

        $("#dvImportQueue").on("notifyResultsEventHandler", function (sender, eventArgs) {
        });

        $("#dvImportQueue").on("notifyProcessedEventHandler", function (sender, eventArgs) {
        });
    };

    me.loadImportQueue = function (pageSize, pageIndex) {
        var filter = getFilter(pageSize, pageIndex);
        $(document).trigger("notifyFilterComplete", filter)
    };

    function getModels() {
        return privateStore[me.id].Models;
    }

    function getFilter(pageSize, pageIndex) {
        var filter = {
            PageIndex: pageIndex,
            PageSize: pageSize
        };

        return filter;
    }
}