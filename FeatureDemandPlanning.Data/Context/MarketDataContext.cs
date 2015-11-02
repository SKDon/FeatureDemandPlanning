using FeatureDemandPlanning.Model;
using FeatureDemandPlanning.Model.Filters;
using FeatureDemandPlanning.Model.Enumerations;
using FeatureDemandPlanning.Model.Interfaces;
using FeatureDemandPlanning.Model;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using enums = FeatureDemandPlanning.Model.Enumerations;

namespace FeatureDemandPlanning.DataStore
{
    public class MarketDataContext : BaseDataContext, IMarketDataContext
    {
        public MarketDataContext(string cdsId)
            : base(cdsId)
        {
            _marketDataStore = new MarketDataStore(cdsId);
            _marketGroupDataStore = new MarketGroupDataStore(cdsId);
            _documentDataStore = new OXODocDataStore(cdsId);
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
        public IEnumerable<Market> ListAvailableMarkets(ProgrammeFilter filter)
        {
            return _marketDataStore.MarketAvailableGetMany(filter.ProgrammeId.GetValueOrDefault())
                                    .OrderBy(m => m.Name);
        }
        public IEnumerable<Market> ListTopMarkets()
        {
            return _marketDataStore.TopMarketGetMany()
                .OrderBy(m => m.Name);
        }
        public Market GetMarket(VolumeFilter filter)
        {
            if (!filter.MarketId.HasValue)
                return new EmptyMarket();

            var market =  _marketDataStore.MarketGet(filter.MarketId.Value);

            if (market == null)
                return new EmptyMarket();

            // Populate the list of available derivatives for that market
            if (filter.OxoDocId.HasValue && filter.ProgrammeId.HasValue)
            {
                var variants = _documentDataStore.OXODocAvailableModelsByMarket(filter.ProgrammeId.Value, filter.OxoDocId.Value, market.Id);
                market.VariantCount = variants.Count();
            }

            return market;
        }
        public MarketGroup GetMarketGroup(VolumeFilter filter)
        {
            if (!filter.MarketGroupId.HasValue || !filter.OxoDocId.HasValue || !filter.ProgrammeId.HasValue)
                return new EmptyMarketGroup();

            var marketGroup = _marketGroupDataStore.MarketGroupGet(string.Empty, 
                                                        filter.MarketGroupId.Value, 
                                                        progid:filter.ProgrammeId.Value, 
                                                        docid:filter.OxoDocId.Value);
            if (marketGroup == null)
                return new EmptyMarketGroup();

            // Populate the list of available derivatives for that market
            if (filter.OxoDocId.HasValue && filter.ProgrammeId.HasValue)
            {
                var variants = _documentDataStore.OXODocAvailableModelsByMarketGroup(filter.ProgrammeId.Value, filter.OxoDocId.Value, marketGroup.Id);
                marketGroup.VariantCount = variants.Count();
            }

            return marketGroup;
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
        public IEnumerable<Model.Model> ListAvailableModelsByMarket(OXODoc forDocument, Market byMarket)
        {
            return _documentDataStore.OXODocAvailableModelsByMarket(forDocument.ProgrammeId, forDocument.Id, byMarket.Id)
                .Where(m => m.Available == true);
        }
        public IEnumerable<Model.Model> ListAvailableModelsByMarketGroup(OXODoc forDocument, MarketGroup byMarketGroup)
        {
            return _documentDataStore.OXODocAvailableModelsByMarketGroup(forDocument.ProgrammeId, forDocument.Id, byMarketGroup.Id)
                .Where(m => m.Available == true);
        }

        private MarketDataStore _marketDataStore;
        private MarketGroupDataStore _marketGroupDataStore;
        private OXODocDataStore _documentDataStore;
    }
}
