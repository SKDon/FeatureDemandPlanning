using FeatureDemandPlanning.Model.Enumerations;
using FeatureDemandPlanning.Model.Parameters;

namespace FeatureDemandPlanning.Model.Filters
{
    public class MarketFilter : FilterBase
    {
        public int? MarketId { get; set; }

        public string CarLine { get; set; }
        public string ModelYear { get; set; }
        public int? ProgrammeId { get; set; }
        public string Gateway { get; set; }

        public string Market { get; set; }

        public MarketAction Action { get; set; }

        public MarketFilter()
        {
            Action = MarketAction.NotSet;
        }

        public static MarketFilter FromMarketId(int? marketId)
        {
            return new MarketFilter
            {
                MarketId = marketId
            };
        }
        public static MarketFilter FromParameters(MarketParameters parameters)
        {
            return new MarketFilter
            {
                MarketId = parameters.MarketId,
                Action = parameters.Action
            };
        }
    }
}
