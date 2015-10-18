var _pathHeader = "/FeatureDemandPlanning";
var _menuTimer = null;
var _vSlider = null;
var _hSlider = null;
var _showWaitFlag = true;
var _scrollFactor = 3;

function initialiseMaster() {

    $("#doc-waiting").hide();

    _vSlider = $("#v-slider").bootstrapSlider({
        orientation: "vertical",
        range: "min",
        min: -100,
        max: 0,
        value: 0,
        step: 5
    }).on("slide", function (value) {
        $("#innerbody").css("top", '' + ui.value + 'px');
    });

    _hSlider = $("#h-slider").bootstrapSlider({
        range: "min",
        orientation: "horizontal",
        min: 0,
        max: 100,
        value: 0,
        step: 5
    }).on("slide", function (value) {
        DoHorizontalScroll(value);
    });

    ResizeMe();
    $(window).resize(function () { ResizeMe() });

    $(document).ajaxStart(function () {
        ShowWaitMsg();
    });

    $(document).ajaxComplete(function (event, request, settings) {
        HideWaitMsg();
    });

    //HideWaitMsg();
}

//$(document).ready(function () {

//    initialiseMaster();
//});

function ShowWaitMsg() {
    if (_showWaitFlag) {
        $('#overlay').show();
        $('#fade').show();
    }
}

function HideWaitMsg() {
    $('#overlay').hide();
    $('#fade').hide();
}

function ResizeMe() {

    var windowHeight = $(window).height();
    var windowWidth = $(window).width();
    var headerHeight = $('div#header').height();
    var headerWidth = $('div#header').width();
    var footerHeight = $('div#footer').height();
    var footerWidth = $('div#footer').width();
    var bodyHeight = windowHeight - headerHeight - footerHeight - 10;
    var vSlider = $('div#v-slider');
    var hSlider = $('div#h-slider');
    var bodyCtl = $('div#body');
  //  var underyLayWidth = Math.round(windowWidth * 96/100);

  //  if (headerWidth != underyLayWidth) {
  //      $('div#header').width(underyLayWidth);
  //      $('div#body1').width(underyLayWidth);
  //  }
    $('body').height(windowHeight);
    if (bodyHeight > 100) {
        bodyCtl.height(bodyHeight);
        vSlider.height(bodyHeight - 40);
        vSlider.css("top", (headerHeight + 20) + 'px');
    }

    hSlider.width(footerWidth - 70);

    checkScrollbar();
    if (windowWidth < 980) {
        //vSlider.hide();
    }
}

function formatDataTable() {
    $('table.display tbody tr td:first-child').css('border-left', '0px solid #478862');
    $('table.display tbody tr td:last-child').css('border-right', '0px solid #478862');
    $('table.display thead tr th:first-child').css('border-left', '0px solid white');
    $('table.display thead tr th:last-child').css('border-right', '0px solid white');
    $('a.paginate_enabled_previous,a.paginate_disabled_previous').text('').attr('title', 'Previous Page');
    $('a.paginate_disabled_next,a.paginate_enabled_next').text('').attr('title', 'Next Page');
    var headerHeight = $('table.display thead').height();
    $('table.display').css("top", "-" + headerHeight + 'px');
    $('div#dtable-info').text($('div.dataTables_info').text());
}

function trim(s) {
    if (typeof (s) === 'undefined') { return; }
    return s.replace(/^\s+|\s+$/g, "");
}


function doMenusTimer() {

    // both _menuTimer and _menuRendered are gloabl var declared in Master.js
    $('ul.contextMenu').mouseover(function (e) {
        clearTimeout(_menuTimer);
    });

    $('ul.contextMenu').mouseleave(function (e) {
        _menuTimer = setTimeout(function () {
            $('ul.contextMenu').hide();
        }, 800);
    });
}

function checkScrollbar() {

    var viewport = $("div#viewport");
    var innerbody = $("div#innerbody");
    var vSlider = $('div#v-slider');
    var hSlider = $('div#h-slider');

    if (viewport.height() < innerbody.height() - 20) {
        var diff = viewport.height() - innerbody.height() - 10;
        vSlider.show();
        _vSlider.bootstrapSlider("option", "min", diff);
        //        _vSlider.slider("option", "step", 3);
        _vSlider.bootstrapSlider("value", 0);
    }
    else {
        innerbody.css("top", "0px");
        vSlider.hide();
    }

        if (viewport.width() < innerbody.width()) {
            var diff = innerbody.width() - viewport.width() + 130;
            hSlider.show();
            _hSlider.bootstrapSlider("option", "max", diff);
        }
        else
        {
            innerbody.css("left", "0px");
            if ($('div#right-pane-header').length == 1) {
                $('div#right-pane-header').css("left", "0");
                $('div#right-pane').css("left", "0");
            }
            hSlider.hide();
        }

}


function resetScrollbar() {
    $("#innerbody").css("top", "0px").css("left", "0px");
    _hSlider.bootstrapSlider("option", "value", 0);
    _vSlider.bootstrapSlider("option", "value", 0);
}


String.prototype.lpad = function (padString, length) {
    var str = this;
    while (str.length < length)
        str = padString + str;
    return str;
}

String.prototype.startsWith = function (prefix) {
    return this.indexOf(prefix) === 0;
}

String.prototype.endsWith = function (suffix) {
    return this.match(suffix + "$") == suffix;
};