"use strict";

var model = namespace("FeatureDemandPlanning");

model.Pager = function (pages) {
    var uid = 0;
    var privateStore = {};
    var me = this;

    privateStore[me.id = uid++] = {};
    privateStore[me.id].Pages = pages;
    privateStore[me.id].PageIndex = 0;

    me.ModelName = "Pager";

    me.initialise = function() {
        displayPage();
    }
    me.nextPage = function () {
        setPageIndex(me.getPageIndex() + 1);
    };
    me.previousPage = function () {
        setPageIndex(me.getPageIndex() - 1);
    };
    me.firstPage = function () {
        setPageIndex(0);
    };
    me.lastPage = function () {
        setPageIndex(getPages().length - 1);
    };
    me.getPageIndex = function() {
        return privateStore[me.id].PageIndex;
    };
    me.isFirstPage = function () {
        return me.getPageIndex() == 0;
    };
    me.isLastPage = function () {
        return me.getPageIndex() == getPages().length - 1;
    };

    function setPageIndex(pageIndex) {
        if (pageIndex < 0 || pageIndex > getPages().length - 1) {
            return;
        }
        privateStore[me.id].PageIndex = pageIndex;

        var args = {
            PageIndex: pageIndex,
            Page: getPage(pageIndex),
            IsFirstPage: me.isFirstPage(),
            IsLastPage: me.isLastPage()
        };
        $(document).trigger("notifyBeforePageChanged", args);

        displayPage();

        args = {
            PageIndex: pageIndex,
            Page: getPage(pageIndex),
            IsFirstPage: me.isFirstPage(),
            IsLastPage: me.isLastPage()
        };
        if (pageIndex == 0) {
            $(document).trigger("notifyFirstPage", args);
        } else if (pageIndex == getPages.length - 1) {
            $(document).trigger("notifyLastPage", args);
        } 
        $(document).trigger("notifyPageChanged", args);
    };
    function getPage(pageIndex) {
        return privateStore[me.id].Pages[pageIndex];
    };
    function getPages() {
        return privateStore[me.id].Pages;
    };
    function displayPage() {
        hidePages();
        showCurrentPage();
    };
    function hidePages() {
        getPages().each(function () {
            $(this).hide();
        });
    };
    function showCurrentPage() {
        var pages = getPages().toArray();
        var index = me.getPageIndex()
        $(pages[index]).show();
    };
};