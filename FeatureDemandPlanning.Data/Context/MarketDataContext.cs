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
using FeatureDemandPlanning.Model.Empty;

namespace FeatureDemandPlanning.DataStore
{
    public class MarketDataContext : BaseDataContext, IMarketDataContext
    {
        public MarketDataContext(string cdsId)
            : base(cdsId)
        {
            _marketDataStore = new MarketDataStore(cdsId);
            _modelDataStore = new ModelDataStore(cdsId);
            _marketGroupDataStore = new MarketGroupDataStore(cdsId);
            _documentDataStore = new OXODocDataStore(cdsId);
        }
        public async Task<IEnumerable<Market>> ListAvailableMarkets()
        {
            return await Task.FromResult(_marketDataStore.FdpMarketAvailableGetMany());
        }
        
        public async Task<IEnumerable<Market>> ListTopMarkets()
        {
            return await Task.FromResult(_marketDataStore.TopMarketGetMany()
                .OrderBy(m => m.Name));
        }
        public Market GetMarket(TakeRateFilter filter)
        {
            if (!filter.MarketId.HasValue)
                return new EmptyMarket();

            var market =  _marketDataStore.MarketGet(filter.MarketId.Value);

            if (market == null)
                return new EmptyMarket();

            // Populate the list of available derivatives for that market (including FDP derivatives)
            if (!filter.OxoDocId.HasValue || !filter.ProgrammeId.HasValue) return market;

            var variants = _modelDataStore.FdpAvailableModelByMarketGetMany(filter, market);
            market.VariantCount = variants.Count();

            return market;
        }
        public MarketGroup GetMarketGroup(TakeRateFilter filter)
        {
            if (!filter.MarketGroupId.HasValue || !filter.OxoDocId.HasValue || !filter.ProgrammeId.HasValue)
                return new EmptyMarketGroup();

            var marketGroup = _marketGroupDataStore.MarketGroupGet(string.Empty, 
                                                        filter.MarketGroupId.Value, 
                                                        progid:filter.ProgrammeId.Value, 
                                                        docid:filter.OxoDocId.Value);
            if (marketGroup == null)
                return new EmptyMarketGroup();

            // Populate the list of available derivatives for that market (including FDP derivatives)
            if (!filter.OxoDocId.HasValue || !filter.ProgrammeId.HasValue) return marketGroup;

            var variants = _modelDataStore.FdpAvailableModelByMarketGroupGetMany(filter, marketGroup);
            marketGroup.VariantCount = variants.Count();

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
        public async Task<IEnumerable<FdpModel>> ListAvailableModelsByMarket(ProgrammeFilter filter, Market byMarket)
        {
            return await Task.FromResult(_modelDataStore.FdpAvailableModelByMarketGetMany(filter, byMarket)
                .Where(m => m.Available == true));
        }
        public async Task<IEnumerable<FdpModel>> ListAvailableModelsByMarketGroup(ProgrammeFilter filter, MarketGroup byMarketGroup)
        {
            return await Task.FromResult(_modelDataStore.FdpAvailableModelByMarketGroupGetMany(filter, byMarketGroup)
                .Where(m => m.Available == true));
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
        private ModelDataStore _modelDataStore;
    }
}
