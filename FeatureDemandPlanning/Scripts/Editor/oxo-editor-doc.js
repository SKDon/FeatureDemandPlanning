var _OXOSection = "DOC";
var _injectOXOListTitle = true;
var _toggleFolder = false
var _OXODataListTable;
var progid = $("#ht_oxo_prog_id").val();
var docid = $("#ht_oxo_doc_id").val();


$(document).ready(function () {
    hookupTable();
    popTable(progid, docid);
    $("div#doc-wrapper").show();
    hookupDialog();
    hookupMouseWheel();
    ResizeMe();
});

function hookupTable() {
    //set cookie
    var openedGroup = GetCookiesTrap(0).split(',');

    _OXODataListTable = $('#oxo-doc-table').dataTable({
        "iDisplayLength": -1,
        "bLengthChange": false,
        "bDeferRender": true,
        "bAutoWidth": false,
        "bProcessing": false,
        "aaSorting": [],
        "bPaginate": false,
        "oLanguage": { "sSearch": "Search&nbsp;:&nbsp;" },
        "sDom": '<"top"lfpi>rt',
        "aoColumnDefs": [
                            { "bVisible": false, "bSortable": false, "bSearchable": false, "sWidth": "120px", "aTargets": [0] },
                            { "bSortable": false, "sWidth": "300px", "aTargets": [1] },
                            { "bSortable": true, "sWidth": "300px", "aTargets": [2] },
                            { "bSortable": true, "aTargets": [3] },
                            { "bSortable": true, "sClass": "right", "sWidth": "100px", "aTargets": [4] },
                            { "bSortable": true, "sWidth": "100px", "aTargets": [5] },
                            { "bSortable": true, "sWidth": "140px", "aTargets": [6] },
                            { "bSortable": true, "sWidth": "0px", "aTargets": [7] }
                                                 ],
        "fnDrawCallback": function (oSettings) {
            if (_injectOXOListTitle) {
                formatDataTable();
                _injectOXOListTitle = false;
                hookupContextMenu();
            }
        }
    }).rowGrouping({ bExpandableGrouping: true, asExpandedGroups: openedGroup,
        iGroupingColumnIndex: 1,
        sGroupingColumnSortDirection: "desc",
        iGroupingOrderByColumnIndex: 7,
        fnAfterGroupClicked: function (sGroup, iGroupLevel, sState) {
            SetCookieTrap(sGroup, iGroupLevel, sState);            
            ResizeMe(); 
        }
    });
    
}


$.strPad = function (i, l, s) {
    var o = i.toString();
    if (!s) { s = '0'; }
    while (o.length < l) {
        o = s + o;
    }
    return o;
};

function popTable(progid, docid) {

    $.ajax({
        url: _pathHeader + "/Editor/ajaxPopFile?progid=" + progid + "&docid=" + docid + "&required=" + $.now(),
        success: function (data) {
            _OXODataListTable.fnClearTable();
            for (var i = 0; i < data.length; i++) {
                var img = '<img src="../Content/Images/tree/' + data[i].FileExt + '.png" class="docs">';
                var row = [data[i].Id, data[i].Gateway,  img + ' ' + data[i].FileName, data[i].FileComment, data[i].FileSize + " KB", data[i].UploadedBy, data[i].DateUploaded, i];
                var k = _OXODataListTable.fnAddData(row, false);
            }
            _OXODataListTable.fnDraw();

            $('div#dtable-info').text($('div.dataTables_info').text());
            $('div#dtable-filter input').on("keyup", function () {
                resetScrollbar();
                var searchVal = this.value;
                if (searchVal.length >= 2) {
                    _OXODataListTable.fnFilter(searchVal);
                }
                else {
                    if (searchVal.length == 0)
                        _OXODataListTable.fnFilter('');
                }
                $('div#dtable-info').text($('div.dataTables_info').text());
            });
        },
        error: function (xhr, ajaxOptions, thrownError) {
            alert(xhr.status);
            alert(thrownError);
        },
        async: false
    });

    ResizeMe();


    hookupContextMenu();

}

function hookupContextMenu() {

    $('#oxo-doc-table tr.odd, tr.even').css("cursor", "pointer");

    $('#oxo-doc-table tr.odd, tr.even').click(function () {
        var rowIndex = _OXODataListTable.fnGetPosition($(this).closest('tr')[0]);
        var aData = _OXODataListTable.fnGetData(rowIndex);
        downloadDoc(parseFloat(aData[0], 10));
    });
}

function syncHeader() {
    var headers = $("#oxo-doc-table thead").html();
    var cloneHeaders = $("#clone-oxo-table thead").html(headers);
    $('#oxo-doc-table').css("top", "-" + $("#oxo-doc-table thead").height() + "px");
    $("table#oxo-doc-table thead tr th").hide();
}

function hookupDialog() {
    $("div#doc-dialog").dialog({
        title: "Upload Document",
        autoOpen: false,
        resizable: false,
        width: "280px",
        position: ["center", 100],
        show: "slide",
        hide: "slide",
        modal: true
    });
}

function performMenuAction(action, el) {
    _currentNode = el;
    var aData;
    var rowIndex;
    switch (action) {
        case "add-oxo-file":
            launchUploadDialog(0);
            break;
        case "delete-oxo-file":
            rowIndex = _OXODataListTable.fnGetPosition($(el).closest('tr')[0]);
            aData = _OXODataListTable.fnGetData(rowIndex);
            if (confirm("Are you sure you want to delete the selected document?")) {
                ajaxDeleteFile(parseFloat(aData[0], 10));
            }
            break;
        case "view-oxo-file":
            rowIndex = _OXODataListTable.fnGetPosition($(el).closest('tr')[0]);
            aData = _OXODataListTable.fnGetData(rowIndex);
            downloadDoc(parseFloat(aData[0], 10));
            break;
    }
}

function launchUploadDialog(id) {
    setDialogValue(id);
    $("div#doc-dialog").dialog("open");
}

function setDialogValue(id) {

    var progid = $("input#ht_oxo_prog_id").val();
    var docid = $("input#ht_oxo_doc_id").val();
    var url = _pathHeader + "/Editor/ajaxFileUploader?progId=" + progid + "&docid=" + docid + "&id=" + id + "&required=" + $.now();
    $.ajax({ type: "GET",
        url: url,
        async: false,
        success: function (html) {
            $("div#doc-dialog").find("div#form-placeholder").html(html);
            hookupValidator();
        },
        error: function (xhr, ajaxOptions, thrownError) {
            alert(xhr.status);
            alert(thrownError);
        }
    });
}

function ajaxDeleteFile(id) {
    var url = _pathHeader + "/Editor/ajaxDeleteFile?id=" + id + "&required=" + $.now();
    $.ajax({ type: "GET",
        url: url,
        async: false,
        success: function (result) {
            if (result.Success) {
                var row = $(_currentNode).closest("tr").get(0);
                _OXODataListTable.fnDeleteRow(_OXODataListTable.fnGetPosition(row));
            }
        },
        error: function (xhr, ajaxOptions, thrownError) {
            alert(xhr.status);
            alert(thrownError);
        }
    });
}

function downloadDoc(id) {
    var url = _pathHeader + "/Editor/DownloadFile?id=" + id + "&required=" + $.now();
    window.location.href = url;
}

function hookupValidator() {
    $('form#frmFiles').removeData('validator');
    $('form#frmFiles').removeData('unobtrusiveValidation');
    $.validator.unobtrusive.parse('form#frmFiles');
}

function getValidatorMsg() {
    var counter = 1;
    var html = 'The following errors have been detected:\n\n';
    $("div.validation-summary-errors ul li").each(function () {
        html = html + counter + ". " + $(this).text() + "\n";
        counter++;
    });
    return html;
}

function hookupMouseWheel() {
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
}


function GetCookiesTrap(iGroupLevel) {
    return $.cookie("EDTDOCCookie" + iGroupLevel) == null ? "" : $.cookie("EDTDOCCookie" + iGroupLevel);
}

function SetCookieTrap(sGroup, iGroupLevel, state) {

    var cookieDude = GetCookiesTrap(iGroupLevel)

    if (state == "Close") {
        var cookieTrack = cookieDude;
        var testMe = '' + sGroup + ',';
        var res = cookieTrack.replace(testMe, '');
        $.cookie("EDTDOCCookie" + iGroupLevel, res, { expires: 365 })
        if (iGroupLevel == 0) {
            //clear any sub level cookie here two
            subCookieDude = GetCookiesTrap(1);
            var array = subCookieDude.split(',');
            array = $.grep(array, function (value) {
                return value.indexOf(sGroup) < 0;
            });
            subCookieDude = array.join(",");
            $.cookie("EDTDOCCookie1", subCookieDude, { expires: 365 })
        }
    }
    if (state == "Open") {
        var cookieTrack = cookieDude;
        var testMe = '' + sGroup + ',';
        if (cookieTrack.indexOf(testMe) == -1) {
            cookieTrack = cookieTrack + testMe;
            $.cookie("EDTDOCCookie" + iGroupLevel, cookieTrack, { expires: 365 })
        }
    }
}
