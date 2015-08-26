using FeatureDemandPlanning.BusinessObjects;
using FeatureDemandPlanning.Interfaces;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;

namespace FeatureDemandPlanning.Models
{
    public class MarketViewModel : SharedModelBase
    {
        public IEnumerable<Market> AvailableMarkets { get; set; }
        public IEnumerable<Market> TopMarkets { get; set; }
        public int NumberOfMarkets { get { return TopMarkets != null && TopMarkets.Any() ? TopMarkets.Count() : 0; } }

        public dynamic Configuration { get; set; }

        public MarketViewModel(IDataContext dataContext) : base(dataContext)
        {
            Configuration = dataContext.ConfigurationSettings;
        }
    }
}