using System;
using System.Collections.Generic;
using System.Data;
using System.Linq;

namespace FeatureDemandPlanning.Model
{
    public class TakeRateData
    {
        public int TotalVolume { get; set; }
        public int FilteredVolume { get; set; }
        public decimal PercentageOfTotalVolume { get; set; }

        public DateTime CreatedOn { get; set; }
        public string CreatedBy { get; set; }

        public IEnumerable<DataRow> RawData { get; set; }
        public IEnumerable<DataRow> FeatureApplicabilityData { get; set; }
        public IEnumerable<DerivativeTakeRateData> TakeRateByModel { get; set; }

        public TakeRateData()
        {
            RawData = Enumerable.Empty<DataRow>();
            FeatureApplicabilityData = Enumerable.Empty<DataRow>();
            TakeRateByModel = Enumerable.Empty<DerivativeTakeRateData>();
        }
    }

    public class DerivativeTakeRateData
    {
        public int ModelId { get; set; }
        public int Volume { get; set; }
        public decimal PercentageOfFilteredVolume { get; set; }
    }
}
