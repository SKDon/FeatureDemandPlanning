// the column (derivative) filter 
var _filters = new Array();
var _currentFilter = null;
// the row (features/markets) filter 
var _rowFilters = new Array();
var _currentRowFilter = null;

// js class to hold the model data
function ModelFilter(docid, progid, mode, objectid) {
    this.DocumentId = docid;
    this.ProgrammeId = progid;
    this.Mode = mode;
    this.ObjectId = objectid;
    this.BodyIds = [];
    this.EngineIds = [];
    this.TranIds = [];
    this.TrimIds = [];
    this.CoaIds = [];
    this.ModelIds = [];

    this.addComp = function (comp, Id) {
        switch (comp) {
            case "body":
                this.BodyIds.push(Id);
                break;
            case "engine":
                this.EngineIds.push(Id);
                break;
            case "tran":
                this.TranIds.push(Id);
                break;
            case "trim":
                this.TrimIds.push(Id);
                break;
            case "coa":
                this.CoaIds.push(Id);
                break;
            case "model":
                this.ModelIds.push(Id);
                break;
        }
    };
}

function RowFilter(docid, progid) {
    this.DocumentId = docid;
    this.ProgrammeId = progid;
    this.MBMValue = "";
    this.FBMValue = "";
    this.FRSValue = "";
    this.GSFValue = "";    
}

$(document).ready(function () {
    hookupModelFilterDialogs();
});

function hookupModelFilterDialogs() {
    $("#select-model-dialog").dialog({
        title: "Select Derivatives",
        autoOpen: false,
        resizable: false,
        width: "570px",
        position: ["center", 100],
        show: "slide",
        hide: "slide",
        modal: true
    });
}

function hookupModelFilterEvent() {
    //hook up event
    $("span.model-component-item").click(function () {
        var $this = $(this);
        if ($this.hasClass("selected"))
            $this.removeClass("selected");
        else
            $this.addClass("selected");
        ComponentClick();
    });
}

function getModelFilterFromCookie() {

    var docid = $("input#ht_oxo_doc_id").val();
    var progid = $("input#ht_oxo_prog_id").val();
    var mode = $("input#ht_oxo_mode").val();
    var objectid = $("input#ht_oxo_object_id").val();

    if (getTrackCookie() == "on") {
        $("a#track1").text("Turn Tracking Off");
        _trackLine = true;
    }
    else {
        $("a#track1").text("Turn Tracking On");
        _trackLine = false;
    }


    var jsonFilter = $.cookie("model-filters");
    if (jsonFilter != null) {
        // show this to users
        _filters = eval("(" + jsonFilter + ")");
        for (var i = 0; i < _filters.length; i++) {
            if (_filters[i].DocumentId == docid && _filters[i].ProgrammeId == progid 
                && _filters[i].Mode == mode && _filters[i].ObjectId == objectid) 
            {
                _currentFilter = new ModelFilter(docid, progid, mode, objectid);
                _currentFilter.BodyIds = _filters[i].BodyIds;
                _currentFilter.EngineIds = _filters[i].EngineIds;
                _currentFilter.TranIds = _filters[i].TranIds;
                _currentFilter.TrimIds = _filters[i].TrimIds;
                _currentFilter.CoaIds = _filters[i].CoaIds;
                _currentFilter.ModelIds = _filters[i].ModelIds;
                $("div#model-filter").show();
                break;
            }
        }
    }
    if (_currentFilter == null)
        _currentFilter = new ModelFilter(docid, progid, mode, objectid);
    else {
        var models = $("ul.model-selected-list li.model-selected");
        //models.hide();
        for (var m = 0; m < _currentFilter.ModelIds.length; m++) {
            var modelid = _currentFilter.ModelIds[m];
            models.parent().find("[data=" + modelid + "]").show();
        }
        for (var b = 0; b < _currentFilter.BodyIds.length; b++) {
            var bodyid = _currentFilter.BodyIds[b];
            $("span.model-component-item[comp='body'][id=" + bodyid + "]").addClass("selected");
        }
        for (var e = 0; e < _currentFilter.EngineIds.length; e++) {
            var engineid = _currentFilter.EngineIds[e];
            $("span.model-component-item[comp='engine'][id=" + engineid + "]").addClass("selected");
        }
        for (var t = 0; t < _currentFilter.TranIds.length; t++) {
            var tranid = _currentFilter.TranIds[t];
            $("span.model-component-item[comp='tran'][id=" + tranid + "]").addClass("selected");
        }
        for (var i = 0; i < _currentFilter.TrimIds.length; i++) {
            var trimid = _currentFilter.TrimIds[i];
            $("span.model-component-item[comp='trim'][id=" + trimid + "]").addClass("selected");
        }
        for (var i = 0; i < _currentFilter.CoaIds.length; i++) {
            var coaid = _currentFilter.CoaIds[i];
            $("span.model-component-item[comp='coa'][id=" + coaid + "]").addClass("selected");
        }

        // calculate the legth of inner div
       
    }
}

function putModelFilterToCookie() {

    var match = false;

    if ($("span.selected").length == 0) {
        for (var i = 0; i < _filters.length; i++) {
            if (_filters[i].DocumentId == _currentFilter.DocumentId && _filters[i].ProgrammeId == _currentFilter.ProgrammeId 
                && _filters[i].Mode == _currentFilter.Mode && _filters[i].ObjectId == _currentFilter.ObjectId) 
            {
                _filters.splice(i, 1);
                break;
            }
        }
    }
    else {
        for (var i = 0; i < _filters.length; i++) {
            if (_filters[i].DocumentId == _currentFilter.DocumentId && _filters[i].ProgrammeId == _currentFilter.ProgrammeId 
                && _filters[i].Mode == _currentFilter.Mode && _filters[i].ObjectId == _currentFilter.ObjectId) 
            {
                _filters[i].BodyIds = _currentFilter.BodyIds;
                _filters[i].EngineIds = _currentFilter.EngineIds;
                _filters[i].TranIds = _currentFilter.TranIds;
                _filters[i].TrimIds = _currentFilter.TrimIds;
                _filters[i].CoaIds = _currentFilter.CoaIds;
                _filters[i].ModelIds = _currentFilter.ModelIds;
                match = true;
                break;
            }
        }

        if (!match)
            _filters.push(_currentFilter);
    }

    $.cookie("model-filters", JSON.stringify(_filters), { expires: 365 })
}


function getRowFilterFromCookie() {
    var docid = $("input#ht_oxo_doc_id").val();
    var progid = $("input#ht_oxo_prog_id").val();
    var jsonFilter = $.cookie("row-filters");
    var bMatch = false;
    if (jsonFilter != null) {
        // show this to users
        _rowFilters = eval("(" + jsonFilter + ")");
        for (var i = 0; i < _rowFilters.length; i++) {
            if (_rowFilters[i].DocumentId == docid && _rowFilters[i].ProgrammeId == progid) {
                _currentRowFilter = new RowFilter(docid, progid);
                _currentRowFilter.MBMValue = _rowFilters[i].MBMValue
                _currentRowFilter.FBMValue = _rowFilters[i].FBMValue;
                _currentRowFilter.FRSValue = _rowFilters[i].FRSValue;
                _currentRowFilter.GSFValue = _rowFilters[i].GSFValue;
                bMatch = true;
                break;
            }
        }
    }
    if (_currentRowFilter == null || bMatch == false) {
        _currentRowFilter = new RowFilter(docid, progid);
    }   
}

function putRowFilterToCookie() {

    var match = false;

    for (var i = 0; i < _rowFilters.length; i++) {
        if (_rowFilters[i].DocumentId == _currentRowFilter.DocumentId && _rowFilters[i].ProgrammeId == _currentRowFilter.ProgrammeId) {
            _rowFilters[i].MBMValue = _currentRowFilter.MBMValue;
            _rowFilters[i].FBMValue = _currentRowFilter.FBMValue;
            _rowFilters[i].FRSValue = _currentRowFilter.FRSValue;
            _rowFilters[i].GSFValue = _currentRowFilter.GSFValue;     
            match = true;
            break;
        }
    }

    if (!match)
        _rowFilters.push(_currentRowFilter);

    $.cookie("row-filters", JSON.stringify(_rowFilters), { expires: 365 })
}

function showSelectModelDialog() {
    if (_dirtyEditor) {
        var msg = "There are unsaved changes, please save/undo your changes before changing models filter.";
        OXOAlert("Models Filter", msg, "question", null);
    }
    else {
        $("#select-model-dialog").dialog("open");
        ComponentClick();
    }
}

function closeSelectModelDialog() {
    $("#select-model-dialog").dialog("close");
}

function setSelectModel() {
    //Check if any is visible
    if ($("ul.model-selected-list li.model-selected:visible").length != 0) {

        ShowWaitMsg();

        var docid = $("input#ht_oxo_doc_id").val();
        var progid = $("input#ht_oxo_prog_id").val();
        var mode = $("input#ht_oxo_mode").val();
        var objectid = $("input#ht_oxo_object_id").val();

        _currentFilter = new ModelFilter(docid, progid, mode, objectid);
        $("span.selected").each(function () {
            var comp = $(this).attr("comp");
            var id = $(this).attr("id");
            _currentFilter.addComp(comp, id);
        });
        $("ul.model-selected-list li.model-selected").each(function () {
            if ($(this).is(":visible")) {
                var id = $(this).attr("data");
                _currentFilter.addComp("model", id);
            }
        });
        putModelFilterToCookie();
        closeSelectModelDialog();
        $.cookie('current-page', 1, { path: "/", expires: 365 });
        location.reload(true);
    }
    else {
        OXOAlert("Models Filter", "Please select at least one model.", "question", null);
    }
}

function clearSelectModel() {
    
    $("span.selected").removeClass("selected");
    var models = $("ul.model-selected-list li.model-selected");
    models.show();
    $("div#model-count").text("" + models.length + " derivative(s) matched.");

}

function ComponentClick() {

    var models = $("ul.model-selected-list li");
    var bodySelector = "";
    var engineSelector = "";
    var tranSelector = "";
    var trimSelector = "";
    var coaSelector = "";

    models.hide();
    $("span.selected").each(function () {
        var comp = $(this).attr("comp");
        var id = $(this).attr("id");
        switch (comp) {
            case "body":
                bodySelector = bodySelector + "[" + comp + "id=" + id + "],"
                break;
            case "engine":
                engineSelector = engineSelector + "[" + comp + "id=" + id + "],"
                break;
            case "tran":
                tranSelector = tranSelector + "[" + comp + "id=" + id + "],"
                break;
            case "trim":
                trimSelector = trimSelector + "[" + comp + "id=" + id + "],"
                break;
            case "coa":
                coaSelector = coaSelector + "[" + comp + "id=" + id + "],"
                break;
        }
    });

    if (bodySelector != "") {
        bodySelector = bodySelector.slice(0, -1);
        models = models.filter(bodySelector);
    }
    if (engineSelector != "") {
        engineSelector = engineSelector.slice(0, -1);
        models = models.filter(engineSelector);
    }
    if (tranSelector != "") {
        tranSelector = tranSelector.slice(0, -1);
        models = models.filter(tranSelector);
    }
    if (trimSelector != "") {
        trimSelector = trimSelector.slice(0, -1);
        models = models.filter(trimSelector);
    }
    if (coaSelector != "") {
        coaSelector = coaSelector.slice(0, -1);
        models = models.filter(coaSelector);
    }

    models.show();
    $("div#model-count").text("" + models.length + " derivative(s) matched.");
}
