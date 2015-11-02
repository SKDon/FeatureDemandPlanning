"use strict";

var page = namespace("FeatureDemandPlanning.Import");

page.ImportQueuePage = function (models) {
    var uid = 0;
    var privateStore = {};
    var me = this;

    privateStore[me.id = uid++] = {};
    privateStore[me.id].DataTable = null;
    privateStore[me.id].Models = models;

    me.initialise = function () {
        me.registerEvents();
        me.registerSubscribers();
       
        $(privateStore[me.id].Models).each(function () {
            this.initialise();
        });
        me.loadData();
    }
    me.setDataTable = function (dataTable) {
        privateStore[me.id].DataTable = dataTable
    };
    me.getDataTable = function () {
        if (privateStore[me.id].DataTable == null) {
            me.configureDataTables();
        }
        return privateStore[me.id].DataTable;
    };
    me.loadData = function () {
        me.configureDataTables(getFilter());
    };
    me.getData = function (data, callback, settings) {
        var params = me.getParameters(data);
        var model = getImportQueueModel();
        var uri = model.getImportQueueUri();
        settings.jqXHR = $.ajax({
            "dataType": "json",
            "type": "POST",
            "url": uri,
            "data": params,
            "success": function (json) {
                callback(json);
            }
        });
    };
    me.getParameters = function (data) {
        var filter = getFilter();
        var params = $.extend({}, data, {
            "ImportQueueId": filter.ImportQueueId,
            "ExceptionType": filter.ExceptionType,
            "FilterMessage": filter.FilterMessage
        });
        return params;
    };
    me.configureDataTables = function () {

        var exceptionsUri = "/FeatureDemandPlanning/ImportException/?importQueueId=1";

        $("#tblImportQueue").DataTable({
            "serverSide": true,
            "pagingType": "full_numbers",
            "ajax": me.getData,
            "processing": true,
            "sDom": "ltip",
            "aoColumns": [
                {
                    "sTitle": "Uploaded On",
                    "sName": "UPLOADED_ON",
                    "bSearchable": true,
                    "bSortable": true,
                    "sClass": "text-center"
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
                    "bSortable": true,
                    "sClass": "text-center",
                },
                {
                    "sTitle": "Errors",
                    "sName": "ERRORS",
                    "bSearchable": false,
                    "bSortable": false,
                    "sClass": "text-center",
                    "render": function ( data, type, full, meta ) {
                        return "<a href='" + exceptionsUri + "'>View</a>";
                    }
                }
            ],
            "fnCreatedRow": function (row, data, index) {
                // Don't like hard-coding indexes in this way. Must be a better way
                var importQueueId = data[0];

                $(row).attr("data-importQueueId", importQueueId);
            },
            "fnDrawCallback": function (oSettings) {
                //$(document).trigger("Results", me.getSummary());
                //me.bindContextMenu();
            }
        });

        //me.setDataTable(dt);
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
    function getImportQueueModel() {
        return getModel("ImportQueue");
    };
    function getFilter(pageSize, pageIndex) {
        var model = getImportQueueModel();
        var filter = {
            PageIndex: pageIndex,
            PageSize: pageSize
        };

        return filter;
    }
}