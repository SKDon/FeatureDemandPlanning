using System;
using FeatureDemandPlanning.Model.Empty;
using FeatureDemandPlanning.Model.Enumerations;

namespace FeatureDemandPlanning.Model.Parameters
{
    public class TakeRateParameters : JQueryDataTableParameters
    {
        public int? DocumentId { get; set; }
        public int? TakeRateId { get; set; }
        public int? TakeRateDataItemId { get; set; }
        public int? MarketId { get; set; }
        public int? MarketGroupId { get; set; }
        public string FilterMessage { get; set; }
        public int? TakeRateStatusId { get; set; }
        public TakeRateDataItemAction Action { get; set; }
        public TakeRateResultMode Mode { get; set; }
        public string ModelIdentifier { get; set; }
        public string FeatureIdentifier { get; set; }
        public string Comment { get; set; }
        public MarketReviewStatus MarketReviewStatus { get; set; }
        public string Filter { get; set; }

        public FdpChangeset Changeset { get; set; }

        public TakeRateParameters()
        {
            Action = TakeRateDataItemAction.NotSet;
            Changeset = new EmptyFdpChangeset();
            MarketReviewStatus = MarketReviewStatus.NotSet;
            Mode = TakeRateResultMode.PercentageTakeRate;
        }

        public object GetActionSpecificParameters()
        {
            switch (Action)
            {
                case TakeRateDataItemAction.TakeRateDataItemDetails:
                    return new
                    {
                        TakeRateDataItemId,
                        Action
                    };
                case TakeRateDataItemAction.AddNote:
                    return new
                    {
                        TakeRateId,
                        MarketId,
                        MarketGroupId,
                        FeatureIdentifier,
                        ModelIdentifier,
                        Comment
                    };
                case TakeRateDataItemAction.NotSet:
                    break;
                case TakeRateDataItemAction.TakeRates:
                    break;
                case TakeRateDataItemAction.TakeRateDataPage:
                    break;
                case TakeRateDataItemAction.UndoChange:
                    break;
                case TakeRateDataItemAction.SaveChanges:
                    break;
                case TakeRateDataItemAction.History:
                    break;
                case TakeRateDataItemAction.Validate:
                    break;
                case TakeRateDataItemAction.Changeset:
                    break;
                case TakeRateDataItemAction.MarketReview:
                    break;
                default:
                    throw new ArgumentOutOfRangeException();
            }

            return new {};
        }
    }
}
