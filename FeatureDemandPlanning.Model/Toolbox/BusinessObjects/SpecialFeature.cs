using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace FeatureDemandPlanning.BusinessObjects
{
    public class SpecialFeature
    {
        public int FdpSpecialFeatureTypeId { get; set; }
        public string SpecialFeatureType { get; set; }
        public string Description { get; set; }
    }
}
