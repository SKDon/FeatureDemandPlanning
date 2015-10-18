//oxo-admin-OXO
var _OXOSection = "FBM";
var _OXOListTable;
var _injectOXOListTitle = true;
var _toggleFolder = false
var _OXODataListTable;
var _view = "";

$(document).ready(function () {
    ShowWaitMsg();
    // set up OXO grid
    _view = getParameterByName('view');
    switch (_view) {
        case "model":
            setupByModelTable();
            break;
        case "area":
            setupByAreaTable();
            break;
        default:
            setupByRuleTable();
            break;
    }

    //sync header:
    syncHeader();
    $('#view-mode-menu').smartmenus({ subMenusSubOffsetX: 0, subMenusSubOffsetY: 1, showOnClick: true });
    $('#show-mode-menu').smartmenus({ subMenusSubOffsetX: 0, subMenusSubOffsetY: 1, showOnClick: true });

    $("div#doc-wrapper").show();
    hookupMouseWheel();
    ResizeMe();
    HideWaitMsg();
});

function setupByRuleTable() {

    _OXODataListTable = $('#oxo-table').dataTable({
        "bDestroy": true,
        "iDisplayLength": -1,
        "bLengthChange": false,
        "bDeferRender": true,
        "bAutoWidth": false,
        "bProcessing": false,
        "aaSorting": [[3, 'asc']],
        "bPaginate": false,
        "oLanguage": { "sSearch": "Search&nbsp;:&nbsp;" },
        "sDom": '<"top"lfpi>rt',
        "aoColumnDefs": [
                            { "bSortable": true, "aTargets": [0] },
                            { "bSortable": false, "sClass": "center-no-sort", "sWidth": "60px", "aTargets": [1] },
                            { "bSortable": true, "aTargets": [2] },                           
                            { "bSortable": true, "sWidth": "230px", "aTargets": [3] },
                            { "bSortable": true, "sWidth": "100px", "aTargets": [4] },
                            { "bSortable": true, "sWidth": "150px", "aTargets": [5] },
                            { "bSortable": true, "sClass": "center-no-sort", "sWidth": "100px", "aTargets": [6] }
                            ],
        "fnDrawCallback": function (oSettings) {
            if (_injectOXOListTitle) {
                formatDataTable();
                _injectOXOListTitle = false;
            }
            ToggleAllFolder(true);
        }
    }).rowGrouping({
        bExpandableGrouping: true,
        asExpandedGroups: [""],
        iGroupingColumnIndex: 0,       
        fnAfterGroupClicked: function () { ResizeMe(); }
    });

}

function setupByModelTable() {
 
    _OXODataListTable = $('#oxo-table').dataTable({
        "bDestroy": true,
        "iDisplayLength": -1,
        "bLengthChange": false,
        "bDeferRender": true,
        "bAutoWidth": false,
        "bProcessing": false,
        "aaSorting": [[3, 'asc']],
        "bPaginate": false,
        "oLanguage": { "sSearch": "Search&nbsp;:&nbsp;" },
        "sDom": '<"top"lfpi>rt',
        "aoColumnDefs": [
                           { "bSortable": true, "aTargets": [0] },
                           { "bSortable": false, "sClass": "center-no-sort", "sWidth": "60px", "aTargets": [1] },
                           { "bSortable": false, "sClass": "center-no-sort", "sWidth": "80px", "aTargets": [2] },
                           { "bSortable": true, "aTargets": [3] },
                           { "bSortable": true, "sWidth": "230px", "aTargets": [4] },
                           { "bSortable": true, "sWidth": "100px", "aTargets": [5] },
                           { "bSortable": true, "sWidth": "150px", "aTargets": [6] },                           
                           { "bSortable": true, "sClass": "center-no-sort", "sWidth": "100px", "aTargets": [7] }
                       ],
        "fnDrawCallback": function (oSettings) {
            if (_injectOXOListTitle) {
                formatDataTable();
                _injectOXOListTitle = false;
            }
            ToggleAllFolder(true);
        }
    }).rowGrouping({
        bExpandableGrouping: true,
        asExpandedGroups: [""],
        iGroupingColumnIndex: 0,
        fnAfterGroupClicked: function () { ResizeMe(); }
    });

}

function setupByAreaTable() {

    _OXODataListTable = $('#oxo-table').dataTable({
        "bDestroy": true,
        "iDisplayLength": -1,
        "bLengthChange": false,
        "bDeferRender": true,
        "bAutoWidth": false,
        "bProcessing": false,
        "aaSorting": [[3, 'asc']],
        "bPaginate": false,
        "oLanguage": { "sSearch": "Search&nbsp;:&nbsp;" },
        "sDom": '<"top"lfpi>rt',
        "aoColumnDefs": [
                            { "bSortable": true, "aTargets": [0] },
                            { "bSortable": false, "sClass": "center-no-sort", "sWidth": "60px", "aTargets": [1] },
                            { "bSortable": false, "sClass": "center-no-sort", "sWidth": "80px", "aTargets": [2] },
                            { "bSortable": true, "aTargets": [3] },                            
                            { "bSortable": true, "sWidth": "300px", "aTargets": [4] },
                            { "bSortable": true, "sWidth": "100px", "aTargets": [5] },
                            { "bSortable": true, "sWidth": "150px", "aTargets": [6] },
                            { "bSortable": true, "sClass": "center-no-sort", "sWidth": "100px", "aTargets": [7] }
                            ],
        "fnDrawCallback": function (oSettings) {
            if (_injectOXOListTitle) {
                formatDataTable();
                _injectOXOListTitle = false;
            }
            ToggleAllFolder(true);
        }
    }).rowGrouping({
        bExpandableGrouping: true,
        asExpandedGroups: [""],
        iGroupingColumnIndex: 0,
        fnAfterGroupClicked: function () { ResizeMe(); }
    });

}

function syncHeader() {
    var headers = $("#oxo-table thead").html(); // skip the header row
    var cloneHeaders = $("#clone-oxo-table thead").html(headers);
    $('#oxo-table').css("top", "-" + ($("#oxo-table thead").height() - 1) + "px");
    $("table#oxo-table thead tr th").hide();
}

function performMenuAction(action, el) {
    _currentNode = el;
    switch (action) {
        case "edit-oxo-X":
            ShowWaitMsg();           
            url = _pathHeader + "/Editor/" + $(el).attr('section') + "?mode=g&progid=" + $(el).attr('progid') + "&docid=" + $(el).attr('docid')
            window.location.href = url;
            break;        
    }
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

function setMode(mode, modeName) {
    var html = "<span class='sub-arrow'>+</span>" + modeName;
    var ele = $("a#selectedMode");
    ele.html(html);
    ele.attr("data", mode);  
}

function setShow(mode, modeName) {
    var html = "<span class='sub-arrow'>+</span>" + modeName;
    var ele = $("a#selectedShow");
    ele.html(html);
    ele.attr("data", mode);   
}

function goButton() {

    var docid = $("input#ht_oxo_doc_id").val();
    var progid = $("input#ht_oxo_prog_id").val();
    var objectid = $("input#ht_oxo_obj_id").val();
    var level = $("input#ht_oxo_level").val();
    var mode = $("a#selectedMode").attr("data");
    var show = $("a#selectedShow").attr("data");

     ShowWaitMsg();
     var url = _pathHeader + "/Editor/ValidateDoc?show=" + show + "&view=" + mode + "&mode=" + level + "&progid=" + progid + "&docid=" + docid + "&objectid=" + parseInt(objectid);
     window.location.href = url;
}

function getParameterByName(name) {
    name = name.replace(/[\[]/, "\\[").replace(/[\]]/, "\\]");
    var regex = new RegExp("[\\?&]" + name + "=([^&#]*)"),
        results = regex.exec(location.search);
    return results === null ? "" : decodeURIComponent(results[1].replace(/\+/g, " "));
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