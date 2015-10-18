var _changeHistoryTable;
var _injectChangeHistoryTitle = true;

$(document).ready(function () {
    hookupChangeDialogs();
    hookupChangeHistoryTable();
});

function hookupChangeDialogs() {

    $("#change-history-dialog").dialog({
        title: "Change History",
        autoOpen: false,
        resizable: false,
        width: "670px",
        position: ["center", 200],
        show: "slide",
        hide: "slide",
        modal: true
    });

    $("#save-change-dialog").dialog({
        title: "Save Change",
        autoOpen: false,
        resizable: false,
        width: "500px",
        position: ["center", 200],
        show: "slide",
        hide: "slide",
        modal: true
    });

    $("#change-log-detail-dialog").dialog({
        title: "Change Sets",
        autoOpen: false,
        resizable: false,
        width: "850px",
        position: ["center", 60],
        show: "slide",
        hide: "slide",
        modal: true
    });
    

};

// move to change log js
function hookupChangeHistoryTable() {

    var _injectChangeHistoryTitle = true;

    _changeHistoryTable = $('#change-history-table').dataTable({
        "scrollY": "60px",
        "scrollCollapse": false,
        "paginate": false,
        "bDeferRender": true,
        "bAutoWidth": false,
        "bProcessing": false,
        "paging": false,
        "sDom": '<"top"lpfi>rt',
        "aaSorting": [[0, 'desc']],
        "aoColumnDefs": [
        { "bSortable": false, "sWidth": "80px", "aTargets": [0] },
        { "bSortable": false, "sWidth": "55px", "aTargets": [1] },        
        { "bSortable": false, "sWidth": "110px", "aTargets": [2] },
        { "bSortable": false, "sWidth": "70px", "aTargets": [3] },
        { "bSortable": false, "sWidth": "42px", "sClass":"center-no-sort", "aTargets": [4] },
        { "bSortable": false, "aTargets": [5] }
        ],
        "fnDrawCallback": function (oSettings) {
            if (_injectChangeHistoryTitle) {
                formatDataTable();
                _injectChangeHistoryTitle = false;
            }
        }
    });
}

// move to change log.js
function showChangeHistoryDialog(docId, modelId, marketId, marketGroupId, featureId, docTitle) {

    var model, market, feature, ending, html;

    model = $("table#clone-oxo-core-table-B thead tr th[data='" + modelId + "']").text();       
    if(_OXOSection == 'MBM'){   
        market = $($("table#oxo-core-table-A td.row[marketid='" + marketId + "']")[1]).text(); 
        html = "Model : " + model + "<br/>Market : " + market;
    }
    else {
        var selectedObject = $("a#selectedObject");
        var mode = (selectedObject.attr("type") == "mg" ? "Market Group" : "Market");
        var caption = selectedObject.text().replace("+", "");
        feature = $($("table#oxo-core-table-A td.row[featureid='" + featureId + "']")[0]).text();
        ending = (feature.length > 65) ? "..." : "";
        html = "Model : " + model + "<br/>" + mode + " : " + caption + "<br/>Feature : " + feature.substring(0, 65) + ending;
    }        
    $("div#change-history-sub-title").html(html).show();
    $("div#change-history-dialog").dialog({ title: "Change History - " + docTitle });
    $("div#change-history-dialog").dialog("open");
    //_changeHistoryTable.fnClearTable();
    ajaxGetChangeHistory(docId, modelId, marketId, marketGroupId, featureId);
}

// move to change log.js
function closeChangeHistoryDialog() {
    $("#change-history-dialog").dialog("close");
}

function showChangeDetailDialog(docId, progId, docTitle) {
    $("div#change-log-detail-dialog").dialog({ title: "Change Sets - " + docTitle });
    $("div#change-log-detail-dialog").dialog("open");
    var url = _pathHeader + '/Editor/ChangeLogTree?docId=' + docId + '&progId=' + progId;
    $('#changeTree').fileTree({
        root: 'root',
        script: url,
        folderEvent: 'click',
        expandSpeed: 300,
        collapseSpeed: 300,
        multiFolder: true
    }, null);
}

function closeChangeLogDetailDialog() {
    $("#change-log-detail-dialog").dialog("close");
}

// move to change log.js
function showSaveChangeDialog() {
  //  $("#reasonText-row").hide();
    $("#cbo_reason").val($("#cbo_reason option:first").val());
    $("textarea#reasonText").val("").focus();
    $("#save-change-dialog").dialog("open");
    $("#save-change-dialog").css("min-height", "");
   // doChangeReason();
}

// move to change log.js
function closeSaveChangeDialog() {
    $("#save-change-dialog").dialog("close");
}

// move to change log.js
/*function doChangeReason() {
    var reason = $("#cbo_reason").val();
    if (reason == "(Please Specifiy)") {
        $("#reasonText").val("");
        $("#reasonText-row").show();
    }
    else {
        $("#reasonText").val(reason);
        $("#reasonText-row").hide();
    }
}
*/

// move to change log.js
function doTextAreaLimit() {
    var $limitNum = 500;
    $('textarea#reasonText').keydown(function () {
        var $this = $(this);
        if ($this.val().length > $limitNum) {
            $this.val($this.val().substring(0, $limitNum));
        }
    });

    $('textarea#reasonText').change(function () {
        var charLeft = 500;
        charLeft = 500 - $(this).val().length;
        $("span#char-left").html("(" + charLeft + " chars left)");
    });

    $('textarea#reasonText').keyup(function () {
        var charLeft = 500;
        charLeft = 500 - $(this).val().length;
        $("span#char-left").html("(" + charLeft + " chars left)");
    });
}

// move to change log.js
function ajaxGetChangeHistory(docId, modelId, marketId, marketGroupId, featureId) {

    var url = _pathHeader + "/Editor/ajaxGetOXOChangeLog?section=" + _OXOSection + "&docId=" + docId + "&modelId=" + modelId + "&marketId=" + marketId;
    url = url + "&marketGroupId=" + marketGroupId + "&featureId=" + featureId + "&required=" + (new Date()).getTime();
    $.ajax({
        type: "POST",
        cache: false,
        url: url,
        dataType: 'json',
        contentType: "application/json; charset=utf-8",
        success: function (data) {
            var logs = data;
            _changeHistoryTable.fnClearTable();
            for (var i = 0; i < data.length; i++) {
                var str = "" + data[i].SetId;
                var row = [str.lpad("0", 10), data[i].VersionLabel, data[i].LastUpdated, data[i].UpdatedBy, data[i].ItemCode, data[i].Reminder];
                _changeHistoryTable.fnAddData(row, false);
            }
            _changeHistoryTable.fnDraw();

        },
        error: function (xhr, ajaxOptions, thrownError) {
            alert(xhr.status);
            alert(thrownError);
        }
    });
}

function changLog_Okay() {
    var proceed = true;
   // var text = $('textarea#reasonText').val();
   // if (text.replace(/ /g, "") == "") {
   //     OXOAlert("Save Change", "Please specify a reminder!", "exclamation", null);
   //     proceed = false;
   // }
    if(proceed)
        saveOXODocument();
}

function ExportExcelChangeSet() {
    var progid = $("input#ht_oxo_prog_id").val();
    var docid = $("input#ht_oxo_doc_id").val();
    _showWaitFlag = false;
    url = _pathHeader + "/Editor/ExcelExportChangeSet?progid=" + progid + "&docid=" + docid
    window.open(url, '_blank');
    var msg = "Your document will appear shortly. Please wait......";
    OXOAlert("Export Change Set", msg, "info", null);
}

