// Removed the document ready check as it simply serves to slow the responsiveness of the page down
//$(document).ready(function () {
    volume = new FeatureDemandPlanning.Volume.OxoVolume(params);
    modal = new FeatureDemandPlanning.Modal.Modal(params);
    cookie = new FeatureDemandPlanning.Cookies.Cookies(params);
    details = new FeatureDemandPlanning.Volume.Details(params);
    addNote = new FeatureDemandPlanning.Volume.AddNote(params);
    marketReview = new FeatureDemandPlanning.Volume.MarketReview(params);
    filter = new FeatureDemandPlanning.Volume.Filter(params);

    page = new FeatureDemandPlanning.Volume.Page([volume, modal, cookie, details, addNote, marketReview, filter]);

    page.initialise();
//});