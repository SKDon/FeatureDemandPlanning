using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;

namespace FeatureDemandPlanning.BusinessObjects
{
    public class FdpOxoVolumeDataItemNote
    {
        public int? FdpOxoVolumeDataItemNoteId { get; set; }
        public DateTime EnteredOn { get; set; }
        public string EnteredBy { get; set; }
        public string Note { get; set; }
    }
}
