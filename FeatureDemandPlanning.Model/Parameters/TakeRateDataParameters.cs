using System.Collections.Generic;
using System.Linq;
using FeatureDemandPlanning.Model.Enumerations;

namespace FeatureDemandPlanning.Model.Parameters
{
    public class TakeRateDataParameters : JQueryDataTableParameters
    {
        public int? OxoDocId { get; set; }
        public int? MarketId { get; set; }
        public int? MarketGroupId { get; set; }
        public string FilterMessage { get; set; }
        public TakeRateResultMode ResultsMode { get; set; }
        public IEnumerable<Model> Models { get; set; }

        public TakeRateDataParameters()
        {
            Models = Enumerable.Empty<Model>();
            ResultsMode = TakeRateResultMode.PercentageTakeRate;
        }
    }
}
