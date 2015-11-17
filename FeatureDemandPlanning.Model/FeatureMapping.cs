using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace FeatureDemandPlanning.Model
{
    public class FeatureMapping
    {
        public int? FdpFeatureMappingId { get; set; }

        public DateTime? CreatedOn { get; set; }
        public string CreatedBy { get; set; }

        public string ImportFeatureCode { get; set; }

        public int ProgrammeId { get; set; }
        public string Gateway { get; set; }
        
        public int? FeatureId { get; set; }
        public string FeatureCode { get; set; }
        public string FeatureDescription { get; set; }
        public Feature MappedFeature { get; set; }

        public bool IsActive { get; set; }

        public DateTime? UpdatedOn { get; set; }
        public string UpdatedBy { get; set; }

        public FeatureMapping()
        {
            MappedFeature = new EmptyFeature();
            IsActive = true;
        }
    }
}
