"use strict";

/* Provides cookie functionality for a page */

var model = namespace("FeatureDemandPlanning.Cookies");

model.Cookies = function (params) {
    var uid = 0;
    var privateStore = {};
    var me = this;

    privateStore[me.id = uid++] = {};
    privateStore[me.id].CookieKey = params.CookieKey;

    me.ModelName = "Cookies";

    me.initialise = function () {

    };
    me.getCookieKey = function () {
        return privateStore[me.id].CookieKey;
    };
    me.getCookiesTrap = function (iGroupLevel) {
        var key = me.getCookieKey();
        return $.cookie(key + iGroupLevel) == null ? "" : $.cookie(key + iGroupLevel);
    };
    me.setCookieTrap = function (sGroup, iGroupLevel, state) {
        var cookieDude = me.getCookiesTrap(iGroupLevel);

        if (state == "Close") {
            var cookieTrack = cookieDude;
            var testMe = '' + sGroup + ',';
            var res = cookieTrack.replace(testMe, '');
            $.cookie(key + iGroupLevel, res, { path: "/", expires: 365 })
            if (iGroupLevel == 0) {
                //clear any sub level cookie here two
                subCookieDude = me.getCookiesTrap(1);
                var array = subCookieDude.split(',');
                array = $.grep(array, function (value) {
                    return value.indexOf(sGroup) < 0;
                });
                subCookieDude = array.join(",");
                $.cookie(key + "1", subCookieDude, { path: "/", expires: 365 })
            }
        }
        if (state == "Open") {
            var cookieTrack = cookieDude;
            var testMe = '' + sGroup + ',';
            if (cookieTrack.indexOf(testMe) == -1) {
                cookieTrack = cookieTrack + testMe;
                $.cookie(key + iGroupLevel, cookieTrack, { path: "/", expires: 365 })
            }
        }
    }
}



