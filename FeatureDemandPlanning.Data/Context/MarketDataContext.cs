using FeatureDemandPlanning.Model;
using FeatureDemandPlanning.Model.Filters;
using FeatureDemandPlanning.Model.Interfaces;
using System;
using System.Collections.Generic;
using System.Linq;
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
        public Market GetMarket(int marketId)
        {
            return _marketDataStore.MarketGet(marketId);
        }
        public Market GetMarket(TakeRateFilter filter)
        {
            if (!filter.MarketId.HasValue || !filter.TakeRateId.HasValue)
                return new EmptyMarket();

            var market =  _marketDataStore.MarketGet(filter.MarketId.Value);

            if (market == null)
                return new EmptyMarket();

            // Populate the list of available derivatives for that market (including FDP derivatives)

            var variants = _modelDataStore.FdpAvailableModelByMarketGetMany(filter);
            market.VariantCount = variants.Count();

            return market;
        }
        public MarketGroup GetMarketGroup(TakeRateFilter filter)
        {
            if (!filter.MarketGroupId.HasValue || !filter.TakeRateId.HasValue)
                return new EmptyMarketGroup();

            var marketGroup = _marketGroupDataStore.FdpMarketGroupGet(filter);

            if (marketGroup == null)
                return new EmptyMarketGroup();

            // Populate the list of available derivatives for that market (including FDP derivatives)
           
            var variants = _modelDataStore.FdpAvailableModelByMarketGroupGetMany(filter);
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
        public async Task<IEnumerable<FdpModel>> ListAvailableModelsByMarket(TakeRateFilter filter)
        {
            return await Task.FromResult(_modelDataStore.FdpAvailableModelByMarketGetMany(filter)
                .Where(m => m.Available));
        }
        public async Task<IEnumerable<FdpModel>> ListAvailableModelsByMarketGroup(TakeRateFilter filter)
        {
            return await Task.FromResult(_modelDataStore.FdpAvailableModelByMarketGroupGetMany(filter)
                .Where(m => m.Available));
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
        public async Task<IEnumerable<Market>> ListMarkets(TakeRateFilter filter)
        {
            return await Task.FromResult(_marketDataStore.MarketGetMany(filter));
        }

        private MarketDataStore _marketDataStore;
        private MarketGroupDataStore _marketGroupDataStore;
        private OXODocDataStore _documentDataStore;
        private ModelDataStore _modelDataStore;


       
    }
}
