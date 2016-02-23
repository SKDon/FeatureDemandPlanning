namespace FeatureDemandPlanning.Model.Enumerations
{
    public enum EmailEvent
    {
        NotSet = 0,
        SentForMarketReview,
        MarketReviewReceived,
        MarketReviewRejected,
        MarketReviewApproved,
        Error
    }
}
