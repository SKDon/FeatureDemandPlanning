using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace FeatureDemandPlanning.BusinessObjects
{
    public class EmptyVolume : Volume
    {
        public EmptyVolume()
        {
            Document = new EmptyOxoDocument();
            Vehicle = new EmptyVehicle();
            Market = new EmptyMarket();
            MarketGroup = new EmptyMarketGroup();
        }
    }
}
