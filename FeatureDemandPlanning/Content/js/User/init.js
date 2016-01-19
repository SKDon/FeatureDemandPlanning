"use strict";

$(document).ready(function () {
    modal = new FeatureDemandPlanning.Modal.Modal(params);
    user = new FeatureDemandPlanning.User.User(params);
    
    page = new FeatureDemandPlanning.User.UsersPage([user, modal]);

    page.initialise();
});