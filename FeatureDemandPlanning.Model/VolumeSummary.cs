using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace FeatureDemandPlanning.Model
{
    public class VolumeSummary
    {
        public int FdpVolumeHeaderId { get; set; }
        public int OxoDocId { get; set; }

        public DateTime CreatedOn { get; set; }
        public string CreatedBy { get; set; }

        public string CarLine { get; set; }
        public string ModelYear { get; set; }
        public string Gateway { get; set; }

        public string Code { get; set; }
    }
}
