var _OXOSection = "MBM";
var _minLeftWidth = 400;

///////////////////////////////////////////////////////////
// UI functions
///////////////////////////////////////////////////////////
// editor specific
function hookupContextMenu() {

    hookupContextMenuA();
    hookupContextMenuB();

    $("div#market-editor-dialog").dialog({
        title: "Maintain Programme Market Groups",
        autoOpen: false,
        resizable: false,
        width: "340px",
        position: ["center", 100],
        show: "slide",
        hide: "slide",
        modal: true
    });

     //Do pager:
    $("#pager").pagination({
        pages: $("#pageCount").text(),
        currentPage: $.cookie('current-page'),
        edges: 1,
        hrefTextPrefix: '#',
        displayedPages: 3,
        cssStyle: 'oxo-theme',
        selectOnClick: false,
        onPageClick: function (pageNumber) {
            if (_dirtyEditor) {
                OXOAlert("Move Page", "There are unsaved changes, please save/undo your changes before moving pages.", "exclamation", null);
            }
            else {
                ShowWaitMsg();
                var progId = $("input#ht_oxo_prog_id").val();
                var docId = $("input#ht_oxo_doc_id").val();
                ajaxMBMPageGet(progId, docId, pageNumber);
                $("#pager").pagination('drawPage', pageNumber);
                //write cookies to track current page 
                $.cookie('current-page', pageNumber, { path: "/", expires: 365 });
                $("#currentPage").text(pageNumber);
            }
        }
    });

}

function hookupContextMenuA() {
    $('#oxo-core-table-A').find('td.group').contextMenu({ menu: 'oxo-market-group-menu', offsetY: -270, offsetX: -30, bubble: true }, function (action, el, pos) { performMenuAction(action, el); });
    $('#oxo-core-table-A').find('tr.oxo-data-row-2').contextMenu({ menu: 'oxo-market-menu', offsetY: -270, offsetX: -30, bubble: true }, function (action, el, pos) { performMenuAction(action, el); });    
}

function hookupContextMenuB() {
    $('#clone-oxo-core-table-B').find('tr th').contextMenu({ menu: 'oxo-model-menu', offsetY: -270, offsetX: -30, bubble: true }, function (action, el, pos) { performMenuAction(action, el); });
    $('#oxo-core-table-B').find('td.group').contextMenu({ menu: 'oxo-market-group-menu', offsetY: -270, offsetX: -30, bubble: true }, function (action, el, pos) { performMenuAction(action, el); });
    $('#oxo-core-table-B').find('tr.oxo-data-row-2').contextMenu({ menu: 'oxo-cell-menu', offsetY: -270, offsetX: -30, bubble: true }, function (action, el, pos) { performMenuAction(action, el); });
}


// editor specific
function hookupTableA() {

    var openedGroup = GetCookiesTrap(0).split(',');
    var openedSubGroup = GetCookiesTrap(1).split(',');

    _OXODataTableA = $('#oxo-core-table-A').dataTable({
        "oSearch": { "sSearch": _currentRowFilter.MBMValue },
        "bScrollCollapse": true,
        "iDisplayLength": 0,
        "bLengthChange": false,
        "bDeferRender": true,
        "bAutoWidth": false,
        "bProcessing": false,
        "bPaginate": false,
        "paging": false,
        "oLanguage": { "sSearch": "Filter&nbsp;:&nbsp;" },
        "sDom": '<"top"lpfi>rt',
        "aoColumnDefs": [
                            { "bSortable": false, "sWidth": "0px", "aTargets": [0] },
                            { "bSortable": false, "sWidth": "0px", "aTargets": [1] },
                            { "bSortable": false, "sClass": "center-no-sort", "sWidth": "60px", "aTargets": [2] },
                            { "bSortable": false, "aTargets": [3] },
                            { "bSortable": false, "bSearchable": false, "sClass": "center-no-sort", "sWidth": "60px", "aTargets": [4] },
                            { "bSortable": false, "bSearchable": false, "sClass": "center-no-sort", "sWidth": "60px", "aTargets": [5] },
                            { "bSortable": false, "sWidth": "0px", "aTargets": [6] },
                            { "bSortable": false, "sWidth": "0px", "aTargets": [7] }
                            ],
        "fnDrawCallback": function (oSettings) {
            if (_injectOXODataTitleA) {
                formatDataTable();
                _injectOXODataTitleA = false;
            }
            $('#oxo-core-table-A').find("td[data-group-level='0'], td[data-group-level='1']").each(function () {
                $(this).mousedown(function () {
                    _fireStarter = "TableA";
                })
            });

            //  $('#oxo-core-table-A').find("td[data-group-level='1']").each(function () {
            //      $(this).mousedown(function () {
            //          _fireStarter = "TableA";
            //      })
            //  });

            // $('#oxo-core-table-A').find('td.group').contextMenu({ menu: 'oxo-market-group-menu', offsetY: -270, offsetX: -30, bubble: true }, function (action, el, pos) { performMenuAction(action, el); });
            // $('#oxo-core-table-A').find('tr.oxo-data-row-2').contextMenu({ menu: 'oxo-market-menu', offsetY: -270, offsetX: -30, bubble: true }, function (action, el, pos) { performMenuAction(action, el); });

            // $('#oxo-core-table-B').find('td.group').contextMenu({ menu: 'oxo-market-group-menu', offsetY: -270, offsetX: -30, bubble: true }, function (action, el, pos) { performMenuAction(action, el); });            
            // $('#clone-oxo-core-table-B').find('tr th').contextMenu({ menu: 'oxo-model-menu', offsetY: -230, offsetX: -44, bubble: true }, function (action, el, pos) { performMenuAction(action, el); });           
            // $('#oxo-core-table-B').find('tr.oxo-data-row-2').contextMenu({ menu: 'oxo-cell-menu', offsetY: -270, offsetX: -30, bubble: true }, function (action, el, pos) { performMenuAction(action, el); });
            hookupContextMenuA();

        }
    }).rowGrouping({
        bExpandableGrouping: true,
        asExpandedGroups: openedGroup,
        asExpandedGroups2: openedSubGroup,
        iGroupingOrderByColumnIndex: 0,
        iGroupingColumnIndex: 1,
        bExpandableGrouping2: true,
        iGroupingColumnIndex2: 6,
        iGroupingOrderByColumnIndex2: 7,
        fnAfterGroupClicked: function (sGroup, iGroupLevel, sState) {
            if (_fireStarter == "TableA")
                SetCookieTrap(sGroup, iGroupLevel, sState);
            SyncHeader('B', sGroup, sState);
            ResizeMeEditor();
        }
    });

}

function hookupTableB() {

    var openedGroup = GetCookiesTrap(0).split(',');
    var openedSubGroup = GetCookiesTrap(1).split(',');

    _OXODataTableB = $('#oxo-core-table-B').dataTable({
        "oSearch": { "sSearch": _currentRowFilter.MBMValue },
        "bScrollCollapse": true,
        "iDisplayLength": 0,
        "bLengthChange": false,
        "bDeferRender": true,
        "bAutoWidth": false,
        "bProcessing": false,
        "bPaginate": false,
        "paging": false,
        "oLanguage": { "sSearch": "Filter&nbsp;:&nbsp;" },
        "aoColumnDefs": [{ "bVisible": false,  "aTargets": [2] }],
        "sDom": '<"top"lpfi>rt',

        "fnDrawCallback": function (oSettings) {

            if (_injectOXODataTitleB) {
                formatDataTable();
                _injectOXODataTitleB = false;
            }

            $('#oxo-core-table-B').find("td[data-group-level='0'],td[data-group-level='1']").each(function () {
                $(this).mousedown(function () {
                    _fireStarter = "TableB";
                })
            });
            
            $("table#oxo-core-table-B td.group-item-expander").each(function () {
                var group = $(this).attr("data-group");
                $(this).text('');
                $(this).css("padding", "0px");
            });

            hookupContextMenuB();

        }
    }).rowGrouping({
        bExpandableGrouping: true,
        asExpandedGroups: openedGroup,
        asExpandedGroups2: openedSubGroup,
        iGroupingOrderByColumnIndex: 0,
        iGroupingColumnIndex: 1,
        bExpandableGrouping2: true,
        iGroupingColumnIndex2: 3,
        iGroupingOrderByColumnIndex2: 4,
        fnAfterGroupClicked: function (sGroup, iGroupLevel, sState) {
            if(_fireStarter == "TableB")
                SetCookieTrap(sGroup, iGroupLevel, sState);
            SyncHeader('A', sGroup, sState);
            ResizeMeEditor();
        }
    });

}

function performMenuAction(action, el) {
    _currentNode = el;
    switch (action) {
        case "track-oxo":
            if (_trackLine) {
                $("a#track1").text("Turn Tracking On");
                $.cookie("tracking", "off", { expires: 365 });
            }
            else {
                $("a#track1").text("Turn Tracking Off");
                $.cookie("tracking", "on", { expires: 365 });
            }
            _trackLine = !_trackLine;
            break;
        case "set-all-model":
            var modelid = $(_currentNode).attr("data");
            bulkOperationWrapper(true, modelid, 0, "");
            break;
        case "clear-all-model":
            var modelid = $(_currentNode).attr("data");
            bulkOperationWrapper(false, modelid, 0, "");
            break;
        case "set-all-market":
            var marketid = $(_currentNode).attr("marketid");
            bulkOperationWrapper(true, 0, marketid, "");
            break;
        case "clear-all-market":
            var marketid = $(_currentNode).attr("marketid");
            bulkOperationWrapper(false, 0, marketid, "");
            break;
        case "set-all-block":
            var group = $(_currentNode).attr("data-group");
            bulkOperationWrapper(true, 0, 0, group);
            break;
        case "clear-all-block":
            var group = $(_currentNode).attr("data-group");
            bulkOperationWrapper(false, 0, 0, group);
            break;
        case "history-oxo":
            var modelId = $(_whichCell).attr("modelid");
            var marketId = $(_whichCell).attr("marketid");
            var docId = $("input#ht_oxo_doc_id").val();
            var docTitle = $("div#dtable-title").text();
            showChangeHistoryDialog(docId, modelId, marketId, 0, 0, docTitle);
            break;
        case "select-model":
            showSelectModelDialog();
            break;
        case "open-fbm":
            var objectId = 0;
            var url = "";
            var progId = $("input#ht_oxo_prog_id").val();
            var docId = $("input#ht_oxo_doc_id").val();
            if ($(_currentNode).hasClass("group")) {
                var key = $(_currentNode).attr("data-group")
                objectId = $("table#oxo-core-table-A").find("tr.group-item-" + key).first().next().attr("groupid");
                url = _pathHeader + "/Editor/FBM?mode=mg&progid=" + progId + "&docid=" + docId + "&objectid=" + objectId;
                window.open(url)
            }
            else {
                objectId = $(_currentNode).attr("marketid");
                url = _pathHeader + "/Editor/FBM?mode=m&progid=" + progId + "&docid=" + docId + "&objectid=" + objectId;
                window.open(url)
            }
            break;
        case "copy-col":
            var modelid = $("table#clone-oxo-core-table-B th.selected").attr("data");
            _copiedColumnCells = $("td[modelid='" + modelid + "']");
            $("li#paste-column").show();
            break;
        case "paste-col":
            //   OXOConfirm("Copy Column", "Are you sure you want to copy column and overwrite the existing values?", "question", null);
            var modelid = $("table#clone-oxo-core-table-B th.selected").attr("data");
            if (_copiedColumnCells != null) {
                for (var i = 0; i < _copiedColumnCells.length; i++) {
                    var bTicked = $(_copiedColumnCells[i]).hasClass("ticked");
                    var marketid = $(_copiedColumnCells[i]).attr("marketid");
                    var selector = "table#oxo-core-table-B td[modelid='" + modelid + "'][marketid='" + marketid + "']";
                    var ele = $(selector);
                    cellClick(ele, bTicked);
                }
            }
            break;
        case "copy-row":
            var rowid = $(_currentNode).attr("uniqueid");
            _copiedRowCells = $("table#oxo-core-table-B tr.oxo-data-row-2[uniqueid='" + rowid + "'] td");
            $("li#paste-row").show();
            break;
        case "paste-row":
            var rowid = $(_currentNode).attr("uniqueid");
            var bRow = $("table#oxo-core-table-B tr.oxo-data-row-2[uniqueid='" + rowid + "']");
            if (_copiedRowCells != null) {
                for (var i = 0; i < _copiedRowCells.length; i++) {
                    var bTicked = $(_copiedRowCells[i]).hasClass("ticked");
                    var modelid = $(_copiedRowCells[i]).attr("modelid");
                    var ele = $(bRow).find("td[modelid='" + modelid + "']");
                    cellClick(ele, bTicked);
                }
            }
            break;
        case "add-market":
            var groupid = $(_currentNode).attr("groupid");
            var marketid = $(_currentNode).attr("marketid");
            launchMarketGroupDialog("market_add", groupid, marketid);
            break;
        case "edit-market":
            var groupid = $(_currentNode).attr("groupid");
            var marketid = $(_currentNode).attr("marketid");
            launchMarketGroupDialog("market_move", groupid, marketid);
            break;
        case "remove-market":
            if (_dirtyEditor) {
                var msg = "There are unsaved changes, please save/undo your changes before removing market.";
                OXOAlert("Remove Market", msg, "exclamation", null);
            }
            else {
                var msg = "Are you sure you want to remove the following market from this programme?";
                msg = msg + "<br/><b>" + $(el).html() + "</b>";
                OXOConfirm("Remove Market", msg, "question", RemoveMarketWrapper);
            }
            break;
    }
}

function RemoveMarketWrapper() {
    var progid = $("input#ht_oxo_prog_id").val();
    var marketid = $(_currentNode).attr("marketid");
    ajaxRemoveMarket(progid, marketid);
}

function cellClick(el, setValue) {
    if (!$(el).hasClass("group") && !$(el).hasClass("subgroup")) {
        // need to find ou what the model count is
        var marketid = $(el).attr("marketid");
        var isTicked;

        if (setValue == null)
            isTicked = $(el).hasClass("ticked");
        else
            isTicked = !setValue;

        if (isTicked) {
            $(el).removeClass("ticked").addClass("unticked");
            if ($(el).attr("prevval") == "Y") {
                $(el).addClass("isDirty");
            }
            else {
                $(el).removeClass("isDirty");
            }
        }
        else {
            $(el).removeClass("unticked").addClass("ticked");
            if ($(el).attr("prevval") == "") {
                $(el).addClass("isDirty");
            }
            else {
                $(el).removeClass("isDirty");
            }
        }

        var uniqueid = $(el).parent().attr("uniqueid");
        var modelid = $(el).attr("modelid");
        UpdateModelCount(uniqueid, !isTicked);
        UpdateMarketCount(modelid);
        var state = ($("#oxo-core-table-B td.isDirty").length > 0);
        ToggleSaveButtons(state);

    }
}

function ToggleSaveButtons(state) {
    if (state) {
        _dirtyEditor = true;
        $("a#butSaveChange,a#butCancelChange").show();
    }
    else {
        _dirtyEditor = false;
        $("a#butSaveChange,a#butCancelChange").hide();
    }
}


function cellBulkClick(el, bTicked) {

    var uniqueid = $(el).parent().attr("uniqueid");
    var modelid = $(el).attr("modelid");
    var marketid = $(el).attr("marketid");
    var isTicked = $(el).hasClass("ticked");
    if (isTicked && !bTicked) {
        $(el).removeClass("ticked").addClass("unticked");
        if ($(el).attr("prevval") != "") {
            $(el).addClass("isDirty");
            UpdateModelCount(uniqueid, false);
        }
        else {
            $(el).removeClass("isDirty");
            UpdateModelCount(uniqueid, false);
        }
    }
    if (!isTicked && bTicked) {
        $(el).removeClass("unticked").addClass("ticked");        
        if ($(el).attr("prevval") != "Y") {
            $(el).addClass("isDirty");
            UpdateModelCount(uniqueid, true);
        }
        else {
            $(el).removeClass("isDirty");
            UpdateModelCount(uniqueid, true);
        }
    }



    UpdateMarketCount(modelid);

    var state = ($("#oxo-core-table-B td.isDirty").length > 0);
    ToggleSaveButtons(state);


}

function bulkOperationWrapper(bTicked, modelid, marketid, group) {
    ShowWaitMsg();
    setTimeout(function () { bulkOperation(bTicked, modelid, marketid, group); }, 500);
}

function bulkOperation(bTicked, modelid, marketid, group) {

    if (group == "") {
        var cells;
        if(modelid!=0)
            cells = $("#oxo-core-table-B td[modelid='" + modelid + "']").filter(":visible");
        else
            cells = $("#oxo-core-table-B td[marketid='" + marketid + "']").filter(":visible");
       
        cells.each(function () {
            cellBulkClick($(this), bTicked);
        });
    }
    else {
        var cells = $("#oxo-core-table-B tr.group-item-" + group + " td").filter(":visible");
        cells.each(function () {
            cellBulkClick($(this), bTicked);
        });
    }

    HideWaitMsg();
}

function ajaxRemoveMarket(progid, marketid) {
    var url = _pathHeader + "/Editor/ajaxRemoveMarketForProg?progid=" + progid + "&marketid=" + marketid + " &required=" + (new Date()).getTime();
    $.ajax({
        type: "GET",
        cache: false,
        url: url,
        contentType: "application/json; charset=utf-8",
        success: function (data) {
            if (data.Success) {
                location.reload(true);
            }
            else {
                OXOAlert("Error", "Remove market failed." + data.Error, "error", null);
            }
        },
        error: function (xhr, ajaxOptions, thrownError) {
            OXOAlert("Error", xhr.status, "error", null);
            OXOAlert("Error", thrownError, "error", null);
        }
    });
}

function ExportExcel(progid, docid) {
    _showWaitFlag = false;
    url = _pathHeader + "/Editor/ExcelExport?progid=" + progid + "&docid=" + docid
    window.location.href = url;
}

function UpdateModelCount(uniqueid, bTicked) {

    var counter = $("#oxo-core-table-A tr[uniqueid='" + uniqueid + "'] td.variant-count");
    //var count = $("#oxo-core-table-B tr[uniqueid='" + uniqueid + "'] td.ticked").length;
    var prevCount = parseInt(counter.text());
    if (bTicked)
        prevCount++;
    else
        prevCount--;
    counter.text(prevCount);
}

function UpdateMarketCount(modelid) {

    var counter = $("#clone-oxo-core-table-B thead tr.countries-count-B th[modelid='" + modelid + "']");
    var count = $("#oxo-core-table-B tr td.ticked[modelid='" + modelid + "']").length;
    counter.text(count);

}


function postProcessing() {
    /*var rows = $("#oxo-core-table-A tr");
    for (var i = 0; i < rows.length; i++) {
        var attr = $(rows[i]).attr('uniqueid');
        if (typeof attr !== typeof undefined && attr !== false) {
            UpdateModelCount(attr);
        }
    }*/

    $("#clone-oxo-core-table-B tr.countries-count-B th").each(function () {
        var modelid = $(this).attr("modelid");
        UpdateMarketCount(modelid);
    });
}

function launchMarketGroupDialog(mode, groupId, marketId) {
    setDialogValue(mode, groupId, marketId);
    switch (mode) {
        case "market_move":
            $("div#market-editor-dialog").dialog('option', 'width', 336);
            break;
        case "market_add":
            $("div#market-editor-dialog").dialog('option', 'width', 417);
            break;
    }
    $("div#market-editor-dialog").dialog("open");
}

function setDialogValue(mode, groupId, marketId) {

    var url = _pathHeader + "/Editor/ajaxMarketGroupMarketEditor?mode=" + mode + "&groupId=" + groupId + "&marketId=" + marketId + "&required=" + $.now();
    $.ajax({ type: "GET",
        url: url,
        async: false,
        success: function (html) {
            $("div#market-editor-dialog").find("div#form-placeholder").html(html);
            //     hookupMarketGroupAjax();
            //    hookupValidator();
        },
        error: function (xhr, ajaxOptions, thrownError) {
            alert(xhr.status);
            alert(thrownError);
        }
    });
}

function GetCookiesTrap(iGroupLevel) {
    return $.cookie("EDTMBMCookie" + iGroupLevel) == null ? "" : $.cookie("EDTMBMCookie" + iGroupLevel);
}

function SetCookieTrap(sGroup, iGroupLevel, state) {

    var cookieDude = GetCookiesTrap(iGroupLevel)

    if (state == "Close") {
        var cookieTrack = cookieDude;
        var testMe = '' + sGroup + ',';
        var res = cookieTrack.replace(testMe, '');
        $.cookie("EDTMBMCookie" + iGroupLevel, res, { path: "/", expires: 365 })
        if (iGroupLevel == 0) {
            //clear any sub level cookie here two
            subCookieDude = GetCookiesTrap(1);
            var array = subCookieDude.split(',');
            array = $.grep(array, function (value) {
                return value.indexOf(sGroup) < 0;
            });
            subCookieDude = array.join(",");
            $.cookie("EDTMBMCookie1", subCookieDude, { path: "/", expires: 365 })
        }
    }
    if (state == "Open") {
        var cookieTrack = cookieDude;
        var testMe = '' + sGroup + ',';
        if (cookieTrack.indexOf(testMe) == -1) {
            cookieTrack = cookieTrack + testMe;
            $.cookie("EDTMBMCookie" + iGroupLevel, cookieTrack, { path: "/", expires: 365 })
        }
    }
}

function ajaxMBMPageGet(progid, docid, page) {
    var url = _pathHeader + "/Editor/AjaxMBM?progid=" + progid + "&docid=" + docid + "&page=" + page + " &required=" + (new Date()).getTime();
    $.ajax({
        type: "GET",
        cache: false,
        url: url,
        contentType: "application/json; charset=utf-8",
        success: function (data) {
            $("#right-pane").html(data);
            hookupTableB();
            CloneHeaderB();
            var headerHeight = $('#oxo-core-table-B thead').height() + 1;
            $('#oxo-core-table-B').css("top", "-" + headerHeight + 'px');
            //need to re-hook all the events  
            postProcessing();
            hookupContextMenuB();
            hookupOtherEventsB();
            if ($('#ht_do_click').val() == 1)
                hookupClickEvent();
            var paneWidth = $('#ht_parent_width').val();
            $("#right-pane-header").width(paneWidth);
            $("#right-pane").width(paneWidth);
            ResizeMeEditor();
            var resetCookies = $("ht_clear_page_cookie").val();
            if(resetCookies == 1)
                $.cookie('current-page', 1, { path: "/", expires: 365 });
        },
        error: function (xhr, ajaxOptions, thrownError) {
            OXOAlert("Error", xhr.status, "error", null);
            OXOAlert("Error", thrownError, "error", null);
        }
    });
}





