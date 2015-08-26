using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace FeatureDemandPlanning.BusinessObjects.Filters
{
    public class ImportQueueFilter : FilterBase
    {
        public int? ImportQueueId { get; set; }

        public ImportQueueFilter()
        {

        }

        public ImportQueueFilter(int importQueueId) : this()
        {
            ImportQueueId = importQueueId;
        }
    }
}
