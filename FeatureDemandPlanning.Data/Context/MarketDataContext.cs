using FeatureDemandPlanning.Model;
using FeatureDemandPlanning.Model.Filters;
using FeatureDemandPlanning.Model.Enumerations;
using FeatureDemandPlanning.Model.Interfaces;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using enums = FeatureDemandPlanning.Model.Enumerations;
using FeatureDemandPlanning.Model.Context;

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
            return _marketDataStore.FdpMarketAvailableGetMany();
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
                var programmeFilter = new ProgrammeFilter()
                {
                    ProgrammeId = filter.ProgrammeId,
                    Gateway = filter.Gateway,
                    MarketId = filter.MarketId
                };
                var variants = _documentDataStore.FdpModelsByMarketGetMany(programmeFilter);
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
                var programmeFilter = new ProgrammeFilter()
                {
                    ProgrammeId = filter.ProgrammeId,
                    Gateway = filter.Gateway,
                    MarketGroupId = filter.MarketGroupId
                };
                var variants = _documentDataStore.FdpModelsByMarketGroupGetMany(programmeFilter);
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
        public IEnumerable<FdpModel> ListAvailableModelsByMarket(OXODoc forDocument, Market byMarket)
        {
            var filter = new ProgrammeFilter()
            {
                ProgrammeId = forDocument.ProgrammeId,
                Gateway = forDocument.Gateway,
                MarketId = byMarket.Id
            };
            return _documentDataStore.FdpModelsByMarketGetMany(filter)
                .Where(m => m.Available == true);
        }
        public IEnumerable<FdpModel> ListAvailableModelsByMarketGroup(OXODoc forDocument, MarketGroup byMarketGroup)
        {
            var filter = new ProgrammeFilter()
            {
                ProgrammeId = forDocument.ProgrammeId,
                Gateway = forDocument.Gateway,
                MarketGroupId = byMarketGroup.Id
            };
            return _documentDataStore.FdpModelsByMarketGroupGetMany(filter)
                .Where(m => m.Available == true);
        }

        public async Task<FdpMarketMapping> DeleteFdpMarketMapping(FdpMarketMapping marketMappingToDelete)
        {
            return await Task.FromResult<FdpMarketMapping>(_marketDataStore.FdpMarketMappingDelete(marketMappingToDelete));
        }
        public async Task<FdpMarketMapping> GetFdpMarketMapping(MarketMappingFilter filter)
        {
            return await Task.FromResult<FdpMarketMapping>(_marketDataStore.FdpMarketMappingGet(filter));
        }
        public async Task<PagedResults<FdpMarketMapping>> ListFdpMarketMappings(MarketMappingFilter filter)
        {
            return await Task.FromResult<PagedResults<FdpMarketMapping>>(_marketDataStore.FdpMarketMappingGetMany(filter));
        }
        public Task<FdpMarketMapping> CopyFdpMarketMappingToGateway(FdpMarketMapping fdpMarketMapping, IEnumerable<string> enumerable)
        {
            throw new NotImplementedException();
        }
        public Task<FdpMarketMapping> CopyFdpMarketMappingsToGateway(FdpMarketMapping fdpMarketMapping, IEnumerable<string> enumerable)
        {
            throw new NotImplementedException();
        }

        private MarketDataStore _marketDataStore;
        private MarketGroupDataStore _marketGroupDataStore;
        private OXODocDataStore _documentDataStore;
    }
}
