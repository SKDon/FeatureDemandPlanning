"use strict";

$(document).ready(function () {
    marketReviews = new FeatureDemandPlanning.MarketReview.MarketReview(params);
    
    page = new FeatureDemandPlanning.MarketReview.MarketReviewPage(
    [
        marketReviews
    ]);

    page.initialise();
});