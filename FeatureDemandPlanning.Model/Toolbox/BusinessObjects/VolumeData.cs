using System;
using System.Collections.Generic;
using System.Data;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace FeatureDemandPlanning.BusinessObjects
{
    public class VolumeData
    {
        public int TotalVolume { get; set; }
        public int FilteredVolume { get; set; }
        public decimal PercentageOfTotalVolume { get; set; }

        public DateTime CreatedOn { get; set; }
        public string CreatedBy { get; set; }

        public IEnumerable<DataRow> RawData { get; set; }
        public IEnumerable<DataRow> FeatureApplicabilityData { get { return _faData; } set { _faData = value; } }
        public IEnumerable<DerivativeVolumeData> VolumeByModel { get { return _volumeByModel; } set { _volumeByModel = value; } }

        private IEnumerable<DataRow> _rawData = Enumerable.Empty<DataRow>();
        private IEnumerable<DataRow> _faData = Enumerable.Empty<DataRow>();
        private IEnumerable<DerivativeVolumeData> _volumeByModel = Enumerable.Empty<DerivativeVolumeData>();
    }

    public class DerivativeVolumeData
    {
        public int ModelId { get; set; }
        public int Volume { get; set; }
        public decimal PercentageOfFilteredVolume { get; set; }
    }
}
