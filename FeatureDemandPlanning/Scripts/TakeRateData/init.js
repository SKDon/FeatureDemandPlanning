$(document).ready(function () {
    volume = new FeatureDemandPlanning.Volume.OxoVolume(params);
    modal = new FeatureDemandPlanning.Modal.Modal(params);
    cookie = new FeatureDemandPlanning.Cookies.Cookies(params);

    page = new FeatureDemandPlanning.Volume.Page([volume, modal, cookie]);

    page.initialise();
});