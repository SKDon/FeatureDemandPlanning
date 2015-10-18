var _OXOSection = "FBM";
var _minLeftWidth = 500;

///////////////////////////////////////////////////////////
// UI functions
///////////////////////////////////////////////////////////
// editor specific
function hookupContextMenuB() {
    $('#clone-oxo-core-table-B').find('tr th').contextMenu({ menu: 'oxo-model-menu', offsetY: -270, offsetX: -30, bubble: true }, function (action, el, pos) { performMenuAction(action, el); });
    $('#oxo-core-table-B').find('tr.oxo-data-row-2[data-group^="option-packs"]').each(
        function () {
            if ($(this).find('td').attr("featureid") != "-1000") {
                $(this).contextMenu({ menu: 'oxo-pack-cell-menu', offsetY: -270, offsetX: -30, bubble: true }, function (action, el, pos) { performMenuAction(action, el); });
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
}

function hookupContextMenu() {

    $('body').click(function () { $("ul.sm-nowrap").hide(); });

    //Do pager:
    $("#pager").pagination({
        pages: $("#pageCount").text(),
        currentPage: $.cookie('current-page'),
        edges: 1,
        hrefTextPrefix: '#p',
        displayedPages: 3,
        cssStyle: 'oxo-theme',
        selectOnClick: false,
        onPageClick: function (pageNumber) {
            if (_dirtyEditor) {
                OXOAlert("Move Page", "There are unsaved changes, please save/undo your changes before moving pages.", "exclamation", null);
            }
            else {
                ShowWaitMsg();
                var progId = $("#ht_oxo_prog_id").val();
                var docId = $("#ht_oxo_doc_id").val();
                var mode = $("#selectedObject").attr("type");
                var objId = $("#selectedObject").attr("data");
                ajaxFBMPageGet(mode, progId, docId, objId, pageNumber);
                $("#pager").pagination('drawPage', pageNumber);
                $.cookie('current-page', pageNumber, { path: "/", expires: 365 });
                $("#currentPage").text(pageNumber);
            }
        }
    });

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
    $('#oxo-core-table-A').find('td.group[data-group="option-packs"]').contextMenu({ menu: 'oxo-pack-new-menu', offsetY: -270, offsetX: -30, bubble: true }, function (action, el, pos) { performMenuAction(action, el); });
    $('#oxo-core-table-A').find('tr.no-packs').contextMenu({ menu: 'oxo-pack-new-menu', offsetY: -270, offsetX: -30, bubble: true }, function (action, el, pos) { performMenuAction(action, el); });       
    $('#oxo-core-table-A').find("td[class*=' option-packs-']").each(
        function () {
            if ($(this).html() != 'No Pack') {
                $(this).contextMenu({ menu: 'oxo-pack-top-menu', offsetY: -270, offsetX: -30, bubble: true }, function (action, el, pos) { performMenuAction(action, el); });
            }
        });
        $('#oxo-core-table-A').find('tr.oxo-data-row-2[data-group^="option-packs"]').each(
        function () {
            if ($(this).attr("packid") != "0") {
                if ($(this).attr("featureid") != "-1000") {
                    $(this).contextMenu({ menu: 'oxo-pack-menu', offsetY: -270, offsetX: -30, bubble: true }, function (action, el, pos) { performMenuAction(action, el); });
                }
                else {
                    $(this).contextMenu({ menu: 'oxo-pack-addonly-menu', offsetY: -270, offsetX: -30, bubble: true }, function (action, el, pos) { performMenuAction(action, el); });
                }
            }
        }

    );

    hookupContextMenuB();

    var ua = window.navigator.userAgent;
    var msie = ua.indexOf("MSIE ");
    var btnNum = 0
    if (msie > 0)
        btnNum = 1;
    $('a#butPublish').contextMenu({ menu: 'oxo-publish-menu', offsetY: -250, offsetX: -10, button: btnNum }, function (action, el, pos) { performMenuAction(action, el); });

    $("#show-chain-dialog").dialog({
        title: "Data Chain",
        autoOpen: false,
        resizable: false,
        width: "400px",
        position: ["center", 200],
        show: "slide",
        hide: "slide",
        modal: true
    });

    $("#pack-editor-dialog").dialog({
        title: "Maintain Feature Packs",
        autoOpen: false,
        resizable: false,
        width: "388px",
        position: ["center", 250],
        show: "slide",
        hide: "slide",
        modal: true
    });

    $("#show-comment-dialog").dialog({
        title: "Feature Comment",
        autoOpen: false,
        resizable: false,
        width: "500px",
        position: ["center", 200],
        show: "slide",
        hide: "slide",
        modal: true,
        open: function(event, ui) { $('#feature-comment').focus(); }
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

    $("#interim-dialog").dialog({
        title: "Interim Publish",
        autoOpen: false,
        resizable: false,
        width: "450px",
        position: ["center", 200],
        show: "slide",
        hide: "slide",
        modal: true
    });

    $("#gateway-dialog").dialog({
        title: "Complete Publish",
        autoOpen: false,
        resizable: false,
        width: "450px",
        position: ["center", 200],
        show: "slide",
        hide: "slide",
        modal: true
    });

    $("a.marketNav").click(function (e) { marketNavClick(e); });
}

// editor specific
function hookupTableA() {

    var openedGroup = GetCookiesTrap(0).split(',');
    var openedSubGroup = GetCookiesTrap(1).split(',');

    _OXODataTableA = $('#oxo-core-table-A').dataTable({
        "oSearch": { "sSearch": _currentRowFilter.FBMValue },
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
                            { "bSortable": false, "bSearchable": false, "sClass": "right-aligned", "sWidth": "110px", "aTargets": [4] },
                            { "bSortable": false, "bSearchable": true, "sClass": "center-no-sort", "sWidth": "60px", "aTargets": [5] },
                            { "bSortable": false, "bSearchable": true, "sWidth": "0px", "aTargets": [6] }
                         ],
        "fnDrawCallback": function (oSettings) {
            if (_injectOXODataTitleA) {
                formatDataTable();
                _injectOXODataTitleA = false;
            }
            $('#oxo-core-table-A').find("td[data-group-level='0'],td[data-group-level='1']").each(function () {
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
                SetCookieTrap(sGroup, iGroupLevel, sState);
            SyncHeader('B', sGroup, sState);
            ResizeMeEditor();
            HidePackAvailbilityRow();

        }
    });


    $("span.info-indicator").tipsy({
        opacity: 0.98,
        gravity: 's',
        width: '320px',
        delayIn: 400,
        html: true,
        title: function () {
            var progId = $("#ht_oxo_prog_id").val();
            var docId = $("#ht_oxo_doc_id").val();
            var featureId = $(this).attr("featureid");
            return getCommentToolTip(progId, docId, featureId);
        }
    });

    $("span.rule-indicator").tipsy({
        opacity: 0.98,
        gravity: 's',
        width: '320px',
        delayIn: 400,
        html: true,
        title: function () {
            var progId = $("#ht_oxo_prog_id").val();
            var docId = $("#ht_oxo_doc_id").val();
            var featureId = $(this).attr("featureid");
            return getRuleTextToolTip(progId, docId, featureId);
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
        "oSearch": { "sSearch": _currentRowFilter.FBMValue },
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
                SetCookieTrap(sGroup, iGroupLevel, sState);
            SyncHeader('A', sGroup, sState);
            ResizeMeEditor();
            HidePackAvailbilityRow();

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
        case "set-all-pack-option":
            var msg = "Would you like to overwrite existing values in this row? If you choose 'No', only blank cells will be updated.";
            OXOYesNo("Set All To Option", msg, 'question', BulkPackOverwriteOptionWrapper, BulkPackOptionWrapper);
            break;
        case "set-all-pack-na":
            var msg = "Would you like to overwrite existing values in this row? If you choose 'No', only blank cells will be updated.";
            OXOYesNo("Set All To Not Available", msg, 'question', BulkPackOverwriteNAWrapper, BulkPackNAWrapper);
            break;
        case "set-all-pack-body-pack":
            var msg = "Would you like to overwrite existing values in this row? If you choose 'No', only blank cells will be updated.";
            OXOYesNo("Set All To Part Of Pack", msg, 'question', BulkPackBodyOverwritePackWrapper, BulkPackBodyPackWrapper);
            break;
        case "set-all-pack-body-na":
            var msg = "Would you like to overwrite existing values in this row? If you choose 'No', only blank cells will be updated.";
            OXOYesNo("Set All To Not Available", msg, 'question', BulkPackBodyOverwriteNAWrapper, BulkPackBodyNAWrapper);
            break;

        case "clear-all-pack":
            var packid = $(_currentNode).parent().next().attr("packid");
            bulkPackOperation(false, packid);
            break;
        case "history-oxo":
            var marketId = 0;
            var marketGroupId = 0;
            var modelId = $(_whichCell).attr("modelid");
            var featureId = $(_whichCell).attr("featureid");
            var docId = $("input#ht_oxo_doc_id").val();
            var docTitle = $("div#dtable-title").text();
            var object = $("a#selectedObject");
            if (object.attr("type") == 'mg')
                marketGroupId = object.attr("data");
            else
                marketId = object.attr("data");
            showChangeHistoryDialog(docId, modelId, marketId, marketGroupId, featureId, docTitle);
            break;
        case "drill-up":
            var marketId = 0;
            var groupId = 0;
            var modelId = $(_whichCell).attr("modelid");
            var featureId = $(_whichCell).attr("featureid");
            var docId = $("input#ht_oxo_doc_id").val();
            var progId = $("input#ht_oxo_prog_id").val();
            var docTitle = $("div#dtable-title").text();
            var object = $("a#selectedObject");
            var level = object.attr("type");
            var objectId = object.attr("data");
            showDataChainDialog("Up", docId, progId, modelId, featureId, level, objectId, docTitle);
            break;
        case "drill-down":
            var marketId = 0;
            var groupId = 0;
            var modelId = $(_whichCell).attr("modelid");
            var featureId = $(_whichCell).attr("featureid");
            var docId = $("input#ht_oxo_doc_id").val();
            var progId = $("input#ht_oxo_prog_id").val();
            var docTitle = $("div#dtable-title").text();
            var object = $("a#selectedObject");
            var level = object.attr("type");
            var objectId = object.attr("data");
            showDataChainDialog("Down", docId, progId, modelId, featureId, level, objectId, docTitle);
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
                launchFeatureLookUpDialogs("vehicle", vehicleId, progId, docId, group, AddFeaturesToProg);
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
                var msg = "Are you sure you want to remove the following feature from this OXO?";
                msg = msg + "Please note, the feature will also be deleted in all Market Groups and Markets.<br/><br/>";
                msg = msg + "<b>" + feature + "</b>";
                OXOConfirm("Remove Feature", msg, "question", RemoveFeatureWrapper);
            }
            break;
        case "add-pack":
            if (_dirtyEditor) {
                var msg = "There are unsaved changes, please save/undo your changes before adding pack.";
                OXOAlert("Add Pack", msg, "exclamation", null);
            }
            else {
                launchPackEditor(0);
            }
            break;
        case "edit-pack":
            if (_dirtyEditor) {
                var msg = "There are unsaved changes, please save/undo your changes before editing pack.";
                OXOAlert("Edit Pack", msg, "exclamation", null);
            }
            else {
                var packid = $(el).closest('tr').next().attr("packid");
                launchPackEditor(packid);
            }
            break;
        case "remove-pack":
            if (_dirtyEditor) {
                var msg = "There are unsaved changes, please save/undo your changes before removing pack.";
                OXOAlert("Remove Pack", msg, "exclamation", null);
            }
            else {
                var packName = $(el).html();
                packName = packName.replace('<SPAN class=pack-profet>', ' [');
                packName = packName + "]";
                var msg = "Are you sure you want to remove the following pack from this OXO?";
                msg = msg + "<br/><b>" + packName + "</b>";
                OXOConfirm("Remove Pack", msg, "question", RemovePackWrapper);
            }
            break;
        case "add-pack-feature":
            if (_dirtyEditor) {
                var msg = "There are unsaved changes, please save/undo your changes before adding feature to pack.";
                OXOAlert("Add Feature To Pack", msg, "exclamation", null);
            }
            else {
                var progid = $("input#ht_oxo_prog_id").val();
                var docid = $("input#ht_oxo_doc_id").val();
                var packid = $(_currentNode).find("td").attr("packid");
                launchFeatureLookUpDialogs("programme", progid, packid, docid, "All", AddFeaturesToPack);
            }
            break;
            break;
        case "remove-pack-feature":
            if (_dirtyEditor) {
                var msg = "There are unsaved changes, please save/undo your changes before removing feature from this pack.";
                OXOAlert("Remove Feature From Pack", msg, "exclamation", null);
            }
            else {
                var feature = $(_currentNode).find("td:eq(0)").text();
                feature = feature.replace(/^\s+|\s+$/g, '').replace(/Rule$/g, '');
                var msg = "Are you sure you want to remove the following feature from this pack?";
                msg = msg + "<br/><b>" + feature + "</b>";
                OXOConfirm("Remove Feature From Pack", msg, "question", RemoveFeatureFromPackWrapper);
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
            //Call ajax to get comment data
            ajaxGetFeatureComment(progid, docid, featureid);
            $("div#show-comment-dialog").dialog({ title: "Edit Comment - " + progName });
            $("div#show-comment-dialog").dialog("open");
           // $("textarea#feature-comment").focus();
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
           // $("textarea#feature-rule-text").focus();
            break;
        case "interim-publish":
            $("div#interim-dialog").dialog("open");
            break;
        case "gateway-publish":
            $("div#gateway-dialog").dialog("open");
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

function BulkPackOptionWrapper() {
    var packid = $(_currentNode).parent().next().attr("packid");    
    bulkPackOperation(true, packid, 'O');
}

function BulkPackOverwriteOptionWrapper() {
    var packid = $(_currentNode).parent().next().attr("packid");    
    bulkPackOperationWithOverwrite(true, packid, 'O');
}

function BulkPackNAWrapper() {
    var packid = $(_currentNode).parent().next().attr("packid");
    bulkPackOperation(true, packid, 'NA');
}

function BulkPackOverwriteNAWrapper() {
    var packid = $(_currentNode).parent().next().attr("packid");
    bulkPackOperationWithOverwrite(true, packid, 'NA');
}

function BulkPackBodyPackWrapper() {
    var packid = $(_currentNode).attr("packid");
    var featureid = $(_currentNode).find("td:eq(0)").attr("featureid");
    bulkPackBodyOperation(true, packid, featureid,  'P');
}

function BulkPackBodyOverwritePackWrapper() {
    var packid = $(_currentNode).attr("packid");
    var featureid = $(_currentNode).find("td:eq(0)").attr("featureid");
    bulkPackBodyOperationWithOverwrite(true, packid, featureid, 'P');
}

function BulkPackBodyNAWrapper() {
    var packid = $(_currentNode).attr("packid");
    var featureid = $(_currentNode).find("td:eq(0)").attr("featureid");
    bulkPackBodyOperation(true, packid, featureid, 'NA');
}

function BulkPackBodyOverwriteNAWrapper() {
    var packid = $(_currentNode).attr("packid");
    var featureid = $(_currentNode).find("td:eq(0)").attr("featureid");  
    bulkPackBodyOperationWithOverwrite(true, packid, featureid, 'NA');
}

function RemoveFeatureFromPackWrapper() {
    var progid = $("input#ht_oxo_prog_id").val();
    var docid = $("input#ht_oxo_doc_id").val();
    var packid = $(_currentNode).find("td:eq(0)").attr("packid");
    var featid = $(_currentNode).find("td:eq(0)").attr("featureid");
    ajaxRemoveFeatureFromPack(progid, docid, packid, featid);
}

function RemovePackWrapper() {
    var progid = $("input#ht_oxo_prog_id").val();
    var docid = $("input#ht_oxo_doc_id").val();
    var packid = $(_currentNode).closest('tr').next().attr("packid");    
    ajaxRemovePack(progid, docid, packid);
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

    var url = _pathHeader + "/Editor/ajaxAddFeaturesProg?docid=" + docId + "&progid=" + progId + "&required=" + (new Date()).getTime();
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
    var url = _pathHeader + "/Editor/ajaxRemoveFeatureForProg?docid=" + docid + "&progid=" + progid + "&featid=" + featid + " &required=" + (new Date()).getTime();
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

function packCellBulkClick(ele, bTicked, overwrite, inputMode) {

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
        cells = $("#oxo-core-table-B td[modelid='" + modelid + "'][featureid!='-1000']").filter(':visible');
    else
        cells = $("#oxo-core-table-B td[featureid='" + featureid + "']").filter(':visible');

    cells.each(function () {
        cellBulkClick($(this), value, false);
    });

    HideWaitMsg()
}

function bulkPackOperation(value, packid, inputMode) {

    ShowWaitMsg();

    var cells = $("table.pack td.pack-header[packid='" + packid + "']").filter(':visible');
    cells.each(function () {
        packCellBulkClick($(this), value, false, inputMode);
    });

    HideWaitMsg()
}

function bulkPackBodyOperation(value, packid, featureid, inputMode) {

    ShowWaitMsg();

    var cells = $("#oxo-core-table-B").find("td.pack-body[packid='" + packid + "'][featureid='" + featureid + "']").filter(':visible');
    cells.each(function () {
        packCellBulkClick($(this), value, false, inputMode);
    });

    HideWaitMsg()
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

    HideWaitMsg()
}

function bulkPackOperationWithOverwrite(value, packid, inputMode) {

    ShowWaitMsg();

    var cells = $("table.pack td.pack-header[packid='" + packid + "']").filter(':visible');
    cells.each(function () {
        packCellBulkClick($(this), value, true, inputMode);
    });

    HideWaitMsg();
}

function bulkPackBodyOperationWithOverwrite(value, packid, featureid, inputMode) {

    ShowWaitMsg();

    var cells = $("#oxo-core-table-B td.pack-body[packid='" + packid + "'][featureid='" + featureid + "']").filter(":visible");
    cells.each(function () {
        packCellBulkClick($(this), value, true, inputMode);
    });

    HideWaitMsg()
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

function marketNavClick(e) {
    if (_dirtyEditor) {
        var msg = "There are unsaved changes, please save/undo your changes before switching market.";
        OXOAlert("Switching Market", msg, "exclamation", null);
        e.preventDefault();
    }
    else {
        ShowWaitMsg();
        $.cookie('current-page', 1, { path: "/", expires: 365 });
        var href = e.srcElement.href;
        document.location = href;
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

function showDataChainDialog(option, docId, progId, modelId, featureId, level, objectId, docTitle) {

    var model;
    var market;
    var feature;
    var ending;
    var html;

    $("div#show-chain-dialog").dialog({ title: "Drill " + option + " - " + docTitle });
    $("div#show-chain-dialog").dialog("open");
    ajaxGetDataChain(option, docId, progId, modelId, featureId, level, objectId);
}

function ajaxGetDataChain(option, docId, progId, modelId, featureId, level, objectId) {

    var url = _pathHeader + "/Editor/ajaxGetOXODataChain?option=" + option + "&docId=" + docId + "&progId=" + progId;
    url = url + "&modelId=" + modelId + "&featureId=" + featureId + "&level=" + level + "&objectId=" + objectId + "&required=" + (new Date()).getTime();
    $.ajax({
        type: "POST",
        cache: false,
        url: url,
        dataType: 'json',
        contentType: "application/json; charset=utf-8",
        success: function (data) {
            var chains = data;
            var model = "";
            var feature = "";
            var row = "";
            var code = "";
            var thead = $("table#chain-table thead tr th").first();

            if (option == "Up") {
                $(thead).text("Level");
            }
            else {
                if (level == 'mg')
                    $(thead).text("Market");
                else
                    $(thead).text("Market Group");
            }

            $("table#chain-table tbody tr").remove();
            for (i = 0; i < chains.length; i++) {
                model = chains[i].ModelName;
                feature = chains[i].FeatureName;
                code = translateCode(chains[i].OXOCode);
                row = row + "<tr><td>" + chains[i].LevelName + "</td><td>" + code + "</td></tr>";
            }

            var subTitle = 'Model : ' + model + '<br/>Feature : ' + feature + '<br/>'
            $("div#chain-sub-title").html(subTitle);
            $("table#chain-table").append(row);
        },
        error: function (xhr, ajaxOptions, thrownError) {
            alert(xhr.status);
            alert(thrownError);
        }
    });
}

function closeDataChainDialog() {
    $("div#show-chain-dialog").dialog("close");
}

function validateDoc() {
    var docid = $("input#ht_oxo_doc_id").val();
    var progid = $("input#ht_oxo_prog_id").val();
    var objectid = $("a#selectedObject").attr("data");
    var mode = $("a#selectedObject").attr("type");
    var view = "";
    url = _pathHeader + "/Editor/ValidateDoc?show=both&view=" + view + "&mode=" + mode + "&progid=" + progid + "&docid=" + docid + "&objectid=" + objectid;
    window.location.href = url;
}

function ExportExcel(progid, docid, option) {
    _showWaitFlag = false;
    url = _pathHeader + "/Editor/ExcelExport?progid=" + progid + "&docid=" + docid + "&option=" + option
    //window.location.assign(url);
    window.open(url, '_blank');
    var msg = "Your document will appear shortly. Please wait......";
    OXOAlert("Export OXO", msg, "info", null);
}

function injectPackAvailability() {

    var packRows = $("#oxo-core-table-A").find("tr.pack-availability");
    for (var i = 0; i < packRows.length; i++) {
        var tag = $(packRows[i]).attr("data-group");
        var bRow = $("#oxo-core-table-B").find("tr.pack-availability[data-group='" + tag + "']");
        var html = "<table class='pack'><tr>" + $(bRow).clone().html() + "</tr></table>";
        $("#oxo-core-table-B").find("td.subgroup[data-group='" + tag + "']").html(html); ;
        var pcode = $(packRows[i]).find("td:eq(2)").text();
        var html2 = "<div class='pack-profet'><span class='pack-code'>" + pcode + "</span></div>";
        $("#oxo-core-table-A").find("td.subgroup[data-group='" + tag + "']").append(html2);
        $(packRows[i]).hide();
        $(bRow).hide();
        $("#oxo-core-table-B").find("td.subgroup[data-group='" + tag + "']").find('table.pack tr td').each(function()
        {
            $(this).contextMenu({ menu: 'oxo-pack-head-menu', offsetY: -270, offsetX: -30, bubble: true }, 
                           function (action, el, pos) { performMenuAction(action, el); });
        });
    }
}

function injectPackAvailabilityB() {
 
    var packRows = $("#oxo-core-table-A").find("tr.pack-availability");
    for (var i = 0; i < packRows.length; i++) {
        var tag = $(packRows[i]).attr("data-group");
        var bRow = $("#oxo-core-table-B").find("tr.pack-availability[data-group='" + tag + "']");
        var html = "<table class='pack'><tr>" + $(bRow).clone().html() + "</tr></table>";
        $("#oxo-core-table-B").find("td.subgroup[data-group='" + tag + "']").html(html); ;
        $(packRows[i]).hide();
        $(bRow).hide();
        $("#oxo-core-table-B").find("td.subgroup[data-group='" + tag + "']").find('table.pack tr td').each(function () {
            $(this).contextMenu({ menu: 'oxo-pack-head-menu', offsetY: -270, offsetX: -30, bubble: true },
                           function (action, el, pos) { performMenuAction(action, el); });
        });
    }

}

// Pack dialog
function launchPackEditor(id) {
    var progid = $("input#ht_oxo_prog_id").val();
    var docid = $("input#ht_oxo_doc_id").val();
    var url = _pathHeader + "/Editor/ajaxPackEditor?progid=" + progid + "&docid=" + docid + "&packid=" + id + "&required=" + $.now();
    $.ajax({ type: "GET",
        url: url,
        async: false,
        success: function (html) {
            $("div#pack-editor-dialog").find("div#form-placeholder").html(html);
            hookupPackAjax();
            hookupValidator();
        },
        error: function (xhr, ajaxOptions, thrownError) {
            OXOAlert("Error", xhr.status, "error", null);
            OXOAlert("Error", thrownError, "error", null);
        }
    });

    $("div#pack-editor-dialog").dialog("open");
}

function hookupPackAjax() {
    $('form#frmPack').submit(function () {
      //  $("input#ht_pack_prog_id").val($("input#ht_oxo_prog_id").val());
      //  $("input#ht_pack_doc_id").val($("input#ht_oxo_doc_id").val());
        if ($(this).valid()) { 
            $.ajax({
                url: this.action,
                type: this.method,
                data: $(this).serialize(),
                success: function (result) {
                    if (result.Success) {
                        location.reload(true);
                    }
                    else {

                        if (result.ErrorMessage != null)
                            OXOAlert("Error", result.ErrorMessage, "error", null);
                        else
                            OXOAlert("Error", "Sorry, fail to perform operation.", "exclamation", null);
                    }
                },
                error: function (xhr, ajaxOptions, thrownError) {
                    alert(xhr.status);
                    alert(thrownError);
                }
            });
        }
        else {
            var msg = getValidatorMsg();
            OXOAlert("Validation", msg, "exclamation", null);
        }

        return false;

    });
}


function hookupValidator() {
    $('form#frmPack').removeData('validator');
    $('form#frmPack').removeData('unobtrusiveValidation');
    $.validator.unobtrusive.parse('form#frmPack');
}

function getValidatorMsg() {
    var counter = 1;
    var html = 'The following errors have been detected:\n\n';
    $("div.validation-summary-errors ul li").each(function () {
        html = html + counter + ". " + $(this).text() + "<br/>";
        counter++;
    });
    return html;
}

function ajaxRemovePack(progid, docid, packid) {
    var url = _pathHeader + "/Editor/ajaxRemovePackForProg?progid=" + progid + "&docid=" + docid + "&packid=" + packid + "&required=" + (new Date()).getTime();
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
                var msg = "Remove feature from pack failed." + data.Error;
                OXOAlert("Remove Feature From Pack", msg, "error", null);
            }
        },
        error: function (xhr, ajaxOptions, thrownError) {
            OXOAlert("Error", xhr.status, "error", null);
            OXOAlert("Error", thrownError, "error", null);
        }
    });
}

function AddFeaturesToPack() {

    var progId = $("input#ht_oxo_prog_id").val();
    var docId = $("input#ht_oxo_doc_id").val();
    var packid = $(_currentNode).attr("packid");
    var url = _pathHeader + "/Editor/ajaxAddFeaturesPack?progid=" + progId + "&docid=" + docId + "&packid=" + packid + "&required=" + (new Date()).getTime();

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

function ajaxRemoveFeatureFromPack(progid, docid, packid, featid) {
    var url = _pathHeader + "/Editor/ajaxRemoveFeatureForPack?progid=" + progid + "&docid=" + docid + "&packid=" + packid + "&featid=" + featid + "&required=" + (new Date()).getTime();
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
                OXOAlert("Remove Feature From Pack", msg, "error", null);
            }
        },
        error: function (xhr, ajaxOptions, thrownError) {
            OXOAlert("Error", xhr.status, "error", null);
            OXOAlert("Error", thrownError, "error", null);
        }
    });
}

function ajaxGetFeatureComment(progId, docId, featureId) {

    var url = _pathHeader + "/Editor/ajaxGetCommentByFeature?progId=" + progId + "&docId=" + docId + "&featureId=" + featureId + "&required=" + $.now();
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

    var url = _pathHeader + "/Editor/ajaxGetCommentByFeature?progId=" + progId + "&docId=" + docId + "&featureId=" + featureId + "&required=" + $.now();
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

    var url = _pathHeader + "/Editor/ajaxSaveCommentByFeature?progid=" + progid + "&docid=" + docid + "&required=" + $.now();
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
                    if (ctl != null && ctl.length == 1) { ctl.hide(); }
                } else {
                    //need either showing or creating the info box.
                    if (ctl != null && ctl.length == 1) { ctl.show(); }
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

function ajaxSaveFeatureRuleText() {

    var progid = $("input#ht_oxo_prog_id").val();
    var docid = $("input#ht_oxo_doc_id").val();
    var featureid = $(_currentNode).find("td:eq(0)").attr("featureid");
    var ruleText = $.trim($("textarea#feature-rule-text").val());

    var featRuleText = new FeatComment(progid, featureid, ruleText);

    var url = _pathHeader + "/Editor/ajaxSaveRuleTextByFeature?progid=" + progid + "&docid=" + docid + "&required=" + $.now();
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
                var ctl = $("#oxo-core-table-A").find("span.rule-indicator[featureid=" + featureid + "]")
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

function GetCookiesTrap(iGroupLevel) {
    return $.cookie("EDTFBMCookie" + iGroupLevel) == null ? "" : $.cookie("EDTFBMCookie" + iGroupLevel);
}

function SetCookieTrap(sGroup, iGroupLevel, state) {

    var cookieDude = GetCookiesTrap(iGroupLevel)

    if (state == "Close") {
        var cookieTrack = cookieDude;
        var testMe = '' + sGroup + ',';
        var res = cookieTrack.replace(testMe, '');
        $.cookie("EDTFBMCookie" + iGroupLevel, res, { path: "/", expires: 365 })
        if (iGroupLevel == 0) {
            //clear any sub level cookie here two
            subCookieDude = GetCookiesTrap(1);
            var array = subCookieDude.split(',');
            array = $.grep(array, function (value) {
                return value.indexOf(sGroup) < 0;
            });
            subCookieDude = array.join(",");
            $.cookie("EDTFBMCookie1", subCookieDude, { path: "/", expires: 365 })
        }
    }
    if (state == "Open") {
        var cookieTrack = cookieDude;
        var testMe = '' + sGroup + ',';
        if (cookieTrack.indexOf(testMe) == -1) {
            cookieTrack = cookieTrack + testMe;
            $.cookie("EDTFBMCookie" + iGroupLevel, cookieTrack, { path: "/", expires: 365 })
        }
    }
}

function HidePackAvailbilityRow() {
    $('#oxo-core-table-A tr.pack-availability').hide();
    $('#oxo-core-table-B tr.pack-availability').hide();
}

function ajaxFBMPageGet(mode, progid, docid, objectid, page) {
    var url = _pathHeader + "/Editor/AjaxFBM?mode=" + mode + "&progid=" + progid + "&docid=" + docid + "&objectid=" + objectid + "&page=" + page + " &required=" + (new Date()).getTime();
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
            injectPackAvailabilityB();
            //need to re-hook all the events  
            hookupContextMenuB();
            hookupOtherEventsB();
            if ($('#ht_do_click').val() == 1)
                hookupClickEvent();

            var paneWidth = $('#ht_parent_width').val();
            $("#right-pane-header").width(paneWidth);
            $("#right-pane").width(paneWidth);
            ResizeMeEditor();
            var resetCookies = $("ht_clear_page_cookie").val();
            if (resetCookies == 1)
                $.cookie('current-page', 1, { path: "/", expires: 365 });
        },
        error: function (xhr, ajaxOptions, thrownError) {
            OXOAlert("Error", xhr.status, "error", null);
            OXOAlert("Error", thrownError, "error", null);
        }
    });
}


