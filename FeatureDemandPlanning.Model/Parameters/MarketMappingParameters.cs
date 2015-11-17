using FeatureDemandPlanning.Model.Enumerations;
using System.Collections.Generic;
using System.Linq;

namespace FeatureDemandPlanning.Model.Parameters
{
    public class MarketMappingParameters : MarketParameters
    {
        public int? MarketMappingId { get; set; }
        public string ImportMarket { get; set; }
      
        public new MarketMappingAction Action { get; set; }

        public IEnumerable<string> CopyToGateways { get; set; }

        public MarketMappingParameters()
        {
            Action = MarketMappingAction.NotSet;
            CopyToGateways = Enumerable.Empty<string>();
        }

        public new object GetActionSpecificParameters()
        {
            if (Action == MarketMappingAction.Delete || 
                Action == MarketMappingAction.Copy || 
                Action == MarketMappingAction.CopyAll)
            {
                return new
                {
                    MarketMappingId
                };
            }

            return new { };
        }
    }
}
