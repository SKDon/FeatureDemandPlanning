$(document).ready(function () {
    volume = new FeatureDemandPlanning.Volume.OxoVolume(params);
    modal = new FeatureDemandPlanning.Modal.Modal(params);
    cookie = new FeatureDemandPlanning.Cookies.Cookies(params);
    details = new FeatureDemandPlanning.Volume.Details(params);

    page = new FeatureDemandPlanning.Volume.Page([volume, modal, cookie, details]);

    page.initialise();
});