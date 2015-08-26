using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace FeatureDemandPlanning.BusinessObjects
{
    public class ImportError
    {
        public int ImportQueueId { get; set; }
        public DateTime ErrorOn { get; set; }
        public string Error { get; set; }
    }
}
