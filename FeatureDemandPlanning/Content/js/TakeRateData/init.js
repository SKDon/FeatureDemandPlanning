// Removed the document ready check as it simply serves to slow the responsiveness of the page down

    volume = new FeatureDemandPlanning.Volume.OxoVolume(params);
    modal = new FeatureDemandPlanning.Modal.Modal(params);
    //cookie = new FeatureDemandPlanning.Cookies.Cookies(params);
    details = new FeatureDemandPlanning.Volume.Details(params);
    addNote = new FeatureDemandPlanning.Volume.AddNote(params);
    marketReview = new FeatureDemandPlanning.Volume.MarketReview(params);
    publish = new FeatureDemandPlanning.Volume.Publish(params);
    filter = new FeatureDemandPlanning.Volume.Filter(params);

    page = new FeatureDemandPlanning.Volume.Page([volume, modal, details, addNote, marketReview, filter, publish]);
    page.showSpinner("Loading");

    var panel = $("#" + page.getIdentifierPrefix() + "_TakeRateDataPanel");
    panel.height = page.calcPanelHeight() + "px";

    page.initialise();
