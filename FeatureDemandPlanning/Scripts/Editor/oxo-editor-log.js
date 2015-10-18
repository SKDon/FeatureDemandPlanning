var _OXOSection = "LOG";
var _injectOXOListTitle = true;
var _toggleFolder = false
var _OXODataListTable;
var progid = $("#ht_oxo_prog_id").val();
var docid = $("#ht_oxo_doc_id").val();
var _availableVersions;
var _availableHeaders;
var _originalTop;
var _logEntryId;

$(document).ready(function () {    
    hookupTable();
    $("div#doc-wrapper").show();
    hookupContextMenu();
    hookupDialog();
    hookupOtherEvent();
    ResizeMe();
});

function hookupTable() {
    //set cookie
    var openedGroup = GetCookiesTrap(0).split(',');

    _OXODataListTable = $('#oxo-table').dataTable({
        "iDisplayLength": -1,
        "bLengthChange": false,
        "bDeferRender": true,
        "bAutoWidth": false,
        "bProcessing": false,
        "bPaginate": false,
        "aaSorting": [[2, 'desc']],
        "oLanguage": { "sSearch": "Search&nbsp;:&nbsp;" },
        "sDom": '<"top"lfpi>rt',
        "aoColumnDefs": [
                            { "bSortable": false, "aTargets": [0] },
                            { "bSortable": false, "aTargets": [1] },
                            { "bSortable": true, "aTargets": [2] },
                            { "bSortable": false, "aTargets": [3] },
                            { "bSortable": false, "aTargets": [4] },
                            { "bSortable": false, "sClass": "center-no-sort", "aTargets": [5] },
                            { "bSortable": false, "sClass": "center-no-sort", "aTargets": [6] },
                            { "bSortable": false, "aTargets": [7] },
                            { "bSortable": false, "aTargets": [8] },
                            { "bSortable": false, "aTargets": [9] },
                            { "bSortable": false, "aTargets": [10] },
                            { "bSortable": false, "aTargets": [11] },
                            { "bSortable": false, "aTargets": [12] },
                            { "bSortable": false, "sClass": "center-no-sort", "aTargets": [13] },
                            { "bSortable": false, "aTargets": [14] },
                            { "bSortable": false, "bVisible": false, "aTargets": [15] }

                       ],
        "fnDrawCallback": function (oSettings) {

            if (_injectOXOListTitle) {
                formatDataTable();
                _injectOXOListTitle = false;
            }
        }



    }).rowGrouping({
        bExpandableGrouping: true,
        asExpandedGroups: openedGroup,
        iGroupingColumnIndex: 0,
        iGroupingOrderByColumnIndex: 0,
        bHideGroupingOrderByColumn: true,
        sGroupingColumnSortDirection: "desc",
        fnAfterGroupClicked: function (sGroup, iGroupLevel, sState) {
            SetCookieTrap(sGroup, iGroupLevel, sState);            
            ResizeMe(); 
        }
    });

    syncHeader();

}


function hookupContextMenu() {
    $('#oxo-table').find('td.group').contextMenu({ menu: 'oxo-version-menu', offsetY: -200, offsetX: -20, bubble: true }, function (action, el, pos) { performMenuAction(action, el); });
    $('#oxo-table').find('td.subgroup').contextMenu({ menu: 'oxo-header-menu', offsetY: -200, offsetX: -20, bubble: true }, function (action, el, pos) { performMenuAction(action, el); });
    $('#oxo-table').find('tr.oxo-log').contextMenu({ menu: 'oxo-entry-menu', offsetY: -200, offsetX: -20, bubble: true }, function (action, el, pos) { performMenuAction(action, el); });
    $('#oxo-table').find('td.dataTables_empty').contextMenu({ menu: 'oxo-entry-empty-menu', offsetY: -200, offsetX: -20, bubble: true }, function (action, el, pos) { performMenuAction(action, el); });
}

function syncHeader() {
    var headers = $("#oxo-table thead").html();
    var cloneHeaders = $("#clone-oxo-table thead").html(headers);
    $('#oxo-table').css("top", "-" + $("#oxo-table thead").height() + "px");
    $("table#oxo-table thead tr th").hide();
}

function hookupDialog() {
    $("div#entry-dialog").dialog({
        title: "Maintain Change Log Entry",
        autoOpen: false,
        resizable: false,
        width: "610px",
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
        case "add-entry":
            launchEntryDialog(0);
            break;
        case "edit-entry":
            rowIndex = _OXODataListTable.fnGetPosition($(el).closest('tr')[0]);
            aData = _OXODataListTable.fnGetData(rowIndex);
            launchEntryDialog(parseFloat(aData[15], 10));
            break;
        case "delete-entry":            
            OXOConfirm("Delete Log Entry", "Are you sure you want to delete the selected entry?", "question", deleteEntry);
            break;
    }
}

function deleteEntry() {

    var progid = $("#ht_oxo_prog_id").val();
    rowIndex = _OXODataListTable.fnGetPosition($(_currentNode).closest('tr')[0]);
    aData = _OXODataListTable.fnGetData(rowIndex);
    _logEntryId = aData[15];
    ajaxDeleteEntry(_logEntryId, progid);
}


function ajaxDeleteEntry(entryid, progid) {

    var url = _pathHeader + "/Editor/ajaxDeleteLogEntry?id=" + entryid + "&progid=" + progid; 
    $.ajax({
        type: "POST",
        url: url,
        data: "",
        success: function (data) {
            if (data.Success) {
                location.reload(true);                
            }
            else {
                OXOAlert("Delete Log Entry", "Delete log entry failed.", "exclamation", null);
            }
        },
        error: function (xhr, ajaxOptions, thrownError) {
            alert(xhr.status);
            alert(thrownError);
        }
    });
}


function launchEntryDialog(id) {
    setDialogValue(id);
    $("div#entry-dialog").dialog("open");
    if(id == 0)
        $("div#entry-dialog").dialog('option', 'title', 'Maintain Change Log Entry - Add');
    else
        $("div#entry-dialog").dialog('option', 'title', 'Maintain Change Log Entry - Edit');
}

function setDialogValue(id) {

    var progid = $("input#ht_oxo_prog_id").val();
    var docid = $("input#ht_oxo_doc_id").val();

    var url = _pathHeader + "/Editor/ajaxLogEntryEditor?progid=" + progid + "&docid=" + docid + "&id=" + id + "&required=" + $.now();
    $.ajax({ type: "GET",
        url: url,
        async: false,
        success: function (html) {
            $("div#entry-dialog").find("div#entry-form-placeholder").html(html);
            hookupFormAjax();
            hookupValidator();
            hookupDatePicker();
            hookupAutoComplete();
        },
        error: function (xhr, ajaxOptions, thrownError) {
            alert(xhr.status);
            alert(thrownError);
        }
    });
}

function hookupFormAjax() {
    $('form#frmEntry').submit(function () {

        $('input#ht_rule_prog_id').val($('input#ht_oxo_prog_id').val());

        if ($(this).valid()) {
            $.ajax({
                url: this.action,
                type: this.method,
                data: $(this).serialize(),
                success: function (result) {
                    if (result.Success) {
                        $("div#entry-dialog").dialog("close");
                        location.reload(true);
                    }
                    else {

                        if (result.ErrorMessage != null)
                            alert(result.ErrorMessage);
                        else
                            alert("Sorry, failed to perform operation.");
                    }
                },
                error: function (xhr, ajaxOptions, thrownError) {
                    alert(xhr.status);
                    alert(thrownError);
                }
            });
        }
        else {
            OXOAlert("Save Entry", getValidatorMsg(), "exclamation", null);
        }

        return false;

    });
}

function ToggleAllFolder(openState) {
    $("table#oxo-table").find("td[data-group-level='0']").each(function () {
        if (openState) {
            $(this).addClass('expanded').removeClass('collapsed').parents('.dataTables_wrapper').find('.collapsed-group').trigger('click');
        }
        else {
            $(this).addClass('collapsed').removeClass('expanded').parents('.dataTables_wrapper').find('.expanded-group').trigger('click');
        }
    });

    $("table#oxo-table").find("td[data-group-level='1']").each(function () {
        if (openState) {
            $(this).addClass('expanded').removeClass('collapsed').parents('.dataTables_wrapper').find('.collapsed-group').trigger('click');
        }
        else {
            $(this).addClass('collapsed').removeClass('expanded').parents('.dataTables_wrapper').find('.expanded-group').trigger('click');
        }
    });
}

function ToggleAllClick() {
    ToggleAllFolder(_toggleFolder);
    _toggleFolder = !_toggleFolder;
}

function hookupValidator() {
    $('form#frmEntry').removeData('validator');
    $('form#frmEntry').removeData('unobtrusiveValidation');
    $.validator.unobtrusive.parse('form#frmEntry');
    $.validator.addMethod('date',
    function (value, element, params) {
        if (this.optional(element)) {
            return true;
        }

        var ok = true;
        try {
            $.datepicker.parseDate('dd/mm/yy', value);
        }
        catch (err) {
            ok = false;
        }
        return ok;
    });

}

function getValidatorMsg() {
    var counter = 1;
    var html = 'The following errors have been detected:<br/><br/>';
    $("div.validation-summary-errors ul li").each(function () {
        html = html + counter + ". " + $(this).text() + "<br/>";
        counter++;
    });
    return html;
}

function selectMe(featId) {
    //$("input#feat-input-" + featId).prop("checked", !$("input#feat-input-" + featId).attr("checked"));
    $("li#feat-list-" + featId).toggleClass("selected");
}

function hookupDatePicker() {

    $("#txt_log_entrydate").datepicker({
        showOn: "button",
        buttonImage: "/OXO/Content/Images/Editor/calendar.png",
        buttonImageOnly: true,
        buttonText: "Choose",
        dateFormat: 'dd/mm/yy'
    });

    $("#txt_log_buildeffdate").datepicker({
        showOn: "button",
        buttonImage: "/OXO/Content/Images/Editor/calendar.png",
        buttonImageOnly: true,
        buttonText: "Choose",
        dateFormat: 'dd/mm/yy'

    });

}

function hookupAutoComplete() {

    _availableVersions = [];
    _availableHeaders = [];

    $("ul#lstVersions li").each(function () { _availableVersions.push($(this).html()); });

    $("#txt_log_version").autocomplete({
        source: _availableVersions
    });
}

function hookupOtherEvent() {

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

    $(window).resize(function () { ResizeMe() });
}


// modal dialog functions
function showModalDialog(comp) {
    switch (comp) {
        case "market":
            $("input:checkbox[name=market]:checked").prop("checked", false);
            $("div#edit-market-layer").show().animate({ 'height': '400px' }, 400);
            break;
        case "deriv":
            $("input:checkbox[name=deriv]:checked").prop("checked", false);
            $("div#edit-deriv-layer").show().animate({ 'height': '400px' }, 400);
            break;
        case "feat":
            $("input:checkbox[name=feat]:checked").prop("checked", false);
            $("div#edit-feat-layer").show().animate({ 'height': '400px' }, 400);
            break;

    }

    $("div#edit-comp-layer").show().animate({ 'height': '100%' }, 400);
}

function cancelComponentClick(comp) {

    switch (comp) {
        case "market":
            $("div#edit-market-layer").fadeOut();
            break;
        case "deriv":
            $("div#edit-deriv-layer").fadeOut();
            break;
        case "feat":
            $("div#edit-feat-layer").fadeOut();
            break;

    }

    $("div#edit-comp-layer").show().animate({ 'height': '0px' }, 400);
}

function okComponentClick(comp) {

    switch (comp) {
        case "market":
            var markets = "";
            var currVal = "";
            currVal = $("textarea#txt_log_markets").val();
            if (currVal.length != 0) {
                currVal = currVal + ", "
            }
            $("input:checkbox[name=market]:checked").each(function () {
                markets = markets + $(this).val() + ", ";
            });
            markets = currVal + markets;
            if (markets.length != 0) {
                markets = markets.substring(0, markets.length - 2);
                $("textarea#txt_log_markets").val(markets);
            }
            $("div#edit-market-layer").fadeOut();
            break;
        case "deriv":
            var derivs = "";
            var currVal = "";
            currVal = $("textarea#txt_log_models").val();
            if (currVal.length != 0) {
                currVal = currVal + ", "
            }
            $("input:checkbox[name=deriv]:checked").each(function () {
                derivs = derivs + $(this).val() + ", ";
            });
            derivs = currVal + derivs;
            if (derivs.length != 0) {
                derivs = derivs.substring(0, derivs.length - 2);
                $("textarea#txt_log_models").val(derivs);
            }
            $("div#edit-deriv-layer").fadeOut();
            break;
        case "feat":
            var feats = "";
            var currVal = "";
            currVal = $("textarea#txt_log_features").val();
            if (currVal.length != 0) {
                currVal = currVal + ", "
            }
            $("input:checkbox[name=feat]:checked").each(function () {
                feats = feats + $(this).val() + ", ";
            });
            feats = currVal + feats;
            if (feats.length != 0) {
                feats = feats.substring(0, feats.length - 2);
                $("textarea#txt_log_features").val(feats);
            }
            $("div#edit-feat-layer").fadeOut();
            break;
    }

    $("div#edit-comp-layer").show().animate({ 'height': '0px' }, 400);
}

function GetCookiesTrap(iGroupLevel) {
    return $.cookie("EDTLOGCookie" + iGroupLevel) == null ? "" : $.cookie("EDTLOGCookie" + iGroupLevel);
}

function SetCookieTrap(sGroup, iGroupLevel, state) {

    var cookieDude = GetCookiesTrap(iGroupLevel)

    if (state == "Close") {
        var cookieTrack = cookieDude;
        var testMe = '' + sGroup + ',';
        var res = cookieTrack.replace(testMe, '');
        $.cookie("EDTLOGCookie" + iGroupLevel, res, { expires: 365 })
        if (iGroupLevel == 0) {
            //clear any sub level cookie here two
            subCookieDude = GetCookiesTrap(1);
            var array = subCookieDude.split(',');
            array = $.grep(array, function (value) {
                return value.indexOf(sGroup) < 0;
            });
            subCookieDude = array.join(",");
            $.cookie("EDTLOGCookie1", subCookieDude, { expires: 365 })
        }
    }
    if (state == "Open") {
        var cookieTrack = cookieDude;
        var testMe = '' + sGroup + ',';
        if (cookieTrack.indexOf(testMe) == -1) {
            cookieTrack = cookieTrack + testMe;
            $.cookie("EDTLOGCookie" + iGroupLevel, cookieTrack, { expires: 365 })
        }
    }
}