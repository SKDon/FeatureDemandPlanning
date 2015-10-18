using FeatureDemandPlanning.BusinessObjects;
using FeatureDemandPlanning.BusinessObjects.Filters;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace FeatureDemandPlanning.Interfaces
{
    public interface IMarketDataContext
    {
        IEnumerable<Market> ListAvailableMarkets();
        IEnumerable<Market> ListTopMarkets();

        Market GetMarket(VolumeFilter filter);
        MarketGroup GetMarketGroup(VolumeFilter filter);
        
        Market GetTopMarket(int marketId);
        Market AddTopMarket(int marketId);
        Market DeleteTopMarket(int marketId);

        IEnumerable<BusinessObjects.Model> ListAvailableModelsByMarket(OXODoc forDocument, Market byMarket);
        IEnumerable<BusinessObjects.Model> ListAvailableModelsByMarketGroup(OXODoc forDocument, MarketGroup byMarketGroup);
    }
}
