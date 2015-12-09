using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace FeatureDemandPlanning.Model
{
    public class TakeRateDataItem
    {
        public int? FdpTakeRateDataItemId { get; set; }

        public DateTime CreatedOn { get; set; }
        public string CreatedBy { get; set; }

        public int? FdpVolumeHeaderId { get; set; }
        public int? DocumentId { get; set; }

        public bool IsManuallyEntered { get; set; }
        
        public int? MarketId { get; set; }
        public int? MarketGroupId { get; set; }
        public int? ModelId { get; set; }
        public int? FdpModelId { get; set; }
        public int? FeatureId { get; set; }
        public int? FdpFeatureId { get; set; }
        public int? FeaturePackId { get; set; }
        
        public int Volume { get; set; }
        public decimal PercentageTakeRate { get; set; }
        
        public DateTime? UpdatedOn { get; set; }
        public string UpdatedBy { get; set; }

        public IEnumerable<TakeRateDataItemNote> Notes { get; set; }

        public TakeRateDataItem()
        {
            Notes = Enumerable.Empty<TakeRateDataItemNote>();
        }
    }
}
