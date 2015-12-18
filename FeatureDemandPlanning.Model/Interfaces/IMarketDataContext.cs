using FeatureDemandPlanning.Model;
using FeatureDemandPlanning.Model.Context;
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
        Task<IEnumerable<Market>> ListAvailableMarkets();
        Task<IEnumerable<Market>> ListTopMarkets();

        Market GetMarket(TakeRateFilter filter);
        MarketGroup GetMarketGroup(TakeRateFilter filter);
        
        Market GetTopMarket(int marketId);
        Market AddTopMarket(int marketId);
        Market DeleteTopMarket(int marketId);

        Task<IEnumerable<FdpModel>> ListAvailableModelsByMarket(ProgrammeFilter filter, Market byMarket);
        Task<IEnumerable<FdpModel>> ListAvailableModelsByMarketGroup(ProgrammeFilter filter, MarketGroup byMarketGroup);

        // Mappings

        Task<FdpMarketMapping> DeleteFdpMarketMapping(FdpMarketMapping fdpMarketMapping);
        Task<FdpMarketMapping> GetFdpMarketMapping(MarketMappingFilter filter);
        Task<PagedResults<FdpMarketMapping>> ListFdpMarketMappings(MarketMappingFilter filter);

        Task<FdpMarketMapping> CopyFdpMarketMappingToGateway(FdpMarketMapping fdpMarketMapping, IEnumerable<string> gateways);
        Task<FdpMarketMapping> CopyFdpMarketMappingsToGateway(FdpMarketMapping fdpMarketMapping, IEnumerable<string> gateways);
    }
}
