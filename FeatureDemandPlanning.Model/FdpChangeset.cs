using System;
using System.Collections.Generic;

namespace FeatureDemandPlanning.Model
{
    public class FdpChangeset
    {
        public int? FdpChangesetId { get; set; }
        public DateTime CreatedOn { get; set; }
        public string CreatedBy { get; set; }
        public bool IsDeleted { get; set; }
        public bool IsSaved { get; set; }
        public string Comment { get; set; }

        public List<DataChange> Changes { get; set; }
        public IList<DataChange> Reverted { get; set; }

        public FdpChangeset()
        {
            Changes = new List<DataChange>();
            Reverted = new List<DataChange>();
            ModelMix = new AllModelMix()
            {
                HasModelMixChanged = false,
                HasModelVolumeChanged = false
            };
        }

        public AllModelMix ModelMix { get; set; }
    }
}
