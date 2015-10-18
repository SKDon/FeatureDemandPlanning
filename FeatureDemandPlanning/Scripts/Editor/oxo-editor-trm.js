var _OXODataTable;
var _injectOXODataTitle = true;

$(document).ready(function () {

    _OXODataTable = $('#oxo-trm-table').dataTable({
        "scrollY": "580px",
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
        { "bSortable": true, "sClass": "center-no-sort", "sWidth": "0px", "aTargets": [0] },
        { "bSortable": true, "aTargets": [1] },
         { "bSortable": true, "aTargets": [2] },
        { "bSortable": true, "sClass": "center-no-sort", "sWidth": "60px", "aTargets": [3] },
        { "bSortable": true, "sClass": "center-no-sort", "sWidth": "70px", "aTargets": [4] },
        { "bSortable": true, "sClass": "center-no-sort", "sWidth": "70px", "aTargets": [5] },
        { "bSortable": true, "sClass": "center-no-sort", "sWidth": "70px", "aTargets": [6] },
        { "bSortable": true, "sClass": "center-no-sort", "sWidth": "70px", "aTargets": [7] },
        { "bSortable": true, "sClass": "center-no-sort", "sWidth": "70px", "aTargets": [8] },
        { "bSortable": true, "sClass": "center-no-sort", "sWidth": "70px", "aTargets": [9] },
        { "bSortable": true, "sClass": "center-no-sort", "sWidth": "70px", "aTargets": [10] },
        { "bSortable": true, "sClass": "center-no-sort", "sWidth": "70px", "aTargets": [11] }
        ],
        "fnDrawCallback": function (oSettings) {

            if (_injectOXODataTitle) {
                $("<div id='oxo-list-summary'><div id='dtable-title-wrapper'><div id='dtable-title'>X351 14 MY (XJ)</div><div id='dtable-info2'>Take Rates By Market Listing</div></div><div id='cboMarket'></div></div>").insertBefore('div.dataTables_info');
                $("div#cboMarket").html($("div#dtable-market-placeholder").html());
                $('.dropdown-menu').smartmenus({
                    subMenusSubOffsetX: 0,
                    subMenusSubOffsetY: 1
                });
                $("span#market-selected").width($('li#menu-generic').width() - 33);
                _injectOXODataTitle = false;
            }

            formatDataTable();

            $('#oxo-trm-table').find('th.model').contextMenu({ menu: 'oxo-model-menu' }, function (action, el, pos) { performMenuAction(action, el); });
            $('#oxo-trm-table').find('td.row').contextMenu({ menu: 'oxo-feature-menu' }, function (action, el, pos) { performMenuAction(action, el); });

        }
    }).rowGrouping({ bExpandableGrouping: true,
        asExpandedGroups: [""],
        iGroupingOrderByColumnIndex: 0,
        iGroupingColumnIndex: 1,
        fnAfterGroupClicked: function () { ResizeMe(); }
    });

});