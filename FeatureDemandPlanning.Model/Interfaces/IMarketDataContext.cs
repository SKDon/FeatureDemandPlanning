using FeatureDemandPlanning.BusinessObjects;
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

        Market GetTopMarket(int marketId);
        Market AddTopMarket(int marketId);
        Market DeleteTopMarket(int marketId);
    }
}
