//oxo-admin-OXO
var _OXOSection = "FPS";
var _minLeftWidth = 400;


function hookupTableA() {

    _OXODataTableA = $('#oxo-core-table-A').dataTable({
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
                            { "bSortable": false, "aTargets": [1] },
                            { "bSortable": false, "sClass": "center-no-sort", "sWidth": "60px", "aTargets": [2] }                           
                            ],
        "fnDrawCallback": function (oSettings) {
            if (_injectOXODataTitleA) {
                formatDataTable();
                _injectOXODataTitleA = false;
            }
            $('#oxo-core-table-A').find("td[data-group-level='0']").each(function () {
                $(this).addClass('expanded').removeClass('collapsed').parents('.dataTables_wrapper').find('.collapsed-group').trigger('click');
                $(this).mousedown(function () {
                    _fireStarter = "TableA";
                })
            });
        }
    }).rowGrouping({
        bExpandableGrouping: true,
        asExpandedGroups: [""],
        iGroupingOrderByColumnIndex: 0,
        iGroupingColumnIndex: 0,
        fnAfterGroupClicked: function (sGroup, iGroupLevel, sState) {
            SyncHeader('B', sGroup, sState);
            ResizeMeEditor();
        }
    });

}

function hookupTableB() {

    _OXODataTableB = $('#oxo-core-table-B').dataTable({
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
        "fnDrawCallback": function (oSettings) {

            if (_injectOXODataTitleB) {
                formatDataTable();
                _injectOXODataTitleB = false;
            }

            $('#oxo-core-table-B').find("td[data-group-level='0']").each(function () {
                $(this).addClass('expanded').removeClass('collapsed').parents('.dataTables_wrapper').find('.collapsed-group').trigger('click');
                $(this).mousedown(function () {
                    _fireStarter = "TableB";
                })
            });


            $("table#oxo-core-table-B td.group-item-expander").each(function () {
                var group = $(this).attr("data-group");
                $(this).text('');
                $(this).css("padding", "0px");
                //  var html = "<div class='blocker' onclick='block_click(&quot;" + group + "&quot;)'></div>";
                //  $(this).append(html);
            });




        }
    }).rowGrouping({
        bExpandableGrouping: true,
        asExpandedGroups: [""],
        iGroupingOrderByColumnIndex: 0,
        iGroupingColumnIndex: 1,
        fnAfterGroupClicked: function (sGroup, iGroupLevel, sState) {
            SyncHeader('A', sGroup, sState);
            ResizeMeEditor();
        }
    });

    _OXODataTableB.fnSetColumnVis(2, false);
}


function performMenuAction(action, el) {
    _currentNode = el;
    switch (action) {
        case "add-pack":
            launchPackEditor(0);
            break;
        case "edit-pack":
            var packid = $(el).parent().next().attr("row-id");
            launchPackEditor(packid);
            break;
        case "remove-pack":
            if (_dirtyEditor) {
                alert("There are unsaved changes, please save/undo your changes before removing pack.");
            }
            else {
                if (confirm("Are you sure you want to remove this pack from this OXO?")) {
                    var progid = $("input#ht_oxo_prog_id").val();
                    var packname = $(_currentNode).text();
                    alert(packname);
                    ajaxRemovePack(progid, packname);
                }
            }
            break;
        case "add-feature":
            if (_dirtyEditor) {
                alert("There are unsaved changes, please save/undo your changes before adding feature.");
            }
            else {
                var progId = $("input#ht_oxo_prog_id").val();
                var packId = $(_currentNode).parent().attr("row-id");
                launchFeatureLookUpDialogs("programme", progId, packId, dcid, "ALL", AddFeaturesToPack);
            }
            break;
        case "remove-feature":
            if (_dirtyEditor) {
                alert("There are unsaved changes, please save/undo your changes before removing feature.");
            }
            else {
                if (confirm("Are you sure you want to remove this feature from this pack?")) {
                    var progid = $("input#ht_oxo_prog_id").val();
                    var packid = $(_currentNode).parent().attr("row-id");
                    var featid = $(_currentNode).attr("featureid");
                    ajaxRemoveFeature(progid, packid, featid);
                }
            }
            break;
        case "set-all-feature":
            break;
        case "clear-all-feature":
            break;
    }
}

function hookupContextMenu() {
    $('#clone-oxo-core-table-B').find('tr th').contextMenu({ menu: 'oxo-model-menu', offsetY: -225, offsetX: -44, bubble: true }, function (action, el, pos) { performMenuAction(action, el); });
    $('#oxo-core-table-A').find('td.row').contextMenu({ menu: 'oxo-pack-menu', offsetY: -225, offsetX: -45, bubble: true }, function (action, el, pos) { performMenuAction(action, el); });
    $('#oxo-core-table-A').find('td.group').contextMenu({ menu: 'oxo-pack-top-menu', offsetY: -225, offsetX: -45, bubble: true }, function (action, el, pos) { performMenuAction(action, el); });
    $("div#pack-editor-dialog").dialog({
        title: "Maintain Feature Packs",
        autoOpen: false,
        resizable: false,
        width: "388px",
        position: ["center", 250],
        show: "slide",
        hide: "slide",
        modal: true
    });
}

function AddFeaturesToPack() {

    var progId = $("input#ht_oxo_prog_id").val();
    var packid = $(_currentNode).parent().attr("row-id");
    var url = _pathHeader + "/Editor/ajaxAddFeaturesPack?progid=" + progId + "&packid=" + packid  + "&required=" + (new Date()).getTime();
    
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
                alert("Error adding features. " + data.Error);
            }
        },
        error: function (xhr, ajaxOptions, thrownError) {
            alert(xhr.status);
            alert(thrownError);
        }
    });
}

function ajaxRemoveFeatureFromPack(progid, packid, featid) {
    var url = _pathHeader + "/Editor/ajaxRemoveFeatureForPack?progid=" + progid + "&packid=" + packid + "&featid=" + featid + "&required=" + (new Date()).getTime();
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
                alert("Remove feature failed." + data.Error);
            }
        },
        error: function (xhr, ajaxOptions, thrownError) {
            alert(xhr.status);
            alert(thrownError);
        }
    });
}

function ajaxRemovePack(progid, packname) {
    var safeName = encodeURIComponent(packname);
    var url = _pathHeader + "/Editor/ajaxRemovePackForProg?progid=" + progid + "&packname=" + safeName + "&required=" + (new Date()).getTime();
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
                alert("Remove feature failed." + data.Error);
            }
        },
        error: function (xhr, ajaxOptions, thrownError) {
            alert(xhr.status);
            alert(thrownError);
        }
    });
}

function launchPackEditor(id) {
    var url = _pathHeader + "/Editor/ajaxPackEditor?packid=" + id + "&required=" + $.now();
    $.ajax({ type: "GET",
        url: url,
        async: false,
        success: function (html) {
            $("div#pack-editor-dialog").find("div#form-placeholder").html(html);
            hookupPackAjax();
            hookupValidator();
            // hookupOtherEvent();            
        },
        error: function (xhr, ajaxOptions, thrownError) {
            alert(xhr.status);
            alert(thrownError);
        }
    });

    $("div#pack-editor-dialog").dialog("open");
}

function hookupPackAjax() {
    $('form#frmPack').submit(function () {
        $("input#ht_pack_prog_id").val($("input#ht_oxo_prog_id").val());            
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
                            alert(result.ErrorMessage);
                        else
                            alert("Sorry, fail to perform operation.");
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


function hookupValidator() {
    $('form#frmPack').removeData('validator');
    $('form#frmPack').removeData('unobtrusiveValidation');
    $.validator.unobtrusive.parse('form#frmPack');
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

function cellClick(ele) {

    var inputMode = $("a#selectedMode").attr("data");
    if (!$(ele).hasClass("group")) {
        // now check if this is locked or suggested data
        if ($(ele).hasClass("locked")) {
            alert("According to the Feature by Market Listing of this OXO Document, \nthis option pack is not availble for the select derivative.");
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
                if ($(ele).text() == "" || inputMode != $(ele).text()) {
                    if ($(ele).hasClass("isDirty")) {
                        $(ele).text($(ele).attr("prevval"));
                    }
                    else {
                        $(ele).text(inputMode);
                    }
                }
                else {
                    if ($(ele).hasClass("prev-generic")) {
                        $(ele).text($(ele).attr("prevval"));
                        $(ele).removeClass("isDirty");
                        $(ele).addClass("generic")
                    }
                    if ($(ele).hasClass("prev-mglevel")) {
                        $(ele).text($(ele).attr("prevval"));
                        $(ele).removeClass("isDirty");
                        $(ele).addClass("mglevel")
                    }
                    if (!($(ele).hasClass("prev-generic") && $(ele).hasClass("prev-mglevel"))) {
                        $(ele).text($(ele).attr("prevval"));
                        $(ele).removeClass("isDirty");

                    }
                }
                if ($(ele).text() == $(ele).attr("prevval"))
                    $(ele).removeClass("isDirty");
                else
                    $(ele).addClass("isDirty");
            }
        }

        ToggleSaveButtons();
    }
}
