using FeatureDemandPlanning.Model;
using FeatureDemandPlanning.Model.Interfaces;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Web;

namespace FeatureDemandPlanning.Model.ViewModel
{
    public class MarketViewModel : SharedModelBase
    {
        public IEnumerable<Market> AvailableMarkets { get; set; }
        public IEnumerable<Market> TopMarkets { get; set; }
        public int NumberOfMarkets { get { return TopMarkets != null && TopMarkets.Any() ? TopMarkets.Count() : 0; } }

        public MarketViewModel() : base()
        {
        }
        public static MarketViewModel GetModel(IDataContext context)
        {
            return new MarketViewModel()
            {
                Configuration = context.ConfigurationSettings
            };
        }
    }
}