var _OXOSection = "FRS";
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
    _OXODataListTable = $('#oxo-table').dataTable({
        "iDisplayLength": -1,
        "bLengthChange": false,
        "bDeferRender": true,
        "bAutoWidth": false,
        "bProcessing": false,
        "aaSorting": [[2, 'asc']],
        "bPaginate": false,
        "oLanguage": { "sSearch": "Search&nbsp;:&nbsp;" },
        "sDom": '<"top"lfpi>rt',
        "aoColumnDefs": [
                            { "bSortable": true, "aTargets": [0] },
                            { "bSortable": false, "sClass": "rule-col-80", "aTargets": [1] },
                            { "bSortable": true, "aTargets": [2] },
                            { "bSortable": true, "sClass": "rule-col-400", "aTargets": [3] },
                            { "bSortable": true, "sClass": "rule-col-80", "aTargets": [4] },
                            { "bSortable": true, "sClass": "rule-col-80", "aTargets": [5] },
                            { "bSortable": true, "sClass": "rule-col-50",  "aTargets": [6] }
                            ],
        "fnDrawCallback": function (oSettings) {

            if (_injectOXOListTitle) {
                formatDataTable();
                _injectOXOListTitle = false;
            }
            ToggleAllFolder(true);
        },

        "fnRowCallback": function (nRow, aData, iDisplayIndex) {
            nRow.className = "oxo-row even";
            return nRow;
        }

    }).rowGrouping({
        bExpandableGrouping: true,
        asExpandedGroups: [""],
        iGroupingColumnIndex: 0,
        fnAfterGroupClicked: function () { ResizeMe(); }
    });

    syncHeader();

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
        url: _pathHeader + "/Editor/ajaxPopFRS?progid=" + progid + "&docid=" + docid +"&required=" + $.now(),
        success: function (data) {
            _OXODataListTable.fnClearTable();
            for (var i = 0; i < data.length; i++) {
                var active = data[i].Active ? "Yes" : "No";
                var row = [data[i].RuleGroup, $.strPad(data[i].Id, 6), data[i].RuleResponse, data[i].RuleReason, data[i].Owner, data[i].RuleCategory, active];
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
    $('#oxo-table').find('tr.group-item').contextMenu({ menu: 'oxo-rule-menu', offsetY: -225, offsetX: -45, bubble: true }, function (action, el, pos) { performMenuAction(action, el); });
}

function syncHeader() {
    var headers = $("#oxo-table thead").html();
    var cloneHeaders = $("#clone-oxo-table thead").html(headers);
    $('#oxo-table').css("top", "-" + $("#oxo-table thead").height() + "px");
    $("table#oxo-table thead tr th").hide();
}

function hookupDialog() {
    $("div#rule-dialog").dialog({
        title: "Maintain Rules",
        autoOpen: false,
        resizable: false,
        width: "445px",
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
        case "add-oxo-rule":
            launchRuleDialog(0);
            break;
        case "edit-oxo-rule":
            rowIndex = _OXODataListTable.fnGetPosition($(el)[0]);
            aData = _OXODataListTable.fnGetData(rowIndex);
            launchRuleDialog(parseFloat(aData[1],10));
            break;
        case "delete-oxo-rule":
            rowIndex = _OXODataListTable.fnGetPosition($(el)[0]);
            aData = _OXODataListTable.fnGetData(rowIndex);
            if (confirm("Are you sure you want to delete the selected rule?")) {
                ajaxDeleteRule(parseFloat(aData[1], 10));
            }
            break;
    }
}

function launchRuleDialog(id) {
    setDialogValue(id);
    $("div#rule-dialog").dialog("open");
}

function setDialogValue(id) {

    var progid = $("input#ht_oxo_prog_id").val();
    var url = _pathHeader + "/Editor/ajaxRuleEditor?progId=" + progid + "&id=" + id + "&required=" + $.now();
    $.ajax({ type: "GET",
        url: url,
        async: false,
        success: function (html) {
            $("div#rule-dialog").find("div#form-placeholder").html(html);
            hookupRuleAjax();
            hookupValidator();
            hookupSwitch();
        },
        error: function (xhr, ajaxOptions, thrownError) {
            alert(xhr.status);
            alert(thrownError);
        }
    });
}

function ajaxDeleteRule(id) {// to-do; need to check if rule has been applied to a feature
    var url = _pathHeader + "/Editor/ajaxDeleteRule?id=" + id + "&required=" + $.now();
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

function hookupSwitch() {
    $('div.switch_yes_no').iphoneSwitch(
            function (elem) {
                $(elem).attr('data', 'yes');
                $("input#ht_rule_active").val("True");
            },
            function (elem) {
                $(elem).attr('data', 'no');
                $("input#ht_rule_active").val("False");
            });
}

function hookupRuleAjax() {
    $('form#frmRules').submit(function () {
        
        $('input#ht_rule_prog_id').val($('input#ht_oxo_prog_id').val());

        if ($(this).valid()) {
            $.ajax({
                url: this.action,
                type: this.method,
                data: $(this).serialize(),
                success: function (result) {
                    if (result.Success) {
                        popTable(progid, docid);
                        $("div#rule-dialog").dialog("close");
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
            alert(getValidatorMsg());
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
    $('form#frmRules').removeData('validator');
    $('form#frmRules').removeData('unobtrusiveValidation');
    $.validator.unobtrusive.parse('form#frmRules');
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

function selectMe(featId) {
    //$("input#feat-input-" + featId).prop("checked", !$("input#feat-input-" + featId).attr("checked"));
    $("li#feat-list-" + featId).toggleClass("selected");
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