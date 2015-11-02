"use strict";

/* Provides generic progress update functionality for a page */

var model = namespace("FeatureDemandPlanning.Progress");

model.Progress = function (params) {
    var uid = 0;
    var privateStore = {};
    var me = this;

    privateStore[me.id = uid++] = {};
    privateStore[me.id].Target = null;
    privateStore[me.id].Config = params.Configuration;
    
    me.ModelName = "Modal";

    me.setTarget = function (target) {
        return privateStore[me.id].Target = target;
    }
    me.getTarget = function () {
        return privateStore[me.id].Target;
    };
    me.getConfiguration = function () {
        return privateStore[me.id].Configuration;
    };
    me.initialise = function () {
    };
    me.showProgress = function (parameters) {
        var opts = {
              lines: 13 // The number of lines to draw
            , length: 28 // The length of each line
            , width: 14 // The line thickness
            , radius: 42 // The radius of the inner circle
            , scale: 1 // Scales overall size of the spinner
            , corners: 1 // Corner roundness (0..1)
            , color: '#000' // #rgb or #rrggbb or array of colors
            , opacity: 0.25 // Opacity of the lines
            , rotate: 0 // The rotation offset
            , direction: 1 // 1: clockwise, -1: counterclockwise
            , speed: 1 // Rounds per second
            , trail: 60 // Afterglow percentage
            , fps: 20 // Frames per second when using setTimeout() as a fallback for CSS
            , zIndex: 2e9 // The z-index (defaults to 2000000000)
            , className: 'spinner' // The CSS class to assign to the spinner
            , top: '50%' // Top position relative to parent
            , left: '50%' // Left position relative to parent
            , shadow: true // Whether to render a shadow
            , hwaccel: true // Whether to use hardware acceleration
            , position: 'absolute' // Element positioning
        }
        var spinner = new Spinner(opts).spin(me.getTarget());
    };
};