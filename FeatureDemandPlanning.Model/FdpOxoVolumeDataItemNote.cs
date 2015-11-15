using System;

namespace FeatureDemandPlanning.Model
{
    public class FdpOxoVolumeDataItemNote
    {
        public int? FdpOxoVolumeDataItemNoteId { get; set; }
        public DateTime EnteredOn { get; set; }
        public string EnteredBy { get; set; }
        public string Note { get; set; }
    }
}
