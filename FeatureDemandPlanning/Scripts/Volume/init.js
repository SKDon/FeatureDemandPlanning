$(document).ready(function () {
    volume = new FeatureDemandPlanning.Volume.OxoVolume(params);
    vehicle = new FeatureDemandPlanning.Vehicle.Vehicle(params);
    pager = new FeatureDemandPlanning.Pager($(".page"), params);
    modal = new FeatureDemandPlanning.Modal.Modal(params);
    cookie = new FeatureDemandPlanning.Cookies.Cookies(params);

    page = new FeatureDemandPlanning.Volume.Page([volume, vehicle, pager, modal, cookie]);

    page.initialise();
});