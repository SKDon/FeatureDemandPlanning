using System;

namespace FeatureDemandPlanning.Model
{
    public class TakeRateDataItemAudit
    {
        public DateTime AuditOn { get; set; }
        public string AuditBy { get; set; }
        public int? Volume { get; set; }
        public decimal? PercentageTakeRate { get; set; }

        public bool IsUncommittedChange { get; set; }

        public TakeRateDataItemAudit()
        {
            IsUncommittedChange = false;
        }
    }
}
