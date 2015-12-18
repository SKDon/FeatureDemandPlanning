using FeatureDemandPlanning.Model.Empty;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace FeatureDemandPlanning.Model
{
    public class EmptyTakeRateDocument : TakeRateDocument
    {
        public EmptyTakeRateDocument()
        {
            UnderlyingOxoDocument = new EmptyOxoDocument();
            Vehicle = new EmptyVehicle();
            Market = new EmptyMarket();
            MarketGroup = new EmptyMarketGroup();
        }
    }
}
