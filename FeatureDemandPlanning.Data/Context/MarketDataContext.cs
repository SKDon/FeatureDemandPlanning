using FeatureDemandPlanning.BusinessObjects;
using FeatureDemandPlanning.Enumerations;
using FeatureDemandPlanning.Interfaces;
using FeatureDemandPlanning.Model;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using enums = FeatureDemandPlanning.Enumerations;

namespace FeatureDemandPlanning.DataStore
{
    public class MarketDataContext : BaseDataContext, IMarketDataContext
    {
        public MarketDataContext(string cdsId)
            : base(cdsId)
        {
            _marketDataStore = new MarketDataStore(cdsId);
        }

        public IEnumerable<Market> ListAvailableMarkets()
        {
            var topMarkets = ListTopMarkets();

            var markets = _marketDataStore.MarketGetMany()
                .Where(m => !topMarkets.Contains(m, new MarketComparer()))
                .Where(m => m.Active == true)
                .OrderBy(m => m.Name).ToList();

            return markets;
        }

        public IEnumerable<Market> ListTopMarkets()
        {
            return _marketDataStore.TopMarketGetMany()
                .OrderBy(m => m.Name);
        }

        public Market GetTopMarket(int marketId)
        {
            return _marketDataStore.TopMarketGet(marketId);
        }

        public Market AddTopMarket(int marketId)
        {
            var market = new Market() {
                Id = marketId
            };
            
            return _marketDataStore.TopMarketSave(market);
        }

        public Market DeleteTopMarket(int marketId)
        {
            var market = new Market()
            {
                Id = marketId
            };

            return _marketDataStore.TopMarketDelete(market);
        }

        private MarketDataStore _marketDataStore;
    }
}
