using FeatureDemandPlanning.Model.Empty;
using System;
using System.Collections.Generic;
using System.Linq;

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

        public string ModelIdentifier
        {
            get
            {
                if (ModelId.HasValue)
                {
                    return string.Format("O{0}", ModelId);
                }
                else
                {
                    return string.Format("F{0}", FdpModelId);
                }
            }
        }

        public string FeatureIdentifier
        {
            get
            {
                if (FeatureId.HasValue)
                {
                    return string.Format("O{0}", FeatureId);
                }
                else
                {
                    return string.Format("F{0}", FdpFeatureId);
                }
            }
        }
        
        public int Volume { get; set; }
        public decimal PercentageTakeRate { get; set; }
        
        public DateTime? UpdatedOn { get; set; }
        public string UpdatedBy { get; set; }

        public FdpModel Model { get; set; }
        public FdpFeature Feature { get; set; }
        public IEnumerable<TakeRateDataItemNote> Notes { get; set; }
        public IEnumerable<TakeRateDataItemAudit> History { get; set; }

        public bool HasUncommittedChanges { get; set; }

        public TakeRateDataItem()
        {
            Notes = Enumerable.Empty<TakeRateDataItemNote>();
            History = Enumerable.Empty<TakeRateDataItemAudit>();
            Model = new EmptyFdpModel();
            Feature = new EmptyFdpFeature();
            HasUncommittedChanges = false;
        }
    }
}
