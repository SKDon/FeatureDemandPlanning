﻿"use strict";

var model = namespace("FeatureDemandPlanning");

model.Pager = function (pages, params) {
    var uid = 0;
    var privateStore = {};
    var me = this;

    privateStore[me.id = uid++] = {};
    privateStore[me.id].Pages = pages;
    privateStore[me.id].PageIndex = 0;
    privateStore[me.id].PageUri = params.PageUri;

    me.ModelName = "Pager";

    me.initialise = function () {
        displayPage();
    };
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
    me.getPageUri = function () {
        return privateStore[me.id].PageUri;
    };
    me.getPageContent = function (params, callback) {
        $.ajax({
            type: "POST",
            url: me.getPageUri(),
            data: params,
            context: this,
            contentType: "application/json",
            success: function (response) {
                callback.call(this, response);
            },
            error: function (response) {
                alert(response.responseText);
            },
            async: true
        });
    };
    function setPageIndex(pageIndex) {
        if (pageIndex < 0 || pageIndex > getPages().length - 1) {
            return;
        }
        var currentPageIndex = me.getPageIndex();
        var nextPage = currentPageIndex < pageIndex;
        var previousPage = currentPageIndex > pageIndex;

        var args = {
            CurrentPageIndex: currentPageIndex,
            PageIndex: pageIndex,
            Page: getPage(pageIndex),
            IsFirstPage: me.isFirstPage(),
            IsLastPage: me.isLastPage(),
            NextPage: nextPage,
            PreviousPage: previousPage,
            Cancel: false
        };
        $(document).trigger("BeforePageChanged", args);

        // If anything in the before page changed handler has cancelled the event, don't change pages
        if (args.Cancel == true)
        {
            return;
        }
        
        var newPageIndex = pageIndex;
        privateStore[me.id].PageIndex = newPageIndex;
        displayPage();

        var args = {
            CurrentPageIndex: newPageIndex,
            PageIndex: newPageIndex,
            Page: getPage(newPageIndex),
            IsFirstPage: me.isFirstPage(),
            IsLastPage: me.isLastPage(),
            NextPage: false,
            PreviousPage: false,
            Cancel: false
        };
        if (newPageIndex == 0) {
            $(document).trigger("FirstPage", args);
        } else if (pageIndex == getPages.length - 1) {
            $(document).trigger("LastPage", args);
        } 
        $(document).trigger("PageChanged", args);
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