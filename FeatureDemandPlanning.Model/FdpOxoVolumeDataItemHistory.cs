using System;

namespace FeatureDemandPlanning.Model
{
    public class FdpOxoVolumeDataItemHistory
    {
        public string AuditBy { get; set; }
        public DateTime AuditOn { get; set; }
        public int Volume { get; set; }
        public Single PercentageTakeRate { get; set; }
    }
}
