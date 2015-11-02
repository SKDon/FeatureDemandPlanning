using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;

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
