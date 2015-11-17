using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace FeatureDemandPlanning.Model
{
    public class FdpFeature : Feature
    {
        public int? ProgrammeId { get; set; }
        public string Gateway { get; set; }

        public int? FdpFeatureId { get; set; }
        public int? FeatureGroupId { get; set; }
        public bool IsActive { get; set; }

        public DateTime? UpdatedOn { get; set; }

        public FdpFeature() : base()
        {
            IsActive = true;
        }
    }
}
