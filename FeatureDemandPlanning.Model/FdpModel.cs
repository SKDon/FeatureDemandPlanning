using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace FeatureDemandPlanning.Model
{
    public class FdpModel : Model
    {
        public int? FdpModelId { get; set; }
        public int? FdpTrimId { get; set; }
        public string StringIdentifier { get; set; }
    }
}
