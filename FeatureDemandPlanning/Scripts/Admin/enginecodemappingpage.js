"use strict";

var page = namespace("FeatureDemandPlanning.EngineCodeMapping");

page.Page = function (models)
{    
    var uid = 0;
    var privateStore = {};
    var me = this;

    privateStore[me.id = uid++] = {};
    privateStore[me.id].Models = models;

    me.initialise = function ()
    {
        me.registerEvents();
        me.registerSubscribers();
        me.configureDataTables();

        $(privateStore[me.id].Models).each(function () {
            this.initialise(me.initialiseCallback);
        });
    }

    me.initialiseCallback = function () {

    };

    me.configureDataTables = function () {
        
        var tblEngineCodeMappings = $("#tblEngineCodeMappings");
        var mappingUri = "";
        var editUri = "";
        $(privateStore[me.id].Models).each(function () {
            if (this.getEngineCodeMappingsUri != undefined) {
                mappingUri = this.getEngineCodeMappingsUri();
                editUri = this.getEngineCodeMappingsEditUri();
            }
        });

        var dt = tblEngineCodeMappings.DataTable({
            "bServerSide": true,
            "sAjaxSource": mappingUri,
            "bProcessing": false,
            "iDisplayLength": 10,
            "sDom": "ltip",
            "aoColumns": [
                {
                    "sTitle": "Make",
                    "sName": "MAKE",
                    "bSearchable": true,
                    "bSortable": true,
                    "sWidth:": "10%"
                },
                {
                    "sTitle": "Vehicle",
                    "sName": "VEHICLE",
                    "bSearchable": true,
                    "bSortable": true,
                    "sWidth": "20%"
                },
                {
                    "sTitle": "M/Y",
                    "sName": "MODEL_YEAR",
                    "bSearchable": true,
                    "bSortable": true,
                    "sWidth": "10%"
                },
                {
                    "sTitle": "Engine",
                    "sName": "ENGINE",
                    "bSearchable": true,
                    "bSortable": true,
                    "sWidth": "10%"
                },
                {
                    "sTitle": "Fuel",
                    "sName": "FUEL",
                    "bSearchable": true,
                    "bSortable": true,
                    "sWidth": "10%"
                },
                {
                    "sTitle": "Power",
                    "sName": "POWER",
                    "bSearchable": true,
                    "bSortable": true,
                    "sWidth": "10%"
                },
                {
                    "sTitle": "E",
                    "sName": "ELECTRIFICATION",
                    "bSearchable": true,
                    "bSortable": true,
                    "sWidth": "10%"
                },
                {
                    "sTitle": "Engine Code",
                    "sName": "EXTERNAL_CODE",
                    "bSearchable": true,
                    "bSortable": true,
                    "sClass": "editEngineCode",
                    "sWidth": "15%"
                },
                {
                    "sTitle": "ProgrammeId",
                    "sName": "PROGRAMME_ID",
                    "bSearchable": false,
                    "bSortable": false,
                    "bVisible": false,
                    "sWidth": "1%"
                },
                {
                    "sTitle": "EngineId",
                    "sName": "ENGINE_ID",
                    "bSearchable": false,
                    "bSortable": false,
                    "bVisible": false,
                    "sWidth": "1%"
                }
            ],
            "createdRow": function (row, data, index)
            {
                // Don't like hard-coding indexes in this way. Must be a better way
                var programmeId = data[8];
                var engineId = data[9];

                $(row).attr("data-programmeId", programmeId);
                $(row).attr("data-engineId", engineId);
            }
        });

        
        tblEngineCodeMappings.on("draw.dt", function (e, settings) {

            $(".editEngineCode").editable(me.editEngineCode, {
                placeholder: "",
                select: true,
                onblur: "submit"
            });
        });
    }

    me.editEngineCode = function (value, settings)
    {
        var tblEngineCodeMappings = $("#tblEngineCodeMappings");
        var editUri = "";
        $(privateStore[me.id].Models).each(function () {
            if (this.getEngineCodeMappingsEditUri != undefined) {
                editUri = this.getEngineCodeMappingsEditUri();
            }
        });

        // Get the row being edited and any metdata that it contains to identify the programme and engine id

        var origValue = this.revert;
        if (value == origValue) {
            return origValue;
        }

        var cell = $(this).context;
        var row = $(this).context.parentElement;
        var engineId = $(row).attr("data-engineId");
        var programmeId = $(row).attr("data-programmeId");

        var update = {
            programmeId: programmeId,
            engineId: engineId,
            externalEngineCode: value == null ? "" : value.toUpperCase()
        };

        var results = $.getJSON(editUri, update, function (data, testStatus, jqXHR) {
            if (testStatus.toUpperCase() == "SUCCESS") {
                $(cell).html(data.ExternalEngineCode);
            }
            else
            {
                $(cell).html = origValue;
            }
        });

        return origValue;
    }

    me.registerEvents = function ()
    {
        $(document).on("notifySuccess", function (sender, eventArgs) {
            var subscribers = $(".subscribers-notifySuccess");
            subscribers.trigger("notifySuccessEventHandler", [eventArgs]);
        });

        $(document).on("notifyError", function (sender, eventArgs) {
            var subscribers = $(".subscribers-notifyError");
            subscribers.trigger("notifyErrorEventHandler", [eventArgs]);
        });

        $(document).on("notifyMakes", function (sender, eventArgs) {
            var subscribers = $(".subscribers-notifyMakes");
            subscribers.trigger("notifyMakesEventHandler", [eventArgs]);
        });

        $(document).on("notifyProgrammes", function (sender, eventArgs) {
            var subscribers = $(".subscribers-notifyProgrammes");
            subscribers.trigger("notifyProgrammesEventHandler", [eventArgs]);
        });

        $(document).on("notifyModelYears", function (sender, eventArgs) {
            var subscribers = $(".subscribers-notifyModelYears");
            subscribers.trigger("notifyModelYearsEventHandler", [eventArgs]);
        });

        $(document).on("notifyFilterComplete", function (sender, eventArgs) {
            var subscribers = $(".subscribers-notifyFilterComplete");
            subscribers.trigger("notifyFilterCompleteEventHandler", [eventArgs]);
        });

        $(document).on("notifyResults", function (sender, eventArgs) {
            var subscribers = $(".subscribers-notifyResults");
            subscribers.trigger("notifyResultsEventHandler", [eventArgs]);
        });

        $(document).on("notifyUpdated", function (sender, eventArgs) {
            var subscribers = $(".subscribers-notifyUpdated");
            subscribers.trigger("notifyUpdatedEventHandler", [eventArgs]);
        })

        $("#ddlMake").change(me.makeChanged);
        $("#ddlProgramme").change(me.programmeChanged);
        $("#txtEngineCode").keyup(function () {
            var engineCode = $("#txtEngineCode").val()
            if (engineCode.length == 0 || engineCode.length >= 3) {
                me.engineCodeChanged(engineCode);
            }
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

        $("#ddlMake").on("notifyMakesEventHandler", function (sender, eventArgs) {

            var ddlMakes = $("#ddlMake");

            ddlMakes.empty();
            $(eventArgs.Makes).each(function () {
                $("<option />", {
                    val: this,
                    text: this
                }).appendTo(ddlMakes);
            });

            ddlMakes.prepend("<option value='' selected='selected'>-- SELECT --</option>");

            var models = getModels();
            $(models).each(function () {
                if (this.getProgrammes !== undefined) {
                    var pageSize = this.getPageSize();
                    var pageIndex = this.getPageIndex();
                    var filter = getFilter(pageSize, pageIndex);
                    this.getProgrammes(filter);
                }
            });
        });

        $("#ddlProgramme").on("notifyProgrammesEventHandler", function (sender, eventArgs) {

            var ddlMakes = $("#ddlMake");
            var ddlProgrammes = $("#ddlProgramme");

            ddlProgrammes.empty();
            $(eventArgs.Programmes).each(function () {
                $("<option />", {
                    val: this.VehicleName,
                    text: this.Description
                }).appendTo(ddlProgrammes);
            });

            if (eventArgs.Programmes.length === 1) {
                ddlProgrammes.val(eventArgs.Programmes[0].VehicleName);
            }
            else {
                ddlProgrammes.prepend("<option value='' selected='selected'>-- SELECT --</option>");
            }

            var models = getModels();
            $(models).each(function () {
                if (this.getModelYears !== undefined) {
                    var pageSize = this.getPageSize();
                    var pageIndex = this.getPageIndex();
                    var filter = getFilter(pageSize, pageIndex);
                    this.getModelYears(filter);
                    return false;
                }
            });
        });

        $("#ddlModelYear").on("notifyModelYearsEventHandler", function (sender, eventArgs)
        {
            var models = getModels();
            var ddlModelYears = $("#ddlModelYear");

            ddlModelYears.empty();
            $(eventArgs.ModelYears).each(function () {
                $("<option />", {
                    val: this,
                    text: this
                }).appendTo(ddlModelYears);
            });

            if (eventArgs.ModelYears.length === 1)
            {
                ddlModelYears.val(eventArgs.ModelYears[0]);
            }
            else
            {
                ddlModelYears.prepend("<option value='' selected='selected'>-- SELECT --</option>");
            }

            // As this is the final stage of the binding of filter results, we can perform a search
            // by rebinding the model and listening for the notifyFilterComplete event

            $(models).each(function () {
               
                if (this.getPageSize !== undefined &&
                    this.getPageIndex !== undefined &&
                    this.filterResults !== undefined)
                {
                    var pageSize = this.getPageSize();
                    var pageIndex = this.getPageIndex();
                    var filter = getFilter(pageSize, pageIndex);

                    this.filterResults(filter);

                    return false;
                } 
            });
        });

        $("#dvFilter").on("notifyFilterCompleteEventHandler", function (sender, eventArgs)
        {
            var tblEngineCodeMappings = $("#tblEngineCodeMappings");
            var dt = tblEngineCodeMappings.dataTable();
            dt.fnFilter(JSON.stringify(eventArgs));
        });

        $("#dvEngineCodeMappings").on("notifyResultsEventHandler", function (sender, eventArgs)
        {
        });

        $("#dvEngineCodeMappings").on("notifyUpdatedEventHandler", function (sender, eventArgs) {
        });
    };

    me.loadEngineCodeMappings = function (pageSize, pageIndex) { 
        var filter = getFilter(pageSize, pageIndex);
        $(document).trigger("notifyFilterComplete", filter)
    };

    me.makeChanged = function(data) {
        var models = getModels();
        $(models).each(function () {
            if (this.getProgrammes !== undefined) {
                var pageSize = this.getPageSize();
                var pageIndex = this.getPageIndex();
                var filter = getFilter(pageSize, pageIndex);
                this.getProgrammes(filter);
            }
        });
    }

    me.programmeChanged = function(data) {
        var models = getModels();
        $(models).each(function () {
            if (this.getModelYears !== undefined) {
                var pageSize = this.getPageSize();
                var pageIndex = this.getPageIndex();
                var filter = getFilter(pageSize, pageIndex);
                this.getModelYears(filter);
            }
        });
    }

    me.engineCodeChanged = function(data) {
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
    }

    function getModels() {
        return privateStore[me.id].Models;
    }

    function getFilter(pageSize, pageIndex) {
        var filter = new FeatureDemandPlanning.Vehicle.VehicleFilter();
        
        filter.Make = $("#ddlMake").val();
        filter.Name = $("#ddlProgramme").val();
        filter.ModelYear = $("#ddlModelYear").val();
        filter.DerivativeCode = $("#txtEngineCode").val();
        filter.PageIndex = pageIndex;
        filter.PageSize = pageSize;

        return filter;
    }
};