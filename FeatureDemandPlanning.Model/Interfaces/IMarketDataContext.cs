using FeatureDemandPlanning.Model;
using FeatureDemandPlanning.Model.Filters;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace FeatureDemandPlanning.Model.Interfaces
{
    public interface IMarketDataContext
    {
        IEnumerable<Market> ListAvailableMarkets();
        IEnumerable<Market> ListAvailableMarkets(ProgrammeFilter filter);
        IEnumerable<Market> ListTopMarkets();

        Market GetMarket(VolumeFilter filter);
        MarketGroup GetMarketGroup(VolumeFilter filter);
        
        Market GetTopMarket(int marketId);
        Market AddTopMarket(int marketId);
        Market DeleteTopMarket(int marketId);

        IEnumerable<Model> ListAvailableModelsByMarket(OXODoc forDocument, Market byMarket);
        IEnumerable<Model> ListAvailableModelsByMarketGroup(OXODoc forDocument, MarketGroup byMarketGroup);
    }
}
