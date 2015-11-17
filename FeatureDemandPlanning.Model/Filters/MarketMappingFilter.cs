using FeatureDemandPlanning.Model.Enumerations;
using FeatureDemandPlanning.Model.Parameters;
namespace FeatureDemandPlanning.Model.Filters
{
    public class MarketMappingFilter : MarketFilter
    {
        public int? MarketMappingId { get; set; }
        public new MarketMappingAction Action { get; set; }

        public MarketMappingFilter()
        {
            Action = MarketMappingAction.NotSet;
        }

        public static MarketMappingFilter FromMarketMappingId(int? marketMappingId)
        {
            return new MarketMappingFilter()
            {
                MarketMappingId = marketMappingId
            };
        }
        public static MarketMappingFilter FromMarketMappingParameters(MarketMappingParameters parameters)
        {
            return new MarketMappingFilter()
            {
                MarketMappingId = parameters.MarketMappingId,
                Action = parameters.Action
            };
        }
    }
}
