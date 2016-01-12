using System.Collections.Generic;

namespace FeatureDemandPlanning.Model
{
    public class FdpChangesetHistory
    {
        public IEnumerable<FdpChangesetHistoryItem> History { get; set; }
    }
}
