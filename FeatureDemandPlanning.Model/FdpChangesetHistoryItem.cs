using System;

namespace FeatureDemandPlanning.Model
{
    public class FdpChangesetHistoryItem
    {
        public int? FdpChangesetId { get; set; }
        public DateTime UpdatedOn { get; set; }
        public string UpdatedBy { get; set; }
        public string Comment { get; set; }
        public string Market { get; set; }
        public bool IsSaved { get; set; }
        public bool IsMarketReview { get; set; }
    
    }

    public class FdpChangesetHistoryItemDetails
    {
        public DateTime UpdatedOn { get; set; }
        public string UpdatedBy { get; set; }
        public string Change { get; set; }
        public bool IsPercentageUpdate { get; set; }
        public int OldVolume { get; set; }
        public int NewVolume { get; set; }
        public decimal OldPercentageTakeRate { get; set; }
        public decimal NewPercentageTakeRate { get; set; }

    }
}
