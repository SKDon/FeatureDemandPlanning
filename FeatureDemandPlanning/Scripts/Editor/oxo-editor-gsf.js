var _OXOSection = "GSF";
var _minLeftWidth = 500;

///////////////////////////////////////////////////////////
// UI functions
///////////////////////////////////////////////////////////
// editor specific
function hookupContextMenu() {

    $('body').click(function () { $("ul.sm-nowrap").hide(); });

    $('#clone-oxo-core-table-B').find('tr th').contextMenu({ menu: 'oxo-model-menu', offsetY: -270, offsetX: -30, bubble: true }, function (action, el, pos) { performMenuAction(action, el); });
    $('#oxo-core-table-A').find('tr.oxo-data-row-2:not([data-group^="option-packs"])').each(
        function () {
            if ($(this).attr("featureid") != "-1000") {
                $(this).contextMenu({ menu: 'oxo-feature-menu', offsetY: -270, offsetX: -30, bubble: true }, function (action, el, pos) { performMenuAction(action, el); });
            }
            else {
                $(this).contextMenu({ menu: 'oxo-feature-addonly-menu', offsetY: -270, offsetX: -30, bubble: true }, function (action, el, pos) { performMenuAction(action, el); });
            }
        }
    );
    $('#oxo-core-table-B').find('tr.oxo-data-row-2:not([data-group^="option-packs"])').each(
        function () {
            if ($(this).find('td').attr("featureid") != "-1000") {
                $(this).contextMenu({ menu: 'oxo-cell-menu', offsetY: -270, offsetX: -30, bubble: true }, function (action, el, pos) { performMenuAction(action, el); });
            }
        }
    );
   
    $("div#show-comment-dialog").dialog({
        title: "Feature Comment",
        autoOpen: false,
        resizable: false,
        width: "500px",
        position: ["center", 200],
        show: "slide",
        hide: "slide",
        modal: true
    });

    $("#show-rule-text-dialog").dialog({
        title: "Feature Rule",
        autoOpen: false,
        resizable: false,
        width: "500px",
        position: ["center", 200],
        show: "slide",
        hide: "slide",
        modal: true,
        open: function (event, ui) { $('#feature-rule-text').focus(); }
    });

}

// editor specific
function hookupTableA() {

    var openedGroup = GetCookiesTrap(0).split(',');
    var openedSubGroup = GetCookiesTrap(1).split(',');

    _OXODataTableA = $('#oxo-core-table-A').dataTable({
        "oSearch": { "sSearch": _currentRowFilter.GSFValue },
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
                            { "bSortable": false, "bSearchable": false, "sWidth": "0px", "aTargets": [0] },
                            { "bSortable": false, "bSearchable": true, "sWidth": "0px", "aTargets": [1] },
                            { "bSortable": false, "bVisible": false, "bSearchable": true, "sWidth": "0px", "aTargets": [2] },
                            { "bSortable": false, "bSearchable": false, "aTargets": [3] },
                            { "bSortable": false, "bSearchable": false, "sClass": "right-aligned", "sWidth": "80px", "aTargets": [4] },
                            { "bSortable": false, "bSearchable": true, "sClass": "center-no-sort", "sWidth": "60px", "aTargets": [5] },
                            { "bSortable": false, "bSearchable": true, "sWidth": "0px", "aTargets": [6] }
                         ],
        "fnDrawCallback": function (oSettings) {
            if (_injectOXODataTitleA) {
                formatDataTable();
                _injectOXODataTitleA = false;
            }
            $('#oxo-core-table-A').find("td[data-group-level='0']").each(function () {

                $(this).mousedown(function () {
                    _fireStarter = "TableA";
                })
            });
            $('#oxo-core-table-A').find("td[data-group-level='1']").each(function () {

                $(this).mousedown(function () {
                    _fireStarter = "TableA";
                })
            });


            hideSubGroupHeader();

        }
    }).rowGrouping({
        bExpandableGrouping: true,
        asExpandedGroups: openedGroup,
        asExpandedGroups2: openedSubGroup,
        iGroupingOrderByColumnIndex: 0,
        iGroupingColumnIndex: 1,
        bExpandableGrouping2: true,
        iGroupingColumnIndex2: 6,
        fnAfterGroupClicked: function (sGroup, iGroupLevel, sState) {
            if (_fireStarter == "TableA")
                SetCookieTrap(sGroup, iGroupLevel, sState, 'A');
            SyncHeader('B', sGroup, sState);
            ResizeMeEditor();
        }
    });



    $("span.info-indicator").tipsy({
        opacity: 0.98,
        gravity: 's',
        width: '320px',
        delayIn: 400,
        html: true,
        title: function () {
            var progId = $("input#ht_oxo_prog_id").val();
            var docId = $("input#ht_oxo_doc_id").val();
            var featureId = $(this).attr("featureid");
            return getGSFCommentToolTip(progId, docId, featureId);
        }
    });

    $("span.rule-indicator").tipsy({
        opacity: 0.98,
        gravity: 's',
        width: '320px',
        delayIn: 400,
        html: true,
        title: function () {
            var progId = $("input#ht_oxo_prog_id").val();
            var docId = $("input#ht_oxo_doc_id").val();
            var featureId = $(this).attr("featureid");
            return getGSFRuleToolTip(progId, docId, featureId);
        }
    });

    $("img.long-indicator").tipsy({
        opacity: 0.98,
        gravity: 's',
        width: '320px',
        delayIn: 400,
        html: true,
        title: function () {

            var html = "";
            html = html + "<tr>";
            html = html + "<td style='vertical-align:top;width:22px;'><img src='" + _pathHeader + "/Content/Images/Editor/info-icon-2.png' /></td>";
            html = html + "<td>" + $(this).attr("data") + "</td>";
            html = html + "</tr>";
            return html;
        }
    });

}

function hookupTableB() {

    var openedGroup = GetCookiesTrap(0).split(',');
    var openedSubGroup = GetCookiesTrap(1).split(',');

    _OXODataTableB = $('#oxo-core-table-B').dataTable({
        "oSearch": { "sSearch": _currentRowFilter.GSFValue },
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
                            { "bSortable": false, "bSearchable": true, "aTargets": [1] },
                            { "bSortable": false, "bVisible": false, "bSearchable": true, "aTargets": [2] },
                            { "bSortable": false, "bSearchable": true, "aTargets": [3] }
                         ],
        "fnDrawCallback": function (oSettings) {

            if (_injectOXODataTitleB) {
                formatDataTable();
                _injectOXODataTitleB = false;
            }

            $('#oxo-core-table-B').find("td[data-group-level='0']").each(function () {

                $(this).mousedown(function () {
                    _fireStarter = "TableB";
                })
            });

            $('#oxo-core-table-B').find("td[data-group-level='1']").each(function () {

                $(this).mousedown(function () {
                    _fireStarter = "TableB";
                })
            });

            $("table#oxo-core-table-B td.group-item-expander").each(function () {
                var group = $(this).attr("data-group");
                $(this).text('');
                $(this).css("padding", "0px");


            });

            hideSubGroupHeader();


        }
    }).rowGrouping({
        bExpandableGrouping: true,
        asExpandedGroups: openedGroup,
        asExpandedGroups2: openedSubGroup,
        iGroupingOrderByColumnIndex: 0,
        iGroupingColumnIndex: 1,
        bExpandableGrouping2: true,
        iGroupingColumnIndex2: 3,
        fnAfterGroupClicked: function (sGroup, iGroupLevel, sState) {
            if (_fireStarter == "TableB")
                SetCookieTrap(sGroup, iGroupLevel, sState, 'B');
            SyncHeader('A', sGroup, sState);         
            ResizeMeEditor();
        }
    });


}

function performMenuAction(action, el) {
    _currentNode = el;
    var whichTag = $(el).prop("tagName");
    switch (action) {
        case "edit-oxo":
            url = _pathHeader + "/Editor/" + $(el).attr('data') + "/" + $(el).attr('rowid')
            window.location.href = url;
            break;
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
            var msg = "Would you like to overwrite existing values in this column? If you choose 'No', only blank cells will be updated.";
            OXOYesNo("Set All", msg, 'question', BulkModelOverwriteOpsWrapper, BulkModelOpsWrapper);
            break;
        case "clear-all-model":
            var modelid = $(_currentNode).attr("data");
            bulkOperationWrapper(false, modelid, 0);
            break;
        case "set-all-feature":
            var msg = "Would you like to overwrite existing values in this row? If you choose 'No', only blank cells will be updated.";
            OXOYesNo("Set All", msg, 'question', BulkFeatureOverwriteOpsWrapper, BulkFeatureOpsWrapper);
            break;
        case "clear-all-feature":
            var featureid = $(_currentNode).attr("featureid");
            bulkOperationWrapper(false, 0, featureid);
            break;
        case "history-oxo":
            var marketId = 0;
            var marketGroupId = 0;
            var modelId = $(_whichCell).attr("modelid");
            var featureId = $(_whichCell).attr("featureid");
            var docId = $("input#ht_oxo_doc_id").val();
            var docTitle = $("div#dtable-title").text();
            var marketId = -1;
            showChangeHistoryDialog(docId, modelId, marketId, marketGroupId, featureId, docTitle);
            break;       
        case "select-model":
            showSelectModelDialog();
            break;
        case "set-standard":
            var ctl = _whichCell;
            if (whichTag == "TD") { ctl = el; }
            if ($(ctl).text() != "S") {
                $(ctl).text("S");
                setDirty(ctl);
            }
            break;
        case "set-optional":
            var ctl = _whichCell;
            if (whichTag == "TD") { ctl = el; }
            if ($(ctl).text() != "O") {
                $(ctl).text("O");
                setDirty(ctl);
            }
            break;
        case "set-na":
            var ctl = _whichCell;
            if (whichTag == "TD") { ctl = el; }
            if ($(ctl).text() != "NA") {
                $(ctl).text("NA");
                setDirty(ctl);
            }
            break;
        case "set-linked":
            var ctl = _whichCell;
            if (whichTag == "TD") { ctl = el; }
            if ($(ctl).text() != "(O)") {
                $(ctl).text("(O)");
                setDirty(ctl);
            }
            break;
        case "set-pack":
            var ctl = _whichCell;
            if (whichTag == "TD") { ctl = el; }
            if ($(ctl).text() != "P") {
                $(ctl).text("P");
                setDirty(ctl);
            }
            break;
        case "clear-cell":
            var ctl = _whichCell;
            if (whichTag == "TD") { ctl = el; }
            $(ctl).text("");
            setDirty(ctl);
            break;
        case "add-feature":
            if (_dirtyEditor) {
                var msg = "There are unsaved changes, please save/undo your changes before adding feature.";
                OXOAlert("Add Feature", msg, "exclamation", null);
            }
            else {
                var vehicleId = $("input#ht_oxo_veh_id").val();
                var progId = $("input#ht_oxo_prog_id").val();
                var docId = $("input#ht_oxo_doc_id").val();
                var rowIndex = _OXODataTableA.fnGetPosition($(el).closest('tr')[0]);
                var aData = _OXODataTableA.fnGetData(rowIndex);
                var group = aData[1];
                launchFeatureLookUpDialogs("gsf", vehicleId, progId, docId, group, AddFeaturesToProg);
            }
            break;
        case "remove-feature":
            if (_dirtyEditor) {
                var msg = "There are unsaved changes, please save/undo your changes before removing feature.";
                OXOAlert("Remove Feature", msg, "exclamation", null);
            }
            else {
                var feature = $(_currentNode).find("td:eq(0)").text();
                feature = feature.replace(/^\s+|\s+$/g, '').replace(/Rule$/g, '');
                var msg = "Are you sure you want to remove the following Global Standard Feature from this OXO?<br/><br/>";
                msg = msg + "<b>" + feature + "</b>";
                OXOConfirm("Remove Feature", msg, "question", RemoveFeatureWrapper);
            }
            break;      
        case "copy-col":
            var modelid = $("table#clone-oxo-core-table-B th.selected").attr("data");
            _copiedColumnCells = $("td.oxo-data[modelid='" + modelid + "'][packid='0']");
            $("li#paste-column").show();
            break;
        case "paste-col":
            //   OXOConfirm("Copy Column", "Are you sure you want to copy column and overwrite the existing values?", "question", null);
            var modelid = $("table#clone-oxo-core-table-B th.selected").attr("data");
            if (_copiedColumnCells != null) {
                for (var i = 0; i < _copiedColumnCells.length; i++) {
                    var value = $(_copiedColumnCells[i]).html();
                    if (value.indexOf("sub") == -1) {
                        var featureid = $(_copiedColumnCells[i]).attr("featureid");
                        //  var packid = $(_copiedColumnCells[i]).attr("packid");
                        var selector = "table#oxo-core-table-B td.oxo-data[modelid='" + modelid + "'][featureid='" + featureid + "'][packid='0']";
                        var ele = $(selector);
                        cellClick(ele, value);
                    }
                }
            }
            break;
        case "copy-row":
            var rowid = $(_currentNode).attr("uniqueid");
            _copiedRowCells = $("table#oxo-core-table-B tr.oxo-data-row-2[uniqueid='" + rowid + "'] td.oxo-data");
            $("li#paste-row").show();
            break;
        case "paste-row":
            var rowid = $(_currentNode).attr("uniqueid");
            var bRow = $("table#oxo-core-table-B tr.oxo-data-row-2[uniqueid='" + rowid + "']");
            if (_copiedRowCells != null) {
                for (var i = 0; i < _copiedRowCells.length; i++) {
                    var value = $(_copiedRowCells[i]).html();
                    if (value.indexOf("sub") == -1) {
                        var modelid = $(_copiedRowCells[i]).attr("modelid");
                        var packid = $(_copiedRowCells[i]).attr("packid");
                        var ele = $(bRow).find("td.oxo-data[modelid='" + modelid + "'][packid='" + packid + "']");
                        cellClick(ele, value);
                    }
                }
            }
            break;
        case "edit-comment":
            var progid = $("input#ht_oxo_prog_id").val();
            var docid = $("input#ht_oxo_doc_id").val();
            var featureid = $(_currentNode).find("td:eq(0)").attr("featureid");
            var progName = $("div#dtable-title").text();
            $("span#feature-comment-name").val("");
            $("textarea#feature-comment").val("");
            ajaxGetFeatureComment(progid, docid, featureid);
            $("div#show-comment-dialog").dialog({ title: "Edit Comment - " + progName });
            $("div#show-comment-dialog").dialog("open");
            break;

        case "edit-rule-text":
            var progid = $("input#ht_oxo_prog_id").val();
            var docid = $("input#ht_oxo_doc_id").val();
            var featureid = $(_currentNode).find("td:eq(0)").attr("featureid");
            var progName = $("div#dtable-title").text();
            $("span#feature-rule-name").val("");
            $("textarea#feature-rule-text").val("");
            //Call ajax to get comment data
            ajaxGetFeatureRuleText(progid, docid, featureid);
            $("div#show-rule-text-dialog").dialog({ title: "Edit Rule - " + progName });
            $("div#show-rule-text-dialog").dialog("open");
            break;

    }
}

function BulkModelOpsWrapper() {
    var modelid = $(_currentNode).attr("data");
    bulkOperation(true, modelid, 0);
}

function BulkFeatureOpsWrapper() {
    var featureid = $(_currentNode).attr("featureid");
    bulkOperation(true, 0, featureid);
}

function BulkModelOverwriteOpsWrapper() {
    var modelid = $(_currentNode).attr("data");
    bulkOperationWithOverwrite(true, modelid, 0);
}

function BulkFeatureOverwriteOpsWrapper() {
    var featureid = $(_currentNode).attr("featureid");
    bulkOperationWithOverwrite(true, 0, featureid);
}

function RemoveFeatureWrapper() {
    var docid = $("input#ht_oxo_doc_id").val();
    var progid = $("input#ht_oxo_prog_id").val();
    var featid = $(_currentNode).find("td:eq(0)").attr("featureid")
    ajaxRemoveFeature(docid, progid, featid);
}

function AddFeaturesToProg() {

    var progId = $("input#ht_oxo_prog_id").val();
    var docId = $("input#ht_oxo_doc_id").val();

    var url = _pathHeader + "/Editor/ajaxAddGSFProg?docid=" + docId + "&progid=" + progId + "&required=" + (new Date()).getTime();
    $.ajax({
        type: "POST",
        cache: false,
        url: url,
        dataType: 'json',
        data: _selectedFeature().stringify(),
        contentType: "application/json; charset=utf-8",
        success: function (data) {
            if (data.Success) {
                location.reload(true);
            }
            else {
                var msg = "Error adding features. " + data.Error;
                OXOAlert("Error", msg, "error", null);
            }
        },
        error: function (xhr, ajaxOptions, thrownError) {
            alert(xhr.status);
            alert(thrownError);
        }
    });
}

function ajaxRemoveFeature(docid, progid, featid) {
    var url = _pathHeader + "/Editor/ajaxRemoveGSFForProg?docid=" + docid + "&progid=" + progid + "&featid=" + featid + " &required=" + (new Date()).getTime();
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
                var msg = "Remove feature failed. " + data.Error;
                OXOAlert("Error", msg, "error", null);
            }
        },
        error: function (xhr, ajaxOptions, thrownError) {
            OXOAlert("Error", xhr.status, "error", null);
            OXOAlert("Error", thrownError, "error", null);
        }
    });
}

function cellClick(ele, setValue) {

    var inputMode;

    if (setValue == null)
        inputMode = $("a#selectedMode").attr("data");
    else
        inputMode = setValue;

    if (!$(ele).hasClass("group") && !$(ele).hasClass("subgroup")) {
        // now check if this is locked or suggested data
        if ($(ele).hasClass("locked")) {
            var msg = "According to the Derivative by Market Listing of this OXO Document, this derivative is not availble for the select market."
            OXOAlert("Change Value", msg, "exclamation", null);
        }
        else {
            if ($(ele).hasClass("generic")) {
                $(ele).removeClass("generic").addClass("prev-generic");
                //$(ele).text($(ele).text().replace('*', ''));
                $(ele).text(inputMode);
                $(ele).addClass("isDirty");
            }
            else if ($(ele).hasClass("mglevel")) {
                $(ele).removeClass("mglevel").addClass("prev-mglevel");
                //$(ele).text($(ele).text().replace('**', ''));
                $(ele).text(inputMode);
                $(ele).addClass("isDirty");
            }
            else {
                if ($(ele).text() == "" || inputMode.toLowerCase() != $(ele).text().toLowerCase()) {
                    if ($(ele).hasClass("isDirty") && setValue == null) {
                        var preCode = $(ele).attr("prevval");
                        dealWithInheritance(ele, preCode);
                    }
                    else {
                        $(ele).text(inputMode);
                    }
                }
                else {

                    var preCode = $(ele).attr("prevval");
                    dealWithInheritance(ele, preCode);
                }

                var preCode = $(ele).attr("prevval");
                if ($(ele).html().toLowerCase() == translateCode(preCode).toLowerCase())
                    $(ele).removeClass("isDirty");
                else
                    $(ele).addClass("isDirty");
            }
        }

        ToggleSaveButtons();
    }
}

function dealWithInheritance(ele, precode) {
    if ($(ele).hasClass("prev-generic")) {
        var preCode = $(ele).attr("prevval")
        preCode = translateCode(preCode);
        $(ele)[0].innerHTML = preCode;
        $(ele).removeClass("isDirty");
        $(ele).addClass("generic")
    }
    if ($(ele).hasClass("prev-mglevel")) {
        var preCode = $(ele).attr("prevval")
        preCode = translateCode(preCode);
        $(ele)[0].innerHTML = preCode;
        $(ele).removeClass("isDirty");
        $(ele).addClass("mglevel")
    }
    if (!($(ele).hasClass("prev-generic") || $(ele).hasClass("prev-mglevel"))) {
        var preCode = $(ele).attr("prevval")
        preCode = translateCode(preCode);
        $(ele).text(preCode);
        $(ele).removeClass("isDirty");
    }
}

function cellBulkClick(ele, bTicked, overwrite) {

    var inputMode = $("a#selectedMode").attr("data");
    if (!$(ele).hasClass("locked")) {
        if ($(ele).hasClass("generic")) { $(ele).removeClass("generic").addClass("prev-generic") };
        if ($(ele).hasClass("mglevel")) { $(ele).removeClass("mglevel").addClass("prev-mglevel") };
        hasValue = ($(ele).text() != "" && !overwrite);
        if (hasValue && !bTicked) {
            $(ele).text("");
            if ($(ele).text() != $(ele).attr("prevval"))
                $(ele).addClass("isDirty");
            else
                $(ele).removeClass("isDirty");
        }
        if (!hasValue && bTicked) {
            $(ele).text(inputMode);
            if ($(ele).text() != $(ele).attr("prevval"))
                $(ele).addClass("isDirty");
            else
                $(ele).removeClass("isDirty");
        }

        var state = ($("#oxo-core-table-B td.isDirty").length > 0);
        ToggleSaveButtons();
    }
}

function bulkOperationWrapper(value, modelid, featureid) {
    ShowWaitMsg();
    setTimeout(function () { bulkOperation(value, modelid, featureid); }, 500);
}

function bulkOperation(value, modelid, featureid) {

    var cells;
    if (modelid != 0)
        cells = $("#oxo-core-table-B td[modelid='" + modelid + "'][featureid!='-1000']").filter(":visible");
    else
        cells = $("#oxo-core-table-B td[featureid='" + featureid + "']").filter(":visible");

    cells.each(function () {
        cellBulkClick($(this), value, false);
    });

    HideWaitMsg();
}

function bulkOperationWithOverwrite(value, modelid, featureid) {

    ShowWaitMsg();

    var cells;
    if (modelid != 0)
        cells = $("#oxo-core-table-B td[modelid='" + modelid + "'][featureid!='-1000']").filter(":visible");
    else
        cells = $("#oxo-core-table-B td[featureid='" + featureid + "']").filter(":visible");

    cells.each(function () {
        cellBulkClick($(this), value, true);
    });

    HideWaitMsg();
}

function ToggleSaveButtons() {
    var state = ($("#oxo-core-table-B td.isDirty").length > 0);
    if (state) {
        _dirtyEditor = true;
        $("a#butSaveChange,a#butCancelChange").show();
    }
    else {
        _dirtyEditor = false;
        $("a#butSaveChange,a#butCancelChange").hide();
    }
}


function setMode(mode, modeName) {
    var html = "<span class='sub-arrow'>+</span>" + modeName;
    var ele = $("a#selectedMode");
    ele.html(html);
    ele.attr("data", mode);
}

function setDirty(ele) {

    if ($(ele).hasClass("mglevel")) {
        $(ele).removeClass("mglevel").addClass("prev-mglevel");
    }
    if ($(ele).hasClass("generic")) {
        $(ele).removeClass("generic").addClass("prev-generic");
    }
    if ($(ele).text() == $(ele).attr("prevval"))
        $(ele).removeClass("isDirty");
    else
        $(ele).addClass("isDirty");

    ToggleSaveButtons();
}


function ExportExcel(progid, docid, option) {
    _showWaitFlag = false;
    url = _pathHeader + "/Editor/ExcelExport?progid=" + progid + "&docid=" + docid + "&option=" + option
    //window.location.assign(url);
    window.open(url, '_blank');
    var msg = "Your document will appear shortly. Please wait......";
    OXOAlert("Export OXO", msg, "info", null);
}

function ajaxGetFeatureComment(progId, docId, featureId) {

    var url = _pathHeader + "/Editor/ajaxGetCommentByGSF?progId=" + progId + "&docId=" + docId + "&featureId=" + featureId + "&required=" + $.now();
    $.ajax({
        url: url,
        type: 'GET',
        async: false, //blocks window close
        success: function (data) {
            if (data != null) {
                $("span#feature-comment-name").text(data.BrandDescription);
                $("textarea#feature-comment").val(data.Comment);
            }
        },
        error: function (xhr, ajaxOptions, thrownError) {
            alert(xhr.status);
            alert(thrownError);
        }
    });
}

function ajaxGetFeatureRuleText(progId, docId, featureId) {

    var url = _pathHeader + "/Editor/ajaxGetCommentByGSF?progId=" + progId + "&docId=" + docId + "&featureId=" + featureId + "&required=" + $.now();
    $.ajax({
        url: url,
        type: 'GET',
        async: false, //blocks window close
        success: function (data) {
            if (data != null) {
                $("span#feature-rule-name").text(data.BrandDescription);
                $("textarea#feature-rule-text").val(data.RuleText);
            }
        },
        error: function (xhr, ajaxOptions, thrownError) {
            alert(xhr.status);
            alert(thrownError);
        }
    });
}

function FeatComment(progid, featureid, comment) {
    this.progid = progid;
    this.featureid = featureid;
    this.comment = comment;
}

function ajaxSaveFeatureComment() {

    var progid = $("input#ht_oxo_prog_id").val();
    var docid = $("input#ht_oxo_doc_id").val();
    var featureid = $(_currentNode).find("td:eq(0)").attr("featureid");
    var comment = $.trim($("textarea#feature-comment").val());

    var featComment = new FeatComment(progid, featureid, comment);

    var url = _pathHeader + "/Editor/ajaxSaveCommentByGSF?progid=" + progid + "&docid=" + docid + "&required=" + $.now();
    $.ajax({
        type: "POST",
        cache: false,
        url: url,
        data: JSON.stringify(featComment),
        dataType: 'json',
        contentType: "application/json; charset=utf-8",
        success: function (data) {
            if (data.Success) {
                $('div#show-comment-dialog').dialog('close');
                var ctl = $(_currentNode).find("span.info-indicator[featureid=" + featureid + "]")
                if (comment.length == 0) {
                    //need hiding the info box
                    if (ctl != null && ctl.length > 0) { ctl.hide(); }
                } else {
                    //need either showing or creating the info box.
                    if (ctl != null && ctl.length > 0) { ctl.show(); }
                }
            }
            else {
                OXOAlert("Error", "Save OXO Feature Comment failed.", "error", null);
            }
        },
        error: function (xhr, ajaxOptions, thrownError) {
            OXOAlert("Error", xhr.status, "error", null);
            OXOAlert("Error", thrownError, "error", null);
        }
    });


}

function getGSFCommentToolTip(progId, docId, featureId) {

    var url = _pathHeader + "/Editor/ajaxGetCommentByGSF?progId=" + progId + "&docId=" + docId + "&featureId=" + featureId + "&required=" + $.now();
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

function ajaxSaveFeatureRuleText() {

    var progid = $("input#ht_oxo_prog_id").val();
    var docid = $("input#ht_oxo_doc_id").val();
    var featureid = $(_currentNode).find("td:eq(0)").attr("featureid");
    var ruleText = $.trim($("textarea#feature-rule-text").val());
    var featRuleText = new FeatComment(progid, featureid, ruleText);

    var url = _pathHeader + "/Editor/ajaxSaveRuleTextByGSF?progid=" + progid + "&docid=" + docid + "&required=" + $.now();
    $.ajax({
        type: "POST",
        cache: false,
        url: url,
        data: JSON.stringify(featRuleText),
        dataType: 'json',
        contentType: "application/json; charset=utf-8",
        success: function (data) {
            if (data.Success) {
                $('div#show-rule-text-dialog').dialog('close');
                var ctl = $(_currentNode).find("span.rule-indicator[featureid=" + featureid + "]")
                if (ruleText.length == 0) {
                    //need hiding the info box
                    if (ctl != null && ctl.length > 0) { ctl.hide(); }
                } else {
                    //need either showing or creating the info box.
                    if (ctl != null && ctl.length > 0) { ctl.show(); }
                }
            }
            else {
                OXOAlert("Error", "Save OXO Feature Rule Text failed.", "error", null);
            }
        },
        error: function (xhr, ajaxOptions, thrownError) {
            OXOAlert("Error", xhr.status, "error", null);
            OXOAlert("Error", thrownError, "error", null);
        }
    });


}


function getGSFRuleToolTip(progId, docId, featureId) {

    var url = _pathHeader + "/Editor/ajaxGetCommentByGSF?progId=" + progId + "&docId=" + docId +"&featureId=" + featureId + "&required=" + $.now();
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

function GetCookiesTrap(iGroupLevel) {
    return $.cookie("EDTGSFCookie" + iGroupLevel) == null ? "" : $.cookie("EDTGSFCookie" + iGroupLevel);
}

function SetCookieTrap(sGroup, iGroupLevel, state) {

    var cookieDude = GetCookiesTrap(iGroupLevel)

    if (state == "Close") {
        var cookieTrack = cookieDude;
        var testMe = '' + sGroup + ',';
        var res = cookieTrack.replace(testMe, '');
        $.cookie("EDTGSFCookie" + iGroupLevel, res, { expires: 365 })
        if (iGroupLevel == 0) {
            //clear any sub level cookie here two
            subCookieDude = GetCookiesTrap(1);
            var array = subCookieDude.split(',');
            array = $.grep(array, function (value) {
                return value.indexOf(sGroup) < 0;
            });
            subCookieDude = array.join(",");
            $.cookie("EDTGSFCookie1", subCookieDude, { expires: 365 })
        }
    }
    if (state == "Open") {
        var cookieTrack = cookieDude;
        var testMe = '' + sGroup + ',';
        if (cookieTrack.indexOf(testMe) == -1) {
            cookieTrack = cookieTrack + testMe;
            $.cookie("EDTGSFCookie" + iGroupLevel, cookieTrack, { expires: 365 })
        }
    }
}

