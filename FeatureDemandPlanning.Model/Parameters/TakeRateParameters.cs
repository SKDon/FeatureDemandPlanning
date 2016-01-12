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

        public FdpChangeset Changeset { get; set; }

        public TakeRateParameters()
        {
            Action = TakeRateDataItemAction.NotSet;
            Changeset = new EmptyFdpChangeset();
        }

        public object GetActionSpecificParameters()
        {
            if (Action == TakeRateDataItemAction.TakeRateDataItemDetails)
            {
                return new
                {
                    TakeRateDataItemId,
                    Action
                };
            }

            return new { };
        }
    }
}
