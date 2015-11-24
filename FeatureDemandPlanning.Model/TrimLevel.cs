using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace FeatureDemandPlanning.Model
{
    public class TrimLevel : BusinessObject
    {
        public int Level { get; set; }
        public string Description { get; set; }
        public int DisplayOrder { get; set; }
    }
}
