// Core table on left and right side
var _OXODataTableA;
var _OXODataTableB;
// Global varibles
var _injectOXODataTitleA = true;
var _injectOXODataTitleB = true;
var _toggleFolder = true;
var _dirtyEditor = false;
var _whichCell;
var _fireStarter = 'none';
var _originalTop;
var _copiedColumnCells;
var _copiedRowCells;
var _trackLine = true;

//$(document).ready(function () {

//    initialiseEditor();

//});

function initialiseEditor()
{
    try {
        ShowWaitMsg();
        resetSavedFilter();
        hookupTableA();
        hookupTableB();
        CloneHeader();
        $("div#doc-waiting").hide();
        $("div#doc-wrapper").show();
        hookupContextMenu();
        doTextAreaLimit();
        hookupModelFilterEvent();
        getModelFilterFromCookie();
        hookupOtherEvents();
        ResizeMeEditor();
        hideHeader();
        HideWaitMsg();
        doModelMarketDropdowns();
        _originalTop = $("#innerbody").position().top;
        if (typeof injectPackAvailability == 'function') {
            injectPackAvailability();
        }
        if (typeof postProcessing == "function") {
            postProcessing();
        }
        var cookies = GetCookiesTrap(0).split(',');
        _toggleFolder = (cookies.length == 0);
    } catch (ex) {
        debugger;
    }
}


//generic function for both mbm and fbm editor
function ShowColumnTracking(el, modelid) {
    var rowIndex = $(el).parent().index();
    var cells = $(el).closest("table").find("tr.oxo-data-row-2 td[modelid='" + modelid + "']");
    cells.each(function () {
        if ($(this).parent().index() < rowIndex)
            $(this).addClass("tracked");
    });
    $("#clone-oxo-core-table-B thead tr th[data='" + modelid + "']").addClass("tracked");

}

function ShowRowTracking(el, entityid) {
    if (el.hasClass("pack-header") == false) {
        var entity = "marketid";
        var rowid = $(el).parent().attr("row-id");
        if (_OXOSection == "FBM" || _OXOSection == "FPS" || _OXOSection == "GSF") {
            entity = "featureid";
        }
        $(el).prevAll("td[" + entity + "='" + entityid + "']").andSelf().addClass("tracked");
        $("#oxo-core-table-A tr.oxo-data-row-2[row-id='" + rowid + "'] td[" + entity + "='" + entityid + "']").addClass("tracked");
    }
}

function CloneHeader() {

    var headersA = $("#oxo-core-table-A thead").html(); // skip the header row
    var cloneHeadersA = $("#clone-oxo-core-table-A thead").html(headersA);
    var headersB = $("#oxo-core-table-B thead").html(); // skip the header row
    var cloneHeadersB = $("#clone-oxo-core-table-B thead").html(headersB);

    // Clear Expander Text for table B
    $("table#oxo-core-table-B td.group-item-expander").each(function () {
        var group = $(this).attr("data-group");
        $(this).text('');
        $(this).css("padding", "0px");
    });
    //Add model filter indicator
    var html = "<div id='model-filter'>Derivative Filter [<span style='color:orange;'>&nbsp;On&nbsp;</span>]&nbsp-&nbsp<a href='#' style='color:orange;' onclick='clearModelFilter()'>Clear</a></div>";
    var col = 0;
    if (_OXOSection == "MBM")
        col = 1;
    $($("table#clone-oxo-core-table-A thead tr").children()[col]).append(html);

    if (_OXOSection == "MBM") {
        var html2 = "<tr class='countries-count'><th colspan='4'>Market Count&nbsp;:&nbsp;</th></tr>";
        //MN - add derivative counter for model
        $("#clone-oxo-core-table-A thead").append(html2);
        var html3 = "<tr class='countries-count-B'>"
        $("#clone-oxo-core-table-B thead tr th").each(function () {
            html3 = html3 + "<th class='countries-count' modelid='" + $(this).attr("data") + "'>" + $(this).attr("countries-count") + "</th>";
        });
        html3 = html3 + "</tr>";
        $("#clone-oxo-core-table-B thead").append(html3);

    }

    $("#clone-oxo-core-table-B thead tr th:last-child").css("border-right", "0px");
}

function CloneHeaderB() {

    var headersB = $("#oxo-core-table-B thead").html(); // skip the header row
    var cloneHeadersB = $("#clone-oxo-core-table-B thead").html(headersB);

    // Clear Expander Text for table B
    $("table#oxo-core-table-B td.group-item-expander").each(function () {
        var group = $(this).attr("data-group");
        $(this).text('');
        $(this).css("padding", "0px");
    });
    if (_OXOSection == "MBM") {
        var html3 = "<tr class='countries-count-B'>"
        $("#clone-oxo-core-table-B thead tr th").each(function () {
            html3 = html3 + "<th class='countries-count' modelid='" + $(this).attr("data") + "'>" + $(this).attr("countries-count") + "</th>";
        });
        html3 = html3 + "</tr>";
        $("#clone-oxo-core-table-B thead").append(html3);
    }

    $("#clone-oxo-core-table-B thead tr th:last-child").css("border-right", "0px");
}

function hookupOtherEventsB() {
    $('#oxo-core-table-B').on("mousedown", 'td', function (event) {
        _whichCell = $(this);
    });

    $('#clone-oxo-core-table-B').on("mousedown", 'th', function () {
        if (!$(this).hasClass("countries-count")) {
            $('table#clone-oxo-core-table-B').find("th").removeClass("selected");
            $(this).addClass("selected");
        }
    });

    $("#oxo-core-table-B").on("mouseenter", 'td', function () {
        if (!$(this).hasClass("group") && !$(this).hasClass("subgroup") && _trackLine) {
            var modelId = $(this).attr("modelid");
            var entityId = $(this).attr("marketid");
            if (_OXOSection == "FBM" || _OXOSection == "FPS" || _OXOSection == "GSF")
                entityId = $(this).attr("featureid");
            ShowColumnTracking($(this), modelId);
            ShowRowTracking($(this), entityId);
        }
    });

    $("#oxo-core-table-B").on("mouseleave", 'td', function () {
        $("#oxo-core-table-B tr td.tracked,#oxo-core-table-A tr td.tracked").removeClass("tracked");
        $("#clone-oxo-core-table-B thead tr th.tracked").removeClass("tracked");
    });
}


function hookupOtherEvents() {

    $(document).on('mousewheel', function (event) {

        if ($("#v-slider").is(":visible") && ($("div.ui-widget-overlay").is(":visible") == false)) {
            var currentTop = $("#innerbody").position().top;
            var currentValue = $("#v-slider").slider("value");
            currentValue = currentValue + (event.deltaY * event.deltaFactor * _scrollFactor);
            var max = $("#v-slider").slider("option", "max");
            var min = $("#v-slider").slider("option", "min");
            if (currentValue <= max && currentValue >= min) {
                currentTop = currentTop + (event.deltaY * event.deltaFactor * _scrollFactor);
                $("#innerbody").css("top", '' + currentTop + 'px');
                $("#v-slider").slider("value", currentValue);
            }
            else {
                if (currentValue > max) {
                    $("#innerbody").css("top", '' + _originalTop + 'px');
                    $("#v-slider").slider("value", max);
                }
                if (currentValue < min) {
                    $("#v-slider").slider("value", min);
                }
            }
        }
    });

    $(window).resize(function () { ResizeMeEditor() });

    hookupOtherEventsB();

    $('#oxo-core-table-A').on("mousedown", 'td', function () {
        $('#oxo-core-table-A').find("tr.oxo-data-row-2").removeClass("selected");
        $(this).parent().addClass("selected");
    });

    $(window).bind('beforeunload', function (e) {
        if (_dirtyEditor) {
            return "There are unsaved changes, press Cancel to stay on this page and save/undo your changes.";
        }
        else {
            ShowWaitMsg();
        }
    });

    $('div#dtable-filter input').on('keydown', function (e) {
        if (_dirtyEditor) {
            e.preventDefault();
            OXOAlert("Apply Filter", "There are unsaved changes, please save/undo your changes before applying filter.", "exclamation", null);
        }
    })

    $('div#dtable-filter input').on("keyup", function () {
        if (!_dirtyEditor) {
            var section = $("input#ht_oxo_section").val();
            _fireStarter = "none";
            resetScrollbar();
            var searchLength = (section == "MBM" ? 2 : 3);
            var searchVal = this.value;
            if (searchVal.length >= searchLength) {
                switch (section) {
                    case "MBM":
                        _currentRowFilter.MBMValue = searchVal;
                        break;
                    case "FBM":
                        _currentRowFilter.FBMValue = searchVal;
                        break;
                    case "FRS":
                        _currentRowFilter.FRSValue = searchVal;
                        break;
                    case "GSF":
                        _currentRowFilter.GSFValue = searchVal;
                        break;
                }
                _OXODataTableA.fnFilter(searchVal);
                _OXODataTableB.fnFilter(searchVal);

                if (section == "MBM") {
                    $("#clone-oxo-core-table-B tr.countries-count-B th").each(function () {
                        var modelid = $(this).attr("modelid");
                        UpdateMarketCount(modelid);
                    });
                }

                if (typeof injectPackAvailability == 'function') {
                    injectPackAvailability();
                }

                hookupContextMenu();
            }
            else {
                if (searchVal.length == 0) {
                    switch (section) {
                        case "MBM":
                            _currentRowFilter.MBMValue = "";
                            break;
                        case "FBM":
                            _currentRowFilter.FBMValue = "";
                            break;
                        case "FRS":
                            _currentRowFilter.FRSValue = "";
                            break;
                        case "GSF":
                            _currentRowFilter.GSFValue = "";
                            break;
                    }

                    _OXODataTableA.fnFilter('');
                    _OXODataTableB.fnFilter('');

                    if (section == "MBM") {
                        $("#clone-oxo-core-table-B tr.countries-count-B th").each(function () {
                            var modelid = $(this).attr("modelid");
                            UpdateMarketCount(modelid);
                        });
                    }

                    if (typeof injectPackAvailability == 'function') {
                        injectPackAvailability();
                    }
                }
            }


            putRowFilterToCookie();
            $('div#dtable-info').text($('div.dataTables_info').text());
            checkScrollbar();
            hookupContextMenu();
        }
    });
}

function hookupClickEvent() {
    $("#oxo-core-table-B").on("click", 'td', function () {
        if (!($(this).closest("table").hasClass("pack") || $(this).hasClass("pack-body"))) {    
            if ($(this).attr("featureid") != -1000)
                cellClick(this, null);
        }
    });
}

function ResizeMeEditor() {

    var cloneheader = $("div#clone-column-header").width();
    var rightpane = $("div#right-pane-header").width();
    var room = (cloneheader - rightpane);

    if (room > _minLeftWidth) {
        var padding = $("table#clone-oxo-core-table-B th").length;
        // resize left side
        $("div#left-pane-header").width(room - padding);
        $("table#clone-oxo-core-table-A").width(room - padding + 1);
        $("div#left-pane").width(room - padding);
        $("table#oxo-core-table-A").width(room - padding + 1);
    }
    else {
        $("div#left-pane-header").width(_minLeftWidth);
        $("table#clone-oxo-core-table-A").width(_minLeftWidth + 1);
        $("div#left-pane").width(_minLeftWidth);
        $("table#oxo-core-table-A").width(_minLeftWidth + 1);
    }

    var leftpane = $("div#left-pane").width();

    $("div#innerheader").width(leftpane + rightpane + 4);
    $("div#innerbody").width(leftpane + rightpane + 4);

    ResizeMe();
}

function hideHeader() {
    var heightA = $("table#clone-oxo-core-table-A thead tr th").height() + 109;
    var leftA = $("table#clone-oxo-core-table-A").position().left + 1;
    $('table#oxo-core-table-A').css("top", "-" + heightA + "px").css("left", leftA + "px");

    var heightB = $("table#clone-oxo-core-table-B thead tr th").height() + 109;
    var leftB = $("table#clone-oxo-core-table-B").position().left + 1;
    $('table#oxo-core-table-B').css("top", "-" + heightB + "px").css("left", leftB + "px");

}

function SyncHeader(option, target, state) {

    if (_fireStarter != "Table" + option && _fireStarter != "none") {
        $("#oxo-core-table-" + option).find("td[data-group='" + target + "']").trigger("click");
        if (state == "Open") {
            var rowA = $("#oxo-core-table-A tbody tr[data-group='" + target + "']");
            var rowB = $("#oxo-core-table-B tbody tr[data-group='" + target + "']");

            for (var i = 0; i < rowA.length; i++) {
                var height = $(rowA[i]).height();
                height = Math.round(height);
                $(rowA[i]).height(height);
                $(rowB[i]).height(height);
            }
        }
    }
}

function DoHorizontalScroll(value) {
    $("#right-pane,#right-pane-header").css("left", "-" + value + "px");
}

function ToggleAllFolderWrapper() {
    ShowWaitMsg();
    setTimeout(ToggleAllFolder, 100);
}

function ToggleAllFolder() {

    _fireStarter = 'TableA';
    $("#oxo-core-table-A").find("td[data-group-level='0']").each(function () {
        if (_toggleFolder) {
            $(this).addClass('expanded').removeClass('collapsed').parents('.dataTables_wrapper').find('.collapsed-group').trigger('click');
        }
        else {
            $(this).addClass('collapsed').removeClass('expanded').parents('.dataTables_wrapper').find('.expanded-group').trigger('click');
        }
    });
    _toggleFolder = !_toggleFolder;
    HideWaitMsg();
}

function cancelOXODocument() {
    OXOConfirm("Cancel Save", "Are you sure you want to cancel your changes to this OXO Document?", "question", cancelSaveWrapper);
}

function cancelSaveWrapper() {
    var cells = $("#oxo-core-table-B").find("td.isDirty");
    cells.each(function () {
        if (_OXOSection == 'MBM') {
            var uniqueid = $(this).parent().attr("uniqueid");
            if ($(this).attr("prevval") == "") {
                $(this).removeClass("ticked").addClass("unticked");
                UpdateModelCount(uniqueid, false);
            }
            else {
                $(this).removeClass("unticked").addClass("ticked");
                UpdateModelCount(uniqueid, true);
            }
        }
        else {
            var preCode = $(this).attr("prevval");
            $(this)[0].innerHTML = translateCode(preCode);
        }
        $(this).removeClass("isDirty");
        if ($(this).hasClass("prev-mglevel"))
            $(this).addClass("mglevel")
        if ($(this).hasClass("prev-generic"))
            $(this).addClass("generic")
    });

    _dirtyEditor = false;
    $("a#butSaveChange,a#butCancelChange").hide();
    if (typeof postProcessing == "function") {
        postProcessing();
    }
    HideWaitMsg();
}

///////////////////////////////////////////////////////////
// data update functions
///////////////////////////////////////////////////////////

function saveOXODocument() {

    var myData = [];
    var counter = 0;
    var docId = 0;
    var section = "";
    var reason = "";
    var note = "";
    var PCANRef = "";
    var PDLRef = "";
    var ETrackerRef = "";
    var progId = 0;
    var _chosenMarketId = 0;
    var _chosenMarketGroupId = 0;

    var _chosenObj = $("a#selectedObject");

    if (_chosenObj.attr("type") == "mg") {
        _chosenMarketGroupId = _chosenObj.attr("data");
    }
    else {
        _chosenMarketId = _chosenObj.attr("data");
    }

    $("#oxo-core-table-B").find("td.isDirty").each(function () {
        if (_OXOSection == "MBM") {
            var modelId = $(this).attr("modelid");
            var marketGroupId = $(this).attr("groupid");            
            var marketId = $(this).attr("marketid");
            var ticked = $(this).hasClass("ticked");
            var section = "MBM";
            myData[counter] = new DataItem(section, modelId, marketId, marketGroupId, 0, 0, (ticked ? "Y" : ""));
            counter++;
        }
        else if (_OXOSection == "FBM") {
            if ($(this).attr("featureid") != "-1000" || $(this).hasClass("pack-header"))
            {
                var modelId = $(this).attr("modelid");
                var marketId = _chosenMarketId;
                var featureId = $(this).attr("featureid");
                var packId = $(this).attr("packid");
                var code = $(this).text();
                var section = "FBM";
                if ($(this).hasClass("pack-header"))
                    section = "PCK";
                if ($(this).hasClass("pack-body"))
                    section = "FPS";
                myData[counter] = new DataItem(section, modelId, _chosenMarketId, _chosenMarketGroupId, featureId, packId, code);
                counter++;
            }
        }
        else {
            if($(this).attr("featureid")!="-1000")
            {
                var modelId = $(this).attr("modelid");
                var featureId = $(this).attr("featureid");
                var code = $(this).text();
                var section = "GSF";
                myData[counter] = new DataItem(section, modelId, -1, 0, featureId, 0, code);
                counter++;
            }
        }
    });

    docId = $("input#ht_oxo_doc_id").val();
    section = _OXOSection;
    progId = $("input#ht_oxo_prog_id").val();

    var ctl = $("div#save-change-dialog");
    reminder = $(ctl).find("#reasonText").val();

    var changeLog = new ChangeLog(docId, section, reminder, myData);


    ajaxSaveOXODoc(progId, section, JSON.stringify(changeLog));
}

function ajaxSaveOXODoc(progId, section, changeLog) {
    var url = _pathHeader + "/Editor/ajaxSaveOXODoc?progId=" + progId + "&section=" + section + "&required=" + (new Date()).getTime();
    $.ajax({
        type: "POST",
        cache: false,
        url: url,
        data: changeLog,
        dataType: 'json',
        contentType: "application/json; charset=utf-8",
        success: function (data) {
            if (data.Success) {
                /* closeSaveChangeDialog();
                _dirtyEditor = false;
                $("a#butSaveChange,a#butCancelChange").hide();
                $("#oxo-core-table-B").find("td.isDirty").each(function () {
                $(this).removeClass("isDirty").removeClass("prev-generic").removeClass("prev-group");
                $(this).attr("prevval",  $(this).text());
                });*/
                _dirtyEditor = false;
                location.reload(true);
            }
            else {
                OXOAlert("Error", "Save OXO Document failed.", "error", null);
            }
        },
        error: function (xhr, ajaxOptions, thrownError) {
            OXOAlert("Error", xhr.status, "error", null);
            OXOAlert("Error", thrownError, "error", null);
        }
    });
}

function doModelMarketDropdowns() {

    $('#mode-menu').smartmenus({
        subMenusSubOffsetX: 0,
        subMenusSubOffsetY: 1,
        showOnClick: true
    });

    $('#market-menu').smartmenus({
        subMenusSubOffsetX: 0,
        subMenusSubOffsetY: 1,
        showOnClick: true
    });
}

function ChangeLog(docid, section, reminder, DataItem) {
    this.OXODocId = docid;
    this.Section = section;
    this.Reminder = reminder;
    this.DataItem = DataItem;
}

function DataItem(section, modelid, marketid, marketgroupid, featureid, packid, code) // Constructor
{
    this.Section = section;
    this.ModelId = modelid;
    this.MarketId = marketid;
    this.MarketGroupId = marketgroupid;
    this.FeatureId = featureid;
    this.PackId = packid;
    this.Code = code;
}

function changeLogWrapper() {
    var docId = $("input#ht_oxo_doc_id").val();
    var progId = $("input#ht_oxo_prog_id").val();
    var docTitle = $("div#dtable-title").text();
    showChangeDetailDialog(docId, progId, docTitle);
}

function getRuleTextToolTip(progId, docId, featureId) {

    var url = _pathHeader + "/Editor/ajaxGetCommentByFeature?progId=" + progId + "&docId=" + docId + "&featureId=" + featureId + "&required=" + $.now();
    var html = "<table style='margin-left:-4px'>";
    $.ajax({
        url: url,
        type: 'GET',
        async: false, //blocks window close
        success: function (data) {
            if (data != null) {
                html = html + "<tr>";
                html = html + "<td style='vertical-align:top'><img src='" + _pathHeader + "/Content/Images/Editor/frs-icon.png' /></td>";
                html = html + "<td style='color:orange;'>" + data.RuleText + "</td>";
                html = html + "</tr>";
            }
        },
        error: function (xhr, ajaxOptions, thrownError) {
            alert(xhr.status);
            alert(thrownError);
        }
    });
    html = html + "</table>";
    return html;
}

function getCommentToolTip(progId, docId, featureId) {

    var url = _pathHeader + "/Editor/ajaxGetCommentByFeature?progId=" + progId + "&docId=" + docId + "&featureId=" + featureId + "&required=" + $.now();
    var html = "<table style='margin-left:-4px'>";
    $.ajax({
        url: url,
        type: 'GET',
        async: false, //blocks window close
        success: function (data) {
            if (data != null) {
                html = html + "<tr>";
                html = html + "<td style='vertical-align:top'><img src='" + _pathHeader + "/Content/Images/Admin/comment.png' /></td>";
                html = html + "<td>" + data.Comment + "</td>";
                html = html + "</tr>";
            }
        },
        error: function (xhr, ajaxOptions, thrownError) {
            alert(xhr.status);
            alert(thrownError);
        }
    });
    html = html + "</table>";
    return html;
}

function hideSubGroupHeader() {
    if(_OXOSection != "MBM")
    {
        var tableASubGroupHeaders = $('#oxo-core-table-A td.subgroup');
        var tableBSubGroupHeaders = $('#oxo-core-table-B td.subgroup');

    for (var i = 0; i < tableASubGroupHeaders.length; i++) {
        if ($(tableASubGroupHeaders[i]).text() == "NA") {
            $(tableASubGroupHeaders[i]).parent().hide();
            $(tableBSubGroupHeaders[i]).parent().hide();
        }
    }
        if (_OXOSection == "FBM") {
             $('#oxo-core-table-A tr.pack-availability').hide();
             $('#oxo-core-table-B tr.pack-availability').hide();
        }
   }
}

function clearModelFilter() {
    if (_dirtyEditor) {
        OXOAlert("Clear Filter", "There are unsaved changes, please save/undo your changes before clearing filter.", "exclamation", null);
    }
    else {
        ShowWaitMsg();
        for (var i = 0; i < _filters.length; i++) {
            if (_filters[i].DocumentId == _currentFilter.DocumentId
                && _filters[i].ProgrammeId == _currentFilter.ProgrammeId
                && _filters[i].Mode == _currentFilter.Mode
                && _filters[i].ObjectId == _currentFilter.ObjectId) {
                _filters.splice(i, 1);
                break;
            }
        }
        $.cookie("model-filters", JSON.stringify(_filters), { expires: 365 })
        //need to clear derivative/feature filters
        location.reload(true);
    }
}

function resetSavedFilter() {

    var value = "";
    getRowFilterFromCookie();
    var section = $("input#ht_oxo_section").val();
    switch (section) {
        case "MBM":
            value = _currentRowFilter.MBMValue;
            break;
        case "FBM":
            value = _currentRowFilter.FBMValue;
            break;
        case "FRS":
            value = _currentRowFilter.FRSValue;
            break;
        case "GSF":
            value = _currentRowFilter.GSFValue;
            break;
    }

    $("div#dtable-filter input").val(value);

    // if (value.length > 0) {
    //     $("div#dtable-filter input").val(value);
    //     _OXODataTableA.fnFilter(value);
    //     _OXODataTableB.fnFilter(value);
    // }
}

function translateCode(code) {
    if (code.indexOf("**") != -1)
        return code.replace("**", "<sup>2</sup>");
    else
        return code.replace("*", "<sup>1</sup>");
}

function getTrackCookie() {
    var retval = $.cookie("tracking") ? $.cookie("tracking") : 'on';
    return retval;
}

function closeIntrimPublishPopup() {
    $("div#interim-dialog").dialog("close");
}

function closeGatewayPublishPopup() {
    $("div#gateway-dialog").dialog("close");
}

function InterimPublish() {

    var _option = new Array(5);
    var progId = $("input#ht_oxo_prog_id").val();
    var docId = $("input#ht_oxo_doc_id").val();
    var minorMajor = $("#minor-major").val();
    var comment = $("textarea#comment").val();
    var PACN = $("#txtInterimPACN").val();
    var proceed = true;

    if ($.trim(comment) == "") {
        OXOAlert("Interim Publishing", "Please supply a comment before publishing.", "exclamation", null);
        proceed = false;
    }

    if ($.trim(PACN) == "" && minorMajor == "Major") {
        OXOAlert("Interim Publishing", "Please supply a PACN before a major publishing.", "exclamation", null);
        proceed = false;
    }

    if ($.trim(PACN) != "" && $.trim(PACN).length < 8) {
        OXOAlert("Interim Publishing", "PACN number - must have a minimum 8 characters.", "exclamation", null);
        proceed = false;
    }

    if(proceed)
    {
        _option[0] = progId;
        _option[1] = docId;
        _option[2] = minorMajor;
        _option[3] = comment;
        _option[4] = PACN;

        var url = _pathHeader + "/Editor/ajaxPublishOXO?required=" + $.now();
        $.ajax({
            type: "POST",
            cache: false,
            url: url,
            dataType: 'json',
            data: JSON.stringify(_option),
            contentType: "application/json; charset=utf-8",
            success: function (data) {
                if (data.Success) {
                    OXOAlert("Interim Publish", "OXO Document successfully published.", "success", null);
                    location.reload(true);
                }
                else {
                    OXOAlert("Interim Publish", data.Error + "<br /><br/ ><a class='dialog-link' href='../Editor/ValidateDoc?show=both&view=&mode=g&progid=" + progId + "&docid=" + docId + "&objectid=-1'>Click here to review errors</a>", "exclamation", null);
                }
            },
            error: function (xhr, ajaxOptions, thrownError) {
                OXOAlert("Error", xhr.status, "error", null);
                OXOAlert("Error", thrownError, "error", null);
            }
        });
    }
}

function GatewayPublish() {

    var _option = new Array(5);
    var progId = $("input#ht_oxo_prog_id").val();
    var docId = $("input#ht_oxo_doc_id").val();
    var pacn = $("input#txtPACN").val();
    var comment = $("textarea#gateway-comment").val();
    var proceed = true;



    if ($.trim(pacn) == "" || $.trim(comment) == "") {
        OXOAlert("Complete Publishing", "Please supply a PACN/comment before complete publishing.", "exclamation", null);
        proceed = false;
    }

    if ($.trim(pacn).length < 8) {
        OXOAlert("Complete Publishing", "PACN number - must have a minimum 8 characters.", "exclamation", null);
        proceed = false;
    }

    if (proceed)
    {
        _option[0] = progId;
        _option[1] = docId;
        _option[2] = pacn;
        _option[3] = comment;

        var url = _pathHeader + "/Editor/ajaxGatewayPublishOXO?required=" + $.now();
        $.ajax({
            type: "POST",
            cache: false,
            url: url,
            dataType: 'json',
            data: JSON.stringify(_option),
            contentType: "application/json; charset=utf-8",
            success: function (data) {
                if (data.Success) {
                    OXOAlert("Complete Publish", "OXO Document successfully published.", "success", null);
                    location.reload(true);
                }
                else {
                    OXOAlert("Complete Publish", data.Error + "<br /><br/ ><a class='dialog-link' href='../Editor/ValidateDoc?show=both&view=&mode=g&progid=" + progId + "&docid=" + docId + "&objectid=-1'>Click here to review errors</a>", "exclamation", null);
                }
            },
            error: function (xhr, ajaxOptions, thrownError) {
                OXOAlert("Error", xhr.status, "error", null);
                OXOAlert("Error", thrownError, "error", null);
            }
        });
    }
}

