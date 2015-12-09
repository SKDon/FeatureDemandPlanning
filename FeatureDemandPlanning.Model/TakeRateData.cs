using System;
using System.Collections.Generic;
using System.Data;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

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
        public IEnumerable<DataRow> FeatureApplicabilityData { get { return _faData; } set { _faData = value; } }
        public IEnumerable<ModelTakeRateSummary> TakeRateSummaryByModel { get { return _takeRateSummaryByModel; } set { _takeRateSummaryByModel = value; } }

        private IEnumerable<DataRow> _rawData = Enumerable.Empty<DataRow>();
        private IEnumerable<DataRow> _faData = Enumerable.Empty<DataRow>();
        private IEnumerable<ModelTakeRateSummary> _takeRateSummaryByModel = Enumerable.Empty<ModelTakeRateSummary>();
    }
}
