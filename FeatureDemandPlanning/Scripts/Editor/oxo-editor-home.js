//oxo-admin-OXO
var _OXOSection = "FBM";
var _OXOListTable;
var _injectOXOListTitle = true;
var _toggleFolder = false
var _OXODataListTable;
var _originalTop;
var _syncHeader = false;


$(document).ready(function () {

   // alert($.cookie('current-page'));

    // set up vehicle menu
    $('#vehicle-menu').smartmenus({
        subMenusSubOffsetX: 0,
        subMenusSubOffsetY: 1,
        showOnClick: true
    });
    // set up OXO grid
    //read cookies to see if one is chosen if not 
    // need to determine the first one to use
    var vehName = $.cookie("edit-vehicle");
    var viewMode = $("input#ht_oxo_page").val();
    if (viewMode == "Viewer")
        vehName = $.cookie("view-vehicle");

    if (vehName == null || vehName == "")
        vehName = $("a#selectedMode span.piclink").text();
    popTable(vehName, viewMode);
    $("div#doc-wrapper").show();
    hookupMouseWheel();
    _originalTop = $("#innerbody").position().top;
    ResizeMe();
    hookupPopUp();
});

function setupTable() {

    //set cookie
    var openedGroup = GetCookiesTrap(0).split(',');
    var openedSubGroup = GetCookiesTrap(1).split(',');

    _OXODataListTable = $('#oxo-table').dataTable({
        "iDisplayLength": -1,
        "bLengthChange": false,
        "bDeferRender": true,
        "bAutoWidth": false,
        "bProcessing": false,
        "aaSorting": [[7,'desc']],
        "bPaginate": false,
        "oLanguage": { "sSearch": "Search&nbsp;:&nbsp;" },
        "sDom": '<"top"lfpi>rt',
        "aoColumnDefs": [
                            { "bSortable": true, "aTargets": [0] },
                            { "bSortable": true, "aTargets": [1] },
                            { "bSortable": true, "aTargets": [2] },
                            { "bSortable": true, "sClass": "center-no-sort", "sWidth": "80px", "aTargets": [3] },
                            { "bSortable": false, "sClass": "center-no-sort", "sWidth": "120px", "aTargets": [4] },
                            { "bSortable": false, "sClass": "center-no-sort", "sWidth": "80px", "aTargets": [5] },
                            { "bSortable": false, "sClass": "center-no-sort", "sWidth": "120px", "aTargets": [6] },
                            { "bSortable": false, "sWidth": "0px", "aTargets": [7] }
                            ],
        "fnDrawCallback": function (oSettings) {
            if (_injectOXOListTitle) {
                formatDataTable();
                $('#oxo-table').find('tr.oxo-row[docid!="-1000"]').click(function () { performMenuAction("edit-oxo", $(this)); });                              
            }
        }

    }).rowGrouping({
        bExpandableGrouping: true,
        asExpandedGroups: openedGroup,
        asExpandedGroups2: openedSubGroup,
        iGroupingColumnIndex: 0,
        bExpandableGrouping2: true,
        iGroupingColumnIndex2: 1,
        sGroupingColumnSortDirection: "desc",
        iGroupingOrderByColumnIndex: 7,
        fnAfterGroupClicked: function (sGroup, iGroupLevel, sState) {
            SetCookieTrap(sGroup, iGroupLevel, sState);          
            ResizeMe() 
        }
    });
   
    $('#oxo-table').find('td.subgroup').each(function () {
        if ($(this).text() == "No OXO Document") {
            $(this).contextMenu({ menu: 'oxo-new-menu', offsetY: -160, offsetX: -17, bubble: true }, function (action, el, pos) { performMenuAction(action, el); });
        }
        else {
            $(this).contextMenu({ menu: 'oxo-export-menu', offsetY: -160, offsetX: -17, bubble: true }, function (action, el, pos) { performMenuAction(action, el); });     
        }
    })

    //Find all oxo-rows that are publishd version

    $('#oxo-table').find("tr.published-row").each(function () {
        var count = 0;
        $(this).find("td").each(function () {
            if (count == 0) {
                $(this).attr("colspan", "5");
            }
            else {
                $(this).remove();
            }
            count++;
        });
    });

}


function popTable(vehName, view) {
    var url = _pathHeader + "/Editor/ajaxPopOXOVehDocs?vehName=" + vehName + "&view=" + view + "&required=" + $.now();
    $.ajax({ type: "GET",
        url: url,
        async: false,
        success: function (html) {
            $("div#innerbody").html(html);
        },
        error: function (xhr, ajaxOptions, thrownError) {
            alert(xhr.status);
            alert(thrownError);
        }
    });
    setupTable();
    syncHeader();
}


function syncHeader() {

    var headers = $("#oxo-table thead").html(); // skip the header row
    var cloneHeaders = $("#clone-oxo-table thead").html(headers);
    
    if (!_syncHeader) {
        $('#oxo-table').css("top", "-" + ($("#oxo-table thead").height() - 1) + "px");
        $("table#oxo-table thead tr th").hide();
        _syncHeader = true;
    }
}

function performMenuAction(action, el) {
    _currentNode = el;
    switch (action) {
        case "edit-oxo":
            $.cookie('current-page', 1, { path: "/", expires: 365 });
            ShowWaitMsg();
            url = _pathHeader + "/Editor/" + $(el).attr('section') + "?mode=g&progid=" + $(el).attr('progid') + "&docid=" + $(el).attr('docid')
            window.location.href = url;            
            break;
        case "export-oxo-1":
            var childRow = $(el).parent().next();
            var progid = $(childRow).attr("progid");
            var docid = $(childRow).attr("docid");
            ExportExcel(progid, docid, true);
            break;
        case "export-oxo-2":
            var childRow = $(el).parent().next();
            var progid = $(childRow).attr("progid");
            var docid = $(childRow).attr("docid");
            ExportExcel(progid, docid, false);
            break;
        case "edit-oxo-new":
            var childRow = $(el).parent().next();
            var progid = $(childRow).attr("progid");
            $("input#ht_oxo_prog_id").val(progid);
            var vehName = $("a#selectedMode span.piclink").text();
            var modelYear = $(el).attr("data-group").substring(0, 4).toUpperCase();
            $("div#oxo-new-dialog").find("span.lblCarline").text(vehName + ' ' + modelYear);
            $("div#oxo-new-dialog").dialog("open");
            break;
        case "edit-oxo-clone":
            var childRow = $(el).parent().next();
            var progid = $(childRow).attr("progid");            
            var vehName = $("a#selectedMode span.piclink").text();
            var modelYear = $(el).attr("data-group").substring(0, 4).toUpperCase();
            $("div#oxo-clone-dialog").find("input.lblCarline").val(vehName + ' ' + modelYear);
            $("div#oxo-clone-dialog").find("input#ht_new_prog_id").val(progid);
            $("div#oxo-clone-dialog").dialog("open");
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

function ExportExcel(progid, docid, popDoc) {
    _showWaitFlag = false;
    url = _pathHeader + "/Editor/ExcelExport?progid=" + progid + "&docid=" + docid + "&popDoc=" + popDoc
    //window.location.assign(url);
    window.open(url, '_blank');
    var msg = "Your document will appear shortly. Please wait......";
    OXOAlert("Export OXO", msg, "info", null);
}

function setVehicle(ctl, vehName, mode) {
    var html = "<span class='sub-arrow'>+</span>" + $(ctl).html();
    var ele = $("a#selectedMode");
    ele.html(html);
    ele.attr("data", vehName);
    if (mode == 0) {
        $.cookie("view-vehicle", vehName, { expires: 365 });
        popTable(vehName, 'Viewer');
    }
    else {
        $.cookie("edit-vehicle", vehName, { expires: 365 });
        popTable(vehName, 'Editor');
    }
   

    
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

function hookupPopUp() {
    $("div#oxo-new-dialog").dialog({ 
        title: "Create New OXO",
        autoOpen: false,
        resizable: false,
        width: "400px",
        position: ["center", 200],
        show: "slide",
        hide: "slide",
        modal: true
    });

    $("div#oxo-clone-dialog").dialog({
        title: "Create New OXO By Clone",
        autoOpen: false,
        resizable: false,
        width: "400px",
        position: ["center", 200],
        show: "slide",
        hide: "slide",
        modal: true
    });
}

function closeCreateNewPopUp() {
    $("div#oxo-new-dialog").dialog('close');
}

function closeClonePopUp() {
    $("div#oxo-clone-dialog").dialog('close');
}

function createNewOXODoc() {

    var _option = new Array(4);
    var progId = $("input#ht_oxo_prog_id").val();
    var gateway = $("#new-gateway").val();
    var major = $("#new-major").val();
    var minor = $("#new-minor").val();

    _option[0] = progId;
    _option[1] = gateway;
    _option[2] = major;
    _option[3] = minor;
    
    var url = _pathHeader + "/Editor/ajaxCreateNewOXODoc?required=" + $.now();  
    $.ajax({
        type: "POST",
        cache: false,
        url: url,
        dataType: 'json',
        data: JSON.stringify(_option),
        contentType: "application/json; charset=utf-8",
        success: function (data) {
            if (data.Success) {
                location.reload(true);
            }
            else {
                var msg = "Error creating new OXO document. " + data.Error;
                OXOAlert("Error", msg, "error", null);
            }
        },
        error: function (xhr, ajaxOptions, thrownError) {
            alert(xhr.status);
            alert(thrownError);
        }
    });
}

function cloneForwardOXODoc() {

    var _option = new Array(6);
    var newProgId = $("#ht_new_prog_id").val(); ;
    var gateway = $("#clone-gateway").val();
    var major = $("#clone-major").val();
    var minor = $("#clone-minor").val();
    var selected = $( "#clone-donor option:selected" );
    var docId = $(selected).val();
    var progId = $(selected).attr("data");
    var donor = $(selected).text();

    _option[0] = docId;    
    _option[1] = progId;
    _option[2] = newProgId;
    _option[3] = gateway;
    _option[4] = major;
    _option[5] = minor;
    _option[6] = donor;

    var url = _pathHeader + "/Editor/ajaxCloneOXODoc?required=" + $.now();
    $.ajax({
        type: "POST",
        cache: false,
        url: url,
        dataType: 'json',
        data: JSON.stringify(_option),
        contentType: "application/json; charset=utf-8",
        success: function (data) {
            if (data.Success) {
                location.reload(true);
            }
            else {
                var msg = "Error Cloning new OXO document. " + data.Error;
                OXOAlert("Error", msg, "error", null);
            }
        },
        error: function (xhr, ajaxOptions, thrownError) {
            alert(xhr.status);
            alert(thrownError);
        }
    });

}

function GetCookiesTrap(iGroupLevel) {
    return $.cookie("EDTHOMCookie" + iGroupLevel) == null ? "" : $.cookie("EDTHOMCookie" + iGroupLevel);
}

function SetCookieTrap(sGroup, iGroupLevel, state) {

    var cookieDude = GetCookiesTrap(iGroupLevel)

    if (state == "Close") {
        var cookieTrack = cookieDude;
        var testMe = '' + sGroup + ',';
        var res = cookieTrack.replace(testMe, '');
        $.cookie("EDTHOMCookie" + iGroupLevel, res, { expires: 365 })
        if (iGroupLevel == 0) {
            //clear any sub level cookie here two
            subCookieDude = GetCookiesTrap(1);
            var array = subCookieDude.split(',');
            array = $.grep(array, function (value) {
                return value.indexOf(sGroup) < 0;
            });
            subCookieDude = array.join(",");
            $.cookie("EDTHOMCookie1", subCookieDude, { expires: 365 })
        }
    }
    if (state == "Open") {
        var cookieTrack = cookieDude;
        var testMe = '' + sGroup + ',';
        if (cookieTrack.indexOf(testMe) == -1) {
            cookieTrack = cookieTrack + testMe;
            $.cookie("EDTHOMCookie" + iGroupLevel, cookieTrack, { expires: 365 })
        }
    }
}


